Database = require('../app/database/connection')
ASQ = require('asynquence')
Container = require('../app/models/container')
_ = require('lodash')
faker = require('faker')

class CollectionEmptyer
  constructor: (data, done) ->
    @data = data
    @done = done

  dropAll: (done) ->
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


module.exports = {
  emptyColection: (collection, done) ->
    collection.find((err, items) ->
      throw new Error(err) if err
      new CollectionEmptyer(items, done).dropAll()
    )

  configureServer: (routes) ->
    (done) ->
      Server = require('../app/api/server')
      server = Server.get()
      server.route(routes)

      done(server)

  makeRequest: (config) ->
    (done, server) ->
      server.inject(config, (response) ->
        done(server, response)
      )

  createContainer: (container = {}) ->
    data = _.merge({
      name: faker.name.findName()
      domain: faker.internet.domainName()
      user_id: faker.helpers.randomNumber(10)
      storage_namespace: faker.lorem.sentence()
    }, container)

    (done) ->
      c = new Container(data)
      c.save((err, container) ->
        done.fail(err) if err
        done(container))
}
