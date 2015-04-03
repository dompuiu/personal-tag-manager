'use strict'

restify = require('restify')
ASQ = require('asynquence')
Database = require('../database/connection')

Server = {
  server: null

  start: (done) ->
    server = @get()
    @bindRoutes(server)

    server.listen(process.env.PORT || 8080, ->
      done()
      console.log('%s listening at %s', server.name, server.url)
    )

  get: ->
    server = @server or @create()
    return server

  bindRoutes: (server) ->
    server.get('/echo/:name', (req, res, next) ->
      res.send(req.params)
      next()
    )

  create: ->
    server = restify.createServer({
      name: 'PersonalTagManagerApp'
      version: '1.0.0'
    })

    server.use(restify.acceptParser(server.acceptable))
    server.use(restify.queryParser())
    server.use(restify.bodyParser())

    return server
}

ASQ(Database.openConnection.bind(Database))
  .then(Server.start.bind(Server))
  .or((err) ->
    console.log(err)
  )
