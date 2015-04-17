Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')

ASQ = require('asynquence')
Server = require('../api/server')

class VersionListCommand
  constructor: (@data) ->
    Joi.assert(
      @data.container_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@checkObjectIdFormat)
      .then(@checkContainerAndAuthId)
      .then(@tryToGetList)
      .then(@buildList)
      .val((storage) -> done(null, storage.light_list))
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    valid = true
    _.each(['container_id'], (key) ->
      unless /^[0-9a-fA-F]{24}$/.test(storage.data[key])
        valid = false
        return false
    )

    unless valid
      return done.fail(Boom.badRequest('Wrong Id Format'))

    done(storage)

  checkContainerAndAuthId: (done, storage) =>
    data = {
      _id: storage.data.container_id
    }

    Container.findOne(data, @onContainerFind(done, storage))

  onContainerFind: (done, storage) =>
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !container
        return done.fail(
          Boom.notFound('Container not found')
        )

      if storage.data.user_id != container.user_id
        return done.fail(
          Boom.unauthorized('Not authorized to add tags on this container')
        )

      done(storage)

  tryToGetList: (done, storage) =>
    data = {
      container_id: storage.data.container_id,
      user_id: storage.data.user_id,
    }

    Version.find(data).sort({version_number : 'descending'})
      .exec(@onGetList(done, storage))

  onGetList: (done, storage) =>
    (err, list) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Cannot connect to database'))

      storage.list = list
      done(storage)

  buildList: (done, storage) ->
    result = {
      items: [],
      count: storage.list.length
    }
    storage.list.forEach((item) ->
      s = item.toSwaggerFormat()

      result_item = {
        id: s.id
        container_id: s.container_id
        status: s.status
        version_number: s.version_number
        created_at: s.created_at
      }
      result_item.published_at =  s.published_at if (s.published_at)

      result.items.push(result_item)
    )

    storage.light_list = result
    done(storage)

module.exports = VersionListCommand
