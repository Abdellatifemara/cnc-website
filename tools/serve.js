// Minimal static server WITH Range support (video seeking needs it).
const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = '/home/abdellatif/Desktop/caironews/site';
const TYPES = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.mp4': 'video/mp4', '.jpg': 'image/jpeg', '.png': 'image/png', '.woff2': 'font/woff2', '.gif': 'image/gif', '.md': 'text/plain' };

http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/index.html';
  let file = path.join(ROOT, p);
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  if (!fs.existsSync(file) && fs.existsSync(file + '.html')) file = file + '.html';
  if (!file.startsWith(ROOT) || !fs.existsSync(file)) {
    res.writeHead(404); res.end('404'); return;
  }
  const size = fs.statSync(file).size;
  const type = TYPES[path.extname(file)] || 'application/octet-stream';
  const range = req.headers.range;
  if (range) {
    const m = /bytes=(\d*)-(\d*)/.exec(range);
    const start = m[1] ? parseInt(m[1]) : 0;
    const end = m[2] ? parseInt(m[2]) : size - 1;
    res.writeHead(206, {
      'Content-Range': `bytes ${start}-${end}/${size}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': end - start + 1,
      'Content-Type': type
    });
    fs.createReadStream(file, { start, end }).pipe(res);
  } else {
    res.writeHead(200, { 'Content-Length': size, 'Content-Type': type, 'Accept-Ranges': 'bytes' });
    fs.createReadStream(file).pipe(res);
  }
}).listen(8742, '127.0.0.1', () => console.log('range server on 8742'));
