Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
ASQ = require('asynquence')

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

  run: (done) ->
    ASQ(@findById.bind(this))
      .then(@checkUserId.bind(this))
      .then(@tryToDelete.bind(this))
      .val((container) ->
        done({result: true, message: 'Container was successfully deleted'})
      )
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

  tryToDelete: (done, container) ->
    container.remove((err) ->
      if (err)
        server.log(['error', 'database'], err)
        done.fail(Boom.badImplementation('Database error'))

      done(container)
    )

module.exports = DeleteContainerCommand
