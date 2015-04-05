Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')

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

  run: (done) ->
    c = new Container(@data)
    c.generateStorageNamespace()

    ASQ(@checkNameIsUnique(c, @data))
      .then(@tryToSave.bind(this))
      .val((container) -> done(container.toSwaggerFormat()))
      .or((err) ->
        if err == 'Duplicate'
          e = Boom.create(409, 'A container with the same name already exists')
          done(e)
        else
          throw new Error(err))

  checkNameIsUnique: (container, data) ->
    (done) ->
      Container.count(data, (err, count) ->
        if err
          server.log(['error', 'database'], err)
          done.fail('Database error')

        done.fail('Duplicate') if count > 0
        done(container)
      )

  tryToSave: (done, container) ->
    container.save((err, container) ->
      if (err)
        server.log(['error', 'database'], err)
        done.fail('Cannot save container to database')

      done(container)
    )


module.exports = CreateContainerCommand
