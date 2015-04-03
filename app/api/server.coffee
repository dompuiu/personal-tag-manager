'use strict'

restify = require('restify')
ASQ = require('asynquence')
mongoose = require('mongoose')

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

Database = {
  openConnection: (done) ->
    @connect()

    db = mongoose.connection
    db.once('open', ->
      console.log('Connected to Mongo.')
      done()
    )

  connect: ->
    mongoose.connect('mongodb://localhost/test')
}

ASQ(Database.openConnection.bind(Database)).then(Server.start.bind(Server))
