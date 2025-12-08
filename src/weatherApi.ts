const BASE = "https://jsonplaceholder.typicode.com/posts";

export const getWeather = async (city: string) => {
  const res = await fetch(`${BASE}/1`);
  return res.json();
};

export const saveFavorite = async (city: string) => {
  const res = await fetch(BASE, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ city })
  });
  return res.json();
};

export const updatePrefs = async (id: number, city: string) => {
  const res = await fetch(`${BASE}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ city })
  });
  return res.json();
};
