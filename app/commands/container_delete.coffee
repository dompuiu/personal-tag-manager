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
    ASQ(@findById)
      .then(@checkUserId)
      .then(@tryToDelete)
      .val((container) ->
        done(
          null,
          {result: true, message: 'Container was successfully deleted'}
        )
      )
      .or((err) -> done(err, null))

  findById: (done) =>
    Container.findOne({
      _id: @data.id,
      deleted_at: {$exists: false}
    }, (err, container) =>

      if err
        @server.log(['error', 'database'], err)
        if err.name == 'CastError' && err.kind = 'ObjectId'
          return done.fail(Boom.badRequest('Wrong Id Format'))
        else
          return done.fail(Boom.badImplementation('Database error'))

      if !container
        return done.fail(Boom.notFound('Container not found'))

      done(container)
    )

  checkUserId: (done, container) =>
    if container.user_id != @data.user_id
      return done.fail(
        Boom.unauthorized('Not authorized to delete this container')
      )

    done(container)

  tryToDelete: (done, container) ->
    container.deleted_at = new Date()
    container.save((err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      done(container)
    )

module.exports = DeleteContainerCommand
