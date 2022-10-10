const fs = require("fs")
const path = require("path")

const settingsPath = "/mnt/c/Users/mniveri/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
const hxsettingsPath = "/home/marius/.config/helix/config.toml"

let settings = {}

fs.readFile(hxsettingsPath, { encoding: "utf-8" }, (err, data) => {
  if (err) return console.error(err)
  
  const pos = data.search("autumn_night")
  let newSettings = ""
  if (pos > 0) {
    newSettings = data.replace("autumn_night", "emacs")
  } else {
    newSettings = data.replace("emacs", "autumn_night")
  }
  fs.writeFile(hxsettingsPath, newSettings, (err) => {
    if (err) console.error(err)
  })
})

fs.readFile(settingsPath, { encoding: "utf-8" }, (err, data) => {
  if (err) return console.error(err)
  settings = JSON.parse(data)
  
  settings.profiles.list.forEach(profile => {
    if (profile.name == "Arch Linux") {
      if (profile.colorScheme == "Campbell") {
        profile.colorScheme = "Tango Light"
        profile.backgroundImage = null
      } else {
        profile.colorScheme = "Campbell"
        profile.backgroundImage = "C:\\Users\\mniveri\\OneDrive - Axel Springer SE\\Bilder\\BLACK.png"
      }
    }
  })
  
  fs.writeFile(settingsPath, JSON.stringify(settings), (err) => {
    if (err) console.error(err)
  })
  // console.log(settings.profiles)
})

console.log("✨🎉🎇 FARBEN ✨🎉🎇")
