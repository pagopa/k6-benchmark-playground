import http from "k6/http";
export const options = {
  vus: 10,
  duration: '30s',
};
export default function (data) {
  const res = http.get("http://localhost:8080");
  return res.status === 200;
}
