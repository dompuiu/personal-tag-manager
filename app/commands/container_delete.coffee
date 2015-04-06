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

    @server = Server.get()

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

    Container.findOne({
      _id: id,
      deleted_at: {$exists: false}
    }, (err, container) ->
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
    container.deleted_at = new Date()
    container.save((err, container) ->
      if (err)
        console.log(err)
        server.log(['error', 'database'], err)
        done.fail(Boom.badImplementation('Database error'))

      done(container)
    )

module.exports = DeleteContainerCommand
