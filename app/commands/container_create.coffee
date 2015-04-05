Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')
Server = require('../api/server')

class CreateContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.name,
      Joi.string().required().regex(/^[A-Za-z0-9 -]+$/).min(5)
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    @server = Server.get()

  run: (done) ->
    c = new Container(@data)
    c.generateStorageNamespace()

    ASQ(@checkNameIsUnique(c, @data))
      .then(@tryToSave.bind(this))
      .val((container) -> done(container.toSwaggerFormat()))
      .or((err) -> done(err))

  checkNameIsUnique: (container, data) ->
    (done) ->
      data.deleted_at = {$exists: false}
      Container.count(data, (err, count) ->
        if err
          @server.log(['error', 'database'], err)
          done.fail(Boom.badImplementation('Database error'))

        if count > 0
          done.fail(
            Boom.conflict('A container with the same name already exists')
          )

        done(container)
      )

  tryToSave: (done, container) ->
    container.save((err, container) ->
      if (err)
        @server.log(['error', 'database'], err)
        done.fail(Boom.badImplementation('Cannot save container to database'))

      done(container)
    )


module.exports = CreateContainerCommand
