const https = require("https")
const fs = require("fs")

const URL_FILE_PATH = "/home/mn/.config/newsboat/urls"
const url = process.argv.slice(2)[0]

const addIDtoRSSfile = id => {

  const ytRSSurl = "https://www.youtube.com/feeds/videos.xml?channel_id=" + id
  fs.appendFile(URL_FILE_PATH, ytRSSurl + "\n", error => {
    if (error) {
      console.error(`Error adding ID ${id} to ${URL_FILE_PATH}:`)
      console.error(error)
    } else {
      console.log(`Added ID ${id} to ${URL_FILE_PATH} :)`)
    }
  })

}

const parseHTML = html => {
  let htmlSplit = html.split(`<meta itemprop="channelId" content="`)[1]
  htmlSplit = htmlSplit.split(`"`)[0]
  addIDtoRSSfile(htmlSplit)
}

const request = https.request(url, response => {
  let data = ""

  response.on("data", chunk => {
    data += chunk.toString()
  })

  response.on("end", () => {
    parseHTML(data)
  })
})

request.on("error", error => {
  console.error("Error during HTTPS Request:")
  console.error(error)
})

request.end()
