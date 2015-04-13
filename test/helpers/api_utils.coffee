Database = require('../../app/api_app/database/connection')
ASQ = require('asynquence')
_ = require('lodash')
faker = require('faker')

Container = require('../../app/api_app/models/container')
Version = require('../../app/api_app/models/version')
Tag = require('../../app/api_app/models/tag')
User = require('../../app/api_app/models/user')

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
        TestServers.server.route(storage.routes)
        TestServers.routes.push(storage.routes)

      return done(storage)

    Server = require('../../app/api_app/api/server')
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

  configureServerAndMakeRequest: (done, storage) ->
    ASQ(storage)
      .then(module.exports.configureServer)
      .then(module.exports.makeRequest)
      .val((storage) -> done(storage))

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

  createVersion:
    (data = {}, from_storage = 'container', storage_name = 'version') ->
      (done, storage) ->
        data = {
          version_number: data.version_number || 1
          container_id: storage[from_storage]._id
          user_id: storage[from_storage].user_id
          status: data.status || ''
        }

        v = new Version(data)
        v.save((err, version) ->
          if err
            done.fail(err)
          else
            storage[storage_name] = version
            done(storage)
        )

  createTag:
    (data = {}, from_storage = 'version', storage_name = 'tag') ->
      (done, storage) ->
        data = {
          name: data.name || faker.name.firstName()
          dom_id: data.dom_id || faker.internet.userName()
          type: data.type || 'html'
          src: data.src || '<div>some html code</div>'
          on_load: data.onload || 'console.log("JS")'
          container_id: storage[from_storage].container_id
          version_id: storage[from_storage]._id
          user_id: storage[from_storage].user_id
          created_at: data.created_at || new Date()
          updated_at: data.updated_at || new Date()
        }

        t = new Tag(data)
        t.save((err, tag) ->
          if err
            done.fail(err)
          else
            storage[storage_name] = tag
            done(storage)
        )

  createUser: (data = {}, storage_name = 'user') ->
      (done, storage) ->
        data = _.merge({
          name: faker.name.findName()
          email: faker.internet.email()
          password: User.makePassword(faker.internet.password())
        }, data)

        u = new User(data)
        u.save((err, user) ->
          if err
            done.fail(err)
          else
            storage[storage_name] = user
            done(storage)
        )
}
