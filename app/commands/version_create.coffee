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
    ASQ(@generateNewVersionId)
      .then(@tryToSave)
      .val((version) -> done(version))
      .or((err) -> done(err))

  generateNewVersionId: (done) =>
    Version.generateNewVersionNumber(@data.container_id, done)


  tryToSave: (done, version_number) =>
    v = new Version(@data)
    v.version_number = version_number

    v.save((err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot save version to database')
        )

      done(version)
    )


module.exports = CreateVersionCommand
