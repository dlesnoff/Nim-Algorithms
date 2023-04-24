import std/[httpclient, json, strutils, math]

type
  Unit = enum
    standard, metric, imperial

const
  appID = ""
  urlBase = "https://api.openweathermap.org/data/2.5/"
  defaultTown = "Chicago"
  defaultMetric = imperial

type
  Weather = object
    description: string
    metric: Unit
    temp: float
  
  Forecast = enum
    current, hourly, daily

proc requestWeather*(forecast: Forecast, town: string = defaultTown,
  appID: string = appID, metric: Unit = defaultMetric): string =

  let queryType = case forecast:
    of current: "weather"
    of hourly: "forecast"
    of daily: "forecast/daily"
  let url = urlBase & queryType & "?q=" & town & "&appid=" & appID & $metric
  var client = newHttpClient()
  result = client.getContent(url)

func kelvinToCelsius(k: float): float =
  k - 273.15

func kelvinToFahrenheit(k: float): float =
  (k - 273.15) * 9.0 / 5.0 + 32.0

func fetchDataFromJson(json: JsonNode): Weather =
  result.description = json["weather"][0]["description"].getStr
  result.tempKelvin = json["main"]["temp"].getFloat
  result.tempFahrenheit = kelvinToFahrenheit(result.tempKelvin)
  result.tempCelsius = kelvinToCelsius(result.tempKelvin)

when isMainModule:
  var town = ""
  while town == "" and town != "q":
    stdout.writeLine("""Enter a town ("q" to quit): """)
    town = readLine(stdin)
  if town == "q":
    quit(0)
  let weather = requestWeather(current, town)
  echo weather
  # let myJson = parseJson(weather)
  # let weatherObj = fetchDataFromJson(myJson)
  # echo "The weather in $1 is: $2" % [town, weatherObj.description]
  # echo "The temperature is: $1°K $2°F $3°C" % 
  #   [
  #   $(weatherObj.tempKelvin),
  #   $weatherObj.tempFahrenheit.round(2),
  #   $weatherObj.tempCelsius.round(2)
  #   ]
