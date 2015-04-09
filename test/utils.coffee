Database = require('../app/database/connection')
ASQ = require('asynquence')
Container = require('../app/models/container')
Version = require('../app/models/version')
_ = require('lodash')
faker = require('faker')

class CollectionEmptyer
  constructor: (data, done) ->
    @data = data
    @done = done

  dropAll: ->
    Database.openConnection((connection) =>
      segments = @data.map(@deleteItem)

      ASQ()
        .all.apply(null, segments)
        .val(@operationResult.bind(this))
    )

  deleteItem: (item) ->
    return ASQ((done) ->
      item.remove((err) ->
        throw new Error(err) if err
        done()
      )
    )

  operationResult: ->
    @done()

TestServers = {
  server: null
  routes: []
  isRouteAdded: (routes) ->
    index = _.findIndex @routes, (r) ->
      return r == routes

    if index == -1 then false else true
}

module.exports = {
  emptyColection: (collection, done) ->
    collection.find((err, items) ->
      throw new Error(err) if err
      new CollectionEmptyer(items, done).dropAll()
    )

  configureServer: (done, storage) ->
    if (TestServers.server)
      storage.server = TestServers.server

      unless TestServers.isRouteAdded(storage.routes)
        server.route(storage.routes)

      return done(storage)

    Server = require('../app/api/server')
    Server.build (server) ->
      server.route(storage.routes)
      storage.server = server

      TestServers.routes.push(storage.routes)
      TestServers.server = server

      done(storage)

  makeRequest: (done, storage) ->
    storage.server.inject(storage.request, (response) ->
      storage.response = response
      done(storage)
    )

  createContainer: (data = {}, storage_name = 'container') ->
    data = _.merge({
      name: faker.name.findName()
      domain: faker.internet.domainName()
      user_id: faker.helpers.randomNumber(10)
      storage_namespace: faker.lorem.sentence()
    }, data)

    (done, storage) ->
      c = new Container(data)
      c.save((err, container) ->
        if err
          done.fail(err)
        else
          storage[storage_name] = container
          done(storage)
      )

  createVersion: (done, container) ->
    data = {
      version_number: 1
      container_id: container._id
      user_id: container.user_id
    }

    v = new Version(data)
    v.save((err, version) ->
      if err
        done.fail(err)
      else
        done(version)
    )
}
