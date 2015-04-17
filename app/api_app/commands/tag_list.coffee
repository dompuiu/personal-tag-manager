Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')
Tag = require('../models/tag')

ASQ = require('asynquence')
Server = require('../api/server')

class TagListCommand
  constructor: (@data) ->
    Joi.assert(
      @data.container_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.version_id,
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
      .then(@checkVersionId)
      .then(@tryToGetList)
      .then(@buildLightList)
      .val((storage) -> done(null, storage.light_list))
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    valid = true
    _.each(['container_id', 'version_id'], (key) ->
      unless /^[0-9a-fA-F]{24}$/.test(storage.data[key])
        valid = false
        return false
    )

    unless valid
      return done.fail(Boom.badRequest('Wrong Id Format'))

    done(storage)

  checkVersionId: (done, storage) =>
    data = {
      _id: storage.data.version_id
      container_id: storage.data.container_id
    }

    Version.findOne(data, @onVersionFind(done, storage))

  onVersionFind: (done, storage) =>
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !version
        return done.fail(
          Boom.notFound('Version not found')
        )

      if storage.data.user_id != version.user_id
        return done.fail(
          Boom.unauthorized('Not authorized to add tags on this version')
        )

      done(storage)

  tryToGetList: (done, storage) =>
    data = {
      container_id: storage.data.container_id,
      version_id: storage.data.version_id,
      user_id: storage.data.user_id,
    }
    Tag.find(data, @onGetList(done, storage))

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
        container_id: s.container_id
        version_id: s.version_id
        name: s.name
        type: s.type
        updated_at: s.updated_at
      })
    )

    storage.light_list = result
    done(storage)

module.exports = TagListCommand
