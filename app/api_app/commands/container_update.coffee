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
      .then(@checkObjectIdFormat)
      .then(@checkNameIsUnique)
      .then(@findById)
      .then(@checkUserId)
      .then(@tryToUpdate)
      .val((storage) -> done(null, storage.container.toSwaggerFormat()))
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    unless /^[0-9a-fA-F]{24}$/.test(storage.data.id)
      return done.fail(Boom.badRequest('Wrong Id Format'))

    done(storage)

  checkNameIsUnique: (done, storage) =>
    data = {
      _id: {$ne: storage.data.id}
      name: storage.data.name
      user_id: storage.data.user_id
      deleted_at: {$exists: false}
    }
    Container.count(data, @onCount(done, storage))

  onCount: (done, storage) ->
    (err, count) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if count > 0
        return done.fail(
          Boom.conflict('A container with the same name already exists')
        )

      done(storage)

  findById: (done, storage) =>
    Container.findOne(
      {_id: storage.data.id, deleted_at: {$exists: false}},
      @onFind(done, storage)
    )

  onFind: (done, storage) =>
    (err, container) =>
      if err
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

      storage.container = container
      done(storage)

module.exports = UpdateContainerCommand
