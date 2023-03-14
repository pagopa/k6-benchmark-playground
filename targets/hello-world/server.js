const http = require('http');

const port = process.env.port || 8080

http.createServer(function (_, res) {
  res.write('Hello World!'); 
  res.end();
}).listen(port);

console.log(`Hello World from port ${port}!`);
