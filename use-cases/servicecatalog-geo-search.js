import http from "k6/http";

export const options = {
  vus: 2000,
  duration: "30s",
  baseUrl: __ENV.BASE_URL,
};

// const url = "http://host.docker.internal:3001"
// const url = "https://io-d-servicecatalogbenchmark-app-service-docker.azurewebsites.net"

export function setup() {
  const url = `${options.baseUrl}/services?select=geo_ids->0`;
  const r= http.get(url);
  console.log('-->', url, r)
  const { body } = r
  const geo_ids = JSON.parse(body)
    .map(({ geo_ids }) => geo_ids)
    .splice(0, 10);
  return geo_ids
}

export default function (geo_ids) {

  const idx = Math.floor(Math.random() * geo_ids.length);
  const random_geo_id = geo_ids[idx];
  const url = `${options.baseUrl}/services?geo_ids=cs.{${random_geo_id}}`;

  http.get(url, {
    headers: {
      "Content-Type": "application/json",
    },
  });
}
