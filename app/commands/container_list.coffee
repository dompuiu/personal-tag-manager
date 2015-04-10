Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')
Server = require('../api/server')

class ContainersListCommand
  constructor: (@data) ->
    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    c = new Container(@data)
    c.generateStorageNamespace()

    ASQ({data: @data})
      .then(@tryToGetList)
      .then(@buildLightList)
      .val((storage) -> done(null, storage.light_list))
      .or((err) -> done(err, null))

  tryToGetList: (done, storage) =>
    data = {user_id: storage.data.user_id, deleted_at: {$exists: false}}
    Container.find(data, @onGetList(done, storage))

  onGetList: (done, storage) =>
    (err, list) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Cannot connect to database'))

      storage.list = list
      done(storage)

  buildLightList: (done, storage) ->
    result = {
      items: [],
      count: storage.list.length
    }
    storage.list.forEach((item) ->
      s = item.toSwaggerFormat()

      result.items.push({
        id: s.id
        name: s.name
      })
    )

    storage.light_list = result
    done(storage)

module.exports = ContainersListCommand
