Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')
Tag = require('../models/tag')

ASQ = require('asynquence')
Server = require('../api/server')

class DeleteTagCommand
  constructor: (@data) ->
    Joi.assert(
      @data.id,
      Joi.string().required()
    )

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
      .then(@tryToDelete)
      .val(->
        done(
          null,
          {result: true, message: 'Tag was successfully deleted'}
        )
      )
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    valid = true
    _.each(['id', 'container_id', 'version_id'], (key) ->
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

      if storage.data.user_id != version.user_id \
      || 'now editing' != version.status
        return done.fail(
          Boom.unauthorized('Not authorized to delete tags on this version')
        )

      done(storage)

  tryToDelete: (done, storage) =>
    Tag.remove({
      _id: storage.data.id,
      container_id: storage.data.container_id,
      version_id: storage.data.version_id,
      user_id: storage.data.user_id,
    }, @onDelete(done, storage))

  onDelete: (done, storage) ->
    (err, response) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot delete tag from database')
        )

      if response.result.n == 0
        return done.fail(Boom.notFound('Tag not found'))

      done(storage)

module.exports = DeleteTagCommand
