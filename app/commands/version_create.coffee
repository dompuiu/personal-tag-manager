Joi = require('joi')

Boom = require('boom')
Version = require('../models/version')
ASQ = require('asynquence')
Server = require('../api/server')

class CreateVersionCommand
  constructor: (@data) ->
    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.container_id.toString(),
      Joi.string().required().regex(/^[0-9a-fA-F]{24}$/)
    )

    Joi.assert(
      @data.status,
      Joi.string().valid('published', 'now editing', 'archived').required()
    )

    @server = Server.get()

  run: (done) ->
    ASQ({data: @data})
      .then(@generateNewVersionId)
      .then(@tryToSave)
      .val((version) -> done(null, version))
      .or((err) -> done(err, null))

  generateNewVersionId: (done, storage) =>
    Version.generateNewVersionNumber(
      storage.data.container_id,
      @onGeneratedVersionNumber(done, storage)
    )

  onGeneratedVersionNumber: (done, storage) ->
    (err, version_number) ->
      if err
        done.fail(err)
      else
        storage.version_number = version_number
        done(storage)

  tryToSave: (done, storage) =>
    v = new Version(@data)
    v.version_number = storage.version_number

    v.save(@onSave(done, storage))

  onSave: (done, storage) ->
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot save version to database')
        )

      storage.version = version
      done(storage)

module.exports = CreateVersionCommand
