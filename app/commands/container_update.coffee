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
      @data.domain,
      Joi.string().hostname()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.name,
      Joi.string().regex(/^[A-Za-z0-9 -\.]+$/).min(5)
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@findById)
      .then(@checkUserId)
      .then(@tryToUpdate)
      .val((storage) -> done(null, storage.container.toSwaggerFormat()))
      .or((err) -> done(err, null))

  findById: (done, storage) =>
    Container.findOne(
      {_id: storage.data.id, deleted_at: {$exists: false}},
      @onFind(done, storage)
    )

  onFind: (done, storage) =>
    (err, container) =>
      if err
        if err.name == 'CastError' && err.kind = 'ObjectId'
          return done.fail(Boom.badRequest('Wrong Id Format'))
        else
          @server.log(['error', 'database'], err)
          return done.fail(Boom.badImplementation('Database error'))

      if !container
        return done.fail(Boom.notFound('Container not found'))

      storage.container = container
      done(storage)

  checkUserId: (done, storage) ->
    if storage.container.user_id != storage.data.user_id
      return done.fail(
        Boom.unauthorized('Not authorized to delete this container')
      )

    done(storage)

  tryToUpdate: (done, storage) =>
    storage.container.name = storage.data.name if storage.data.name
    storage.container.domain = storage.data.domain if storage.data.domain
    storage.container.updated_at = new Date()

    storage.container.save(@onUpdate(done, storage))

  onUpdate: (done, storage) =>
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      done(storage)

module.exports = UpdateContainerCommand
