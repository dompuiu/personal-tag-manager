Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')
Server = require('../api/server')

mongoose = require('mongoose')
ObjectId = mongoose.Types.ObjectId

class DeleteContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.id,
      Joi.string().required()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@findById)
      .then(@checkUserId)
      .then(@tryToDelete)
      .val(->
        done(
          null,
          {result: true, message: 'Container was successfully deleted'}
        )
      )
      .or((err) -> done(err, null))

  findById: (done, storage) =>
    Container.findOne(
      {_id: storage.data.id, deleted_at: {$exists: false}},
      @onFind(done, storage)
    )

  onFind: (done, storage) =>
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        if err.name == 'CastError' && err.kind = 'ObjectId'
          return done.fail(Boom.badRequest('Wrong Id Format'))
        else
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

  tryToDelete: (done, storage) =>
    storage.container.deleted_at = new Date()
    storage.container.save(@onDelete(done, storage))

  onDelete: (done, storage) =>
    (err) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      done(storage)

module.exports = DeleteContainerCommand
