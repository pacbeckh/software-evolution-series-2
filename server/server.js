var express = require('express');
var app = express();
var fs = require('fs');

app.use(express.static('public'));
app.use('/data/files', express.static('data/files'));

app.get('/hello', function (req, res) {
  res.send('Hello World!');
});


var loadFilesInDir = function (path) {
  console.log("BEFORE");
  var files = fs.readdirSync('./data/files/' + path);
  return files.filter(function (f) {
    return !f.match(/^\./)
  }).map(function (f) {
    var stat = fs.statSync('./data/files/' + path + "/" + f);
    var children = [];
    if (stat.isDirectory()) {
      children = loadFilesInDir(path + "/" + f);
    }
    return {
      name: f,
      path: path + "/" + f,
      children: children
    };
  })
};

app.get('/files', function (req, res) {
  try {
    var r = loadFilesInDir('.');
    res.json(r);
  } catch (e) {
    console.log(e);
    //NO CARE
    res.send('Hello World!');
  }
});

app.get('/file', function (req, res) {
  //var content = ;
  //console.log(content);
  res.send(fs.readFileSync('./data/files/' + req.query.path));
});


var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});
