import { WEATHER_API_KEY } from "@env";

const fetchWeather = async (city: string) => {
  const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${WEATHER_API_KEY}&units=metric`;

  const response = await fetch(url);
  const data = await response.json();

  if (data.cod !== 200) {
    throw new Error(data.message);
  }

  return data;
};
