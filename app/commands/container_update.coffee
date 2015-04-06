Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')
Server = require('../api/server')

mongoose = require('mongoose')
ObjectId = mongoose.Types.ObjectId

class UpdateContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.id,
      Joi.string().required()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.name,
      Joi.string().required().regex(/^[A-Za-z0-9 -]+$/).min(5)
    )

    @server = Server.get()

  run: (done) ->
    ASQ(@findById.bind(this))
      .then(@checkUserId.bind(this))
      .then(@tryToUpdate.bind(this))
      .val((container) -> done(container.toSwaggerFormat()))
      .or((err) -> done(err))

  findById: (done) ->
    try
      id = new ObjectId(@data.id)
    catch
      done.fail(Boom.badRequest('Wrong Id Format'))

    Container.findOne(id, (err, container) ->
      if err
        server.log(['error', 'database'], err)
        done.fail(Boom.badImplementation('Database error'))

      if !container
        done.fail(Boom.notFound('Container not found'))

      done(container)
    )

  checkUserId: (done, container) ->
    if container.user_id != @data.user_id
      done.fail(Boom.unauthorized('Not authorized to delete this container'))

    done(container)

  tryToUpdate: (done, container) ->
    container.name = @data.name
    container.save((err, container) ->
      if (err)
        console.log(err)
        server.log(['error', 'database'], err)
        done.fail(Boom.badImplementation('Database error'))

      done(container)
    )

module.exports = UpdateContainerCommand
