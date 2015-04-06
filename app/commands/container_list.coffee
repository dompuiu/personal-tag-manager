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

    @server = Server.get()

  run: (done) ->
    c = new Container(@data)
    c.generateStorageNamespace()

    ASQ(@tryToGetList.bind(this))
      .then(@buildLightList.bind(this))
      .val((list) -> done(list))
      .or((err) -> done(err))

  tryToGetList: (done) ->
    data = {user_id: @data.user_id, deleted_at: {$exists: false}}
    Container.find(data, (err, list) ->
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Cannot connect to database'))

      done(list)
    )

  buildLightList: (done, list) ->
    result = {
      items: [],
      count: list.length
    }
    list.forEach((item) ->
      s = item.toSwaggerFormat()

      result.items.push({
        id: s.id
        name: s.name
      })
    )

    done(result)

module.exports = ContainersListCommand
