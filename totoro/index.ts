import fs from "fs";
import { $ } from "bun";
import OpenAI from "openai";
import type { AssistantStream } from "openai/lib/AssistantStream.mjs";
import path from "path";

// Path to the file
const filePath = path.resolve(
  "/home/mn/code/personal-stuff/totoro/thread_id.string",
);

// Read the file
function readThreadId() {
  try {
    // Read the file contents
    const data = fs.readFileSync(filePath, "utf-8").trim();
    // Return undefined if the file is empty
    return data === "" ? undefined : data;
  } catch (err) {
    return undefined;
  }
}

async function saveThreadId() {
  const threadId = (await client.beta.threads.create()).id;

  try {
    // Write the thread ID to the file
    fs.writeFileSync(filePath, threadId, { encoding: "utf-8" });
    return threadId;
  } catch (err) {
    throw err;
  }
}

const callWolframAlpha = async (args: string) => {
  // RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$APPID&units=metric&" --data-urlencode "i=$*")

  const APPID = await $`secret-tool lookup wolfram password`.quiet().text();

  args = encodeURIComponent(args);

  const response = await fetch(
    `https://api.wolframalpha.com/v1/result?appid=${APPID}&units=metric&i=${args}`,
  );

  if (!response.ok) {
    console.error("Error calling Wolfram Alpha", response);
  }

  return response.text();
};

const OPEN_AI_API_KEY = await $`secret-tool lookup openai password`
  .quiet()
  .text();

const client = new OpenAI({
  apiKey: OPEN_AI_API_KEY,
});

const getMessageFromArgs = () => {
  const message = process.argv[2];
  if (!message) {
    console.error("Please provide a message to send to the assistant");
    process.exit(1);
  }
  return message;
};

const PROMPT = getMessageFromArgs();

let thread_id = readThreadId() || (await saveThreadId());

// const thread_id = (await client.beta.threads.create()).id;
// console.log(thread_id);
// const thread_id = "thread_QgmYdjFIXZZeuqQFdg08OitH";

const runs = await client.beta.threads.runs.list(thread_id);

runs.data.forEach(async (run) => {
  if (run.status === "in_progress" || run.status === "requires_action") {
    await client.beta.threads.runs.cancel(thread_id, run.id);
  }
});

await client.beta.threads.messages.create(thread_id, {
  role: "user",
  content: getMessageFromArgs(),
});

const stream = client.beta.threads.runs.stream(thread_id, {
  assistant_id: "asst_sakseul4mtdjbQ7XI84yUMw8",
});

// const run = await client.beta.threads.runs.create(thread.id, {
//   assistant_id: "asst_sakseul4mtdjbQ7XI84yUMw8",
// });

const handleMessage = (
  _stream: AssistantStream,
  callback?: (message: string) => void,
) => {
  _stream.on("messageDone", async (data) => {
    if (data.content[0].type === "text") {
      if (callback) {
        callback(data.content[0].text.value);
      } else {
        console.log("Totoro:", `"${data.content[0].text.value}"`);
      }
    } else {
      console.error("Error handling data. Logged to Desktop.");
      fs.writeFileSync(
        "/home/mn/Desktop/data.json",
        JSON.stringify(data, null, 2),
      );
      process.exit(1);
    }
  });
  _stream.on("error", (error) => {
    console.error("Error handling message. Logged to Desktop.");
    fs.writeFileSync(
      "/home/mn/Desktop/error.json",
      JSON.stringify(error, null, 2),
    );
    process.exit(1);
  });
  _stream.on("event", (event) => {
    if (event.event === "thread.run.failed") {
      console.error("Error handling event. Logged to Desktop.");
      fs.writeFileSync(
        "/home/mn/Desktop/error.json",
        JSON.stringify(event, null, 2),
      );
    }
  });
};

stream.on("toolCallDone", async (data) => {
  const run = stream.currentRun();

  fs.writeFileSync(
    "/home/mn/Desktop/weird.json",
    JSON.stringify(data, null, 2),
  );

  if (!run) {
    console.error("Error creating run");
    process.exit(1);
  }

  if (data.type !== "function") {
    return;
  }

  if (data.function.name === "wolframalpha") {
    const wolfram_query = JSON.parse(data.function.arguments).query;
    console.log("Totoro asked Wolfram:", `"${wolfram_query}"`);
    $`notify-send "Totoro is talking to Wolfram`.quiet();

    const wolfram_response = await callWolframAlpha(wolfram_query);
    console.log("Wolfram responds:", `"${wolfram_response}"`);

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: wolfram_response,
            tool_call_id: data.id,
          },
        ],
      }),
    );
  } else if (data.function.name === "insert_content") {
    const content = JSON.parse(data.function.arguments).content;

    await $`wtype ${content}`;

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: "Inhalt eingefügt",
            tool_call_id: data.id,
          },
        ],
      }),
    );
  } else if (
    data.function.name === "terminal_befehl" ||
    data.function.name === "paste_command"
  ) {
    const command = JSON.parse(data.function.arguments).command;
    // console.log("Totoro pasting command:", `"${command}"`);
    const dangerous = JSON.parse(data.function.arguments).dangerous;

    await $`wtype ${command}`;

    if (!dangerous) {
      await $`wtype -P return -p return`.quiet();
    }

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: "Command pasted",
            tool_call_id: data.id,
          },
        ],
      }),
    );
    // } else if (data.function.name === "get_clipboard_content") {
    //   const clipboard = await $`wl-paste`.quiet();
    //   console.log("Totoro looked at your clipboard.");

    //   handleMessage(
    //     client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
    //       tool_outputs: [
    //         {
    //           output: clipboard.text(),
    //           tool_call_id: data.id,
    //         },
    //       ],
    //     }),
    //   );
  } else if (data.function.name === "webseite_aufrufen") {
    const url = JSON.parse(data.function.arguments).url;
    console.log("Totoro opening website:", `"${url}"`);

    await $`xdg-open ${url}`.quiet();

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: "Danke! Webseite geöffnet.",
            tool_call_id: data.id,
          },
        ],
      }),
    );
  } else if (data.function.name === "confluence") {
    const query = encodeURIComponent(JSON.parse(data.function.arguments).query);

    await $`xdg-open "https://tgipm.informatik.uni-hamburg.de/confluence/dosearchsite.action?cql=siteSearch+~+%22${query}%22+and+type+in+(%22space%22%2C%22user%22%2C%22com.atlassian.confluence.plugins.confluence-questions%3Aquestion%22%2C%22com.atlassian.confluence.extra.team-calendars%3Acalendar-content-type%22%2C%22com.atlassian.confluence.plugins.confluence-questions%3Aanswer%22%2C%22attachment%22%2C%22page%22%2C%22com.atlassian.confluence.extra.team-calendars%3Aspace-calendars-view-content-type%22%2C%22blogpost%22)&queryString=${query}"`.quiet();

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: "Thanks! Confluence search opened on my PC.",
            tool_call_id: data.id,
          },
        ],
      }),
    );
  } else if (data.function.name === "speichern") {
    const note_title: string = JSON.parse(data.function.arguments).titel;
    const content: string = JSON.parse(data.function.arguments).inhalt;
    const tags: string[] = JSON.parse(data.function.arguments).tags;
    let relative_date: number = JSON.parse(data.function.arguments)?.datum || 0;

    // Log the parsed data
    // console.log("Parsed Data:", { note_title, content, tags });

    let date = new Date();
    date.setDate(new Date().getDate() + relative_date);

    // Format: YYYY-MM-DD
    const noteTitle = "Journal/" + date.toISOString().split("T")[0] + ".md";
    // console.log("Generated Note Title:", noteTitle);

    let formattedTags = "";

    // Format tags as Markdown hashtags
    if (tags.length > 0) {
      formattedTags = `${tags.map((tag) => `[[${tag}]]`).join(", ")}`;
      // console.log("Formatted Tags:", formattedTags);
    }

    console.log(note_title);
    console.log(noteTitle);

    const metadata =
      [
        `# Gespeichert: ${note_title}`,
        `- **Tags:** ${formattedTags ? `${formattedTags}` : "No Tags"}`,
        `- **Erstellt von einem [[Large Language Model]]**`,
        `- **Eingabe: "${PROMPT}"**`,
      ].join("\n") + "\n\n";

    console.log("Generated Metadata:", metadata);

    const doesNoteExist =
      await $`ls ~/Documents/Marius\'\ Remote\ Vault/ | grep ${noteTitle}`.quiet();

    // console.log("Does Note Exist:", doesNoteExist.stdout ? "Yes" : "No");

    if (!doesNoteExist.stdout) {
      console.log("Creating a new note...");
      await $`touch ~/Documents/Marius\'\ Remote\ Vault/${noteTitle}`;
    }

    console.log("Note creation/check completed. Preparing to save content...");

    handleMessage(
      client.beta.threads.runs.submitToolOutputsStream(thread_id, run.id, {
        tool_outputs: [
          {
            output: "Thanks! Note saved in Obsidian.",
            tool_call_id: data.id,
          },
        ],
      }),
      async (message) => {
        console.log("Tool output submitted. Message:", message);

        const gptResponse = message
          ? [`\n## Totoro's Take`, `${message}`].join("\n")
          : "";

        console.log("Generated GPT Response:", gptResponse);

        // Include tags and message content in the note
        const noteContent = `${content}${gptResponse}`;

        console.log("Final Note Content:", noteContent);

        await $`echo "${metadata}${noteContent}" >> ~/Documents/Marius\'\ Remote\ Vault/${noteTitle}`;
        console.log(`Totoro: "${message}"`);
      },
    );
  } else {
    console.log(data.function.name);
    console.error("Tool call is not recognized");
    process.exit(1);
  }
});

handleMessage(stream);

// await client.beta.threads.runs.poll(thread.id, run.id);

// const lastMessage = await client.beta.threads.messages.list(thread.id);

// if (lastMessage.data[0].content[0].type === "text") {
//   console.log(lastMessage.data[0].content[0].text.value);
// } else {
//   console.log("Error getting response text", lastMessage);
// }
