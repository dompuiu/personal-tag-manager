'use strict'

Hapi = require('hapi')
fs = require('fs')
ASQ = require('asynquence')
Database = require('../database/connection')

Bcrypt = require('bcrypt')
Basic = require('hapi-auth-basic')

Server = {
  server: null

  start: (done) ->
    server = @get()
    @bindRoutes(server)

    server.start()

  get: ->
    server = @server or @create()
    return server

  bindRoutes: (server) ->
    fs.readdirSync(__dirname + '/routes').forEach((file) ->
      return if /\.js$/.test(file)

      name = file.substr(0, file.indexOf('.'))
      require('./routes/' + name)(server)
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
  .or((err) ->
    console.log(err)
  )
