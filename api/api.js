var jsonServer = require('json-server')

var server = jsonServer.create()

server.use(jsonServer.defaults())

var router = jsonServer.router('api/db.json')
server.use(router)

console.log('Listening at 5000')
server.listen(5000)
