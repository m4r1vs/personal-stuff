const https = require("https")

const API_KEY = require("./owm_api_key.js").key

const URL = `https://api.openweathermap.org/data/2.5/weather?lat=53.5510846&lon=9.99368179999999&units=metric&appid=` + API_KEY

const ICON_COLOR = "#EE8000"

const colorize = icon => `%{F${ICON_COLOR}}${icon}%{F-} `

const randomize = icons => {
  return icons[Math.round(Math.random() * (icons.length - 1))]
}

const request = https.request(URL, response => {
  let data = ""

  response.on("data", chunk => {
    data += chunk.toString()
  })

  response.on("end", () => {
    const body = JSON.parse(data)

    let weatherDescription = body.weather[0].description + ","

    const now = new Date().getTime() / 1000
    let isNight = true

    if (now > body.sys.sunrise && now < body.sys.sunset) {
      isNight = false
    }

    switch (body.weather[0].description) {
      case "clear sky":
        weatherDescription = colorize(isNight ? randomize(["", ""]) : "")
      case "light rain":
        weatherDescription = colorize(isNight ? "" : "")
      case "broken clouds":
        weatherDescription = colorize(isNight ? "" : "")
    }

    console.log(`${weatherDescription} ${body.main.temp}°C`)
  })
})

request.on("error", error => {
  throw new Error(error)
})

request.end()
