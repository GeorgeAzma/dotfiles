#!/bin/bash

# TODO: 
# - air quality index
# - UV index

API_KEY="13dd238e71d34172f8ff971a90d8f80c"
CITY="Kojori,Tbilisi"
response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=metric")

icon_code=$(echo "$response" | jq -r '.weather[0].icon')
temperature=$(echo "$response" | jq -r '.main.temp')
feels_like=$(echo "$response" | jq -r '.main.feels_like')
humidity=$(echo "$response" | jq -r '.main.humidity')
wind_speed=$(echo "$response" | jq -r '.wind.speed')
ground_pressure=$(echo "$response" | jq -r '.main.grnd_level')
wind_speed=$(echo "$response" | jq -r '.wind.speed')
clouds=$(echo "$response" | jq -r '.clouds.all')
name=$(echo "$response" | jq -r '.name')
lat=$(echo "$response" | jq -r '.coord.lat')
lon=$(echo "$response" | jq -r '.coord.lon')

visibility=$(echo "$response" | jq -r '.visibility')

if [ "$visibility" -ge 1000 ]; then
  # Round to nearest integer km without decimal
  visibility_km=$(awk "BEGIN {printf \"%.0f\", $visibility/1000}")
  visibility="${visibility_km} km"
else
  visibility="${visibility} m"
fi

visibility=$(echo "$response" | jq -r '.visibility')
if [ "$visibility" -ge 1000 ]; then
  visibility_km=$(awk "BEGIN {printf \"%.0f\", $visibility/1000}")
  visibility="${visibility_km}km"
else
  visibility="${visibility}m"
fi


precipitation="N/A"  # OpenWeatherMap's current weather API doesn't always return precipitation; you can parse rain or snow if present:
rain=$(echo "$response" | jq -r '.rain["1h"] // empty')
snow=$(echo "$response" | jq -r '.snow["1h"] // empty')
if [ -n "$rain" ]; then
  precipitation="${rain}mm rain"
elif [ -n "$snow" ]; then
  precipitation="${snow}mm snow"
else
  precipitation="0mm"
fi

sun=$(sun $lat $lon waybar)

tooltip="$temperature°C ($feels_like°C) $humidity%\n$precipitation ${wind_speed}m/s ${ground_pressure}hPa\n$visibility, $clouds% cloudy\n$name @$lat,$lon\n\n$sun"

case "$icon_code" in
  "01d") icon="☀️" ;;       # clear sky day
  "01n") icon="🌙" ;;       # clear sky night
  "02d") icon="🌤️" ;;       # few clouds day
  "02n") icon="🌤️" ;;       # few clouds night (no distinct emoji)
  "03d"|"03n") icon="☁️" ;; # scattered clouds
  "04d"|"04n") icon="☁️" ;; # broken clouds
  "09d"|"09n") icon="🌧️" ;; # shower rain
  "10d"|"10n") icon="🌦️" ;; # rain
  "11d"|"11n") icon="⛈️" ;; # thunderstorm
  "13d"|"13n") icon="❄️" ;; # snow
  "50d"|"50n") icon="🌫️" ;; # mist
  *) icon="❓" ;;
esac

echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\"}"
