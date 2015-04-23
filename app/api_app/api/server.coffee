'use strict'

Hapi = require('hapi')
fs = require('fs')
ASQ = require('asynquence')
Database = require('../database/connection')

Server = {
  server: null

  build: (done) ->
    ASQ({})
      .then(@create.bind(this))
      .val((storage) -> done(storage.server))
      .or((err) -> done(err))

  init: (done) ->
    return if module.parent

    ASQ({})
      .then(@get.bind(this))
      .then(@bindRoutes.bind(this))
      .then(@start.bind(this))
      .val((storage) -> done(storage.server))
      .or((err) -> done(err))

  get: (done, storage) ->
    if @server
      return done(@server)

    @create(done, storage)

  bindRoutes: (done, storage) ->
    fs.readdirSync(__dirname + '/routes').forEach((file) ->
      if !/(\.js|\.coffee)$/.test(file)
        return

      name = file.substr(0, file.indexOf('.'))
      storage.server.route(require(__dirname + '/routes/' + name))
    )
    done(storage)

  start: (done, storage) ->
    storage.server.start()
    done(storage)

  create: (done, storage) ->
    host = process.env.HOST || '0.0.0.0'
    port = process.env.PORT || 8000

    server = new Hapi.Server({
      connections: {
        routes: {cors: true}
      }
    })

    server.connection({
      host: host
      port: port
    })

    ASQ({server: server})
      .then(require('./middleware/log').register)
      .then(require('./middleware/auth').register)
      .then(require('./middleware/swagger').register)
      .val((inner_storage) =>
        storage.server = @server = server
        done(storage)
      )
      .or((err) -> done.fail(err))
}

ASQ(Database.openConnection.bind(Database))
  .then(Server.init.bind(Server))

module.exports = Server
