const https = require("https")

const API_KEY = require("./owm_api_key.js").key

const URL = `https://api.openweathermap.org/data/2.5/weather?lat=53.551086&lon=9.993682&units=metric&appid=` + API_KEY

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
        weatherDescription = colorize(isNight ? randomize(["", "", "󰖔"]) : "")
        break
      case "light rain":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "broken clouds":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "scattered clouds":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "light intensity drizzle rain":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "light intensity drizzle":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "light intensity shower rain":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "few clouds":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "overcast clouds":
        weatherDescription = colorize("")
        break
      case "fog":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "mist":
        weatherDescription = colorize(isNight ? "" : "")
        break
      case "moderate rain":
        weatherDescription = colorize("")
        break
      case "snow":
        weatherDescription = colorize("")
        break
      case "light snow":
        weatherDescription = colorize("󰼶")
        break
      case "shower rain":
        weatherDescription = colorize("")
        break
      case "thunderstorm with heavy rain":
        weatherDescription = colorize("")
        break
    }

    if (Math.floor(Math.random() * 10 ** 100) == 420) {
      weather = colorize("")
    }

    console.log(`${weatherDescription}${Math.round(body.main.feels_like)}°C`)
  })
})

request.on("error", error => {
  throw new Error(error)
})

request.end()
