var express = require('express'); 
var compression = require('compression');
var app = express();
app.use(express.static(__dirname + '/public'));
app.use(compression());
app.get('*',function(req,res,next){
  if (req.headers['x-forwarded-proto'] == 'https') {
    res.redirect('http://rocky-sea-8048.herokuapp.com'+req.url);
  }
});
app.listen(process.env.PORT || 3000);
