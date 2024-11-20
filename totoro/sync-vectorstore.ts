import { $ } from "bun";
import fs from "fs";
import OpenAI from "openai";
import type { VectorStoreFilesPage } from "openai/resources/beta/vector-stores/files.mjs";

// const createReadStreamForAll = (path: string) => {
//   const streams = files.map((file) => fs.createReadStream(`${path}/${file}`));
//   console.log("Uploading: ", files);
//   return {
//     files: streams,
//     fileIds: files,
//   };
// };

const syncVectorStore = async () => {
  const OPEN_AI_API_KEY = await $`secret-tool lookup openai password`
    .quiet()
    .text();
  const STORE_ID = "vs_mJw1qyw9a0byhJwbnMjpViDo";

  const client = new OpenAI({
    apiKey: OPEN_AI_API_KEY,
  });

  const DELTE_ALL_ALL = () => {
    client.files.list().then((files) => {
      files.data.forEach((file) => {
        client.files.del(file.id);
      });
    });

    return;
  };

  type FileOnDisk = {
    name: string;
    stream: fs.ReadStream;
  };

  const filesOnDisk: FileOnDisk[] = fs
    .readdirSync("/home/mn/Documents/Marius' Remote Vault/Journal/")
    .filter((fileName) => {
      // Check if the file is not empty
      const filePath = `/home/mn/Documents/Marius' Remote Vault/Journal/${fileName}`;
      return fs.statSync(filePath).size > 0;
    })
    .map((fileName) => {
      const filePath = `/home/mn/Documents/Marius' Remote Vault/Journal/${fileName}`;
      return {
        name: fileName,
        stream: fs.createReadStream(filePath),
      };
    });

  const deleteAllFiles = async (vectorStoreFilePage: VectorStoreFilesPage) => {
    const deletePromises: Promise<void>[] = [];

    vectorStoreFilePage.data.forEach((vectorStoreFile) => {
      const deletePromise = async () => {
        await client.files.del(vectorStoreFile.id);
        console.log("Deleted: ", vectorStoreFile.id);
      };
      deletePromises.push(deletePromise());
    });

    await Promise.all(deletePromises);

    if (vectorStoreFilePage.hasNextPage()) {
      const nextPage = await vectorStoreFilePage.getNextPage();
      await deleteAllFiles(nextPage);
    }
  };

  const deleteAllFilesFromStore = async () => {
    const initialPage = await client.beta.vectorStores.files.list(STORE_ID);
    await deleteAllFiles(initialPage);
    console.log("All files have been deleted.");
  };

  await deleteAllFilesFromStore();

  console.log("Continuing with further logic...");

  await client.beta.vectorStores.fileBatches.uploadAndPoll(STORE_ID, {
    files: filesOnDisk.map((f) => f.stream),
  });

  console.log("Synced vector store with all files in Journal");
};

const connectedToTheWWW = !!(await require("dns")
  .promises.resolve("google.com")
  .catch(() => {}));
if (connectedToTheWWW) {
  syncVectorStore();
} else {
  console.log("No internet connection.");
}
