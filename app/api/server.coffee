'use strict'

Hapi = require('hapi')
fs = require('fs')
ASQ = require('asynquence')
Database = require('../database/connection')

Server = {
  server: null

  start: (done) ->
    server = @get()
    @bindRoutes(server)

    if !module.parent
      server.start()

  get: ->
    server = @server or @create()
    return server

  bindRoutes: (server) ->
    fs.readdirSync(__dirname + '/routes').forEach((file) ->
      if !/(\.js|\.coffee)$/.test(file)
        return

      name = file.substr(0, file.indexOf('.'))
      server.route(require(__dirname + '/routes/' + name))
    )

  create: ->
    host = process.env.HOST || 'localhost'
    port = process.env.PORT || 8000

    server = new Hapi.Server()
    server.connection({
      host: host
      port: port
    })

    require('./middleware/auth').register(server)
    require('./middleware/swagger')(server)

    return server
}

ASQ(Database.openConnection.bind(Database))
  .then(Server.start.bind(Server))

module.exports = Server
