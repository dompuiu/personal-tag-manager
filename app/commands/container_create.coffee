Joi = require('joi')
Boom = require('boom')
Container = require('../models/container')
CreateVersionCommand = require('../commands/version_create')
ASQ = require('asynquence')
Server = require('../api/server')

class CreateContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.name,
      Joi.string().required().regex(/^[A-Za-z0-9 -\.]+$/).min(5)
    )

    Joi.assert(
      @data.domain,
      Joi.string().hostname().required()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    @server = Server.get()

  run: (done) ->
    ASQ({data: @data})
      .then(@checkNameIsUnique)
      .then(@createAndSaveContainer)
      .val((storage) -> done(null, storage.container))
      .or((err) -> done(err, null))

  checkNameIsUnique: (done, storage) =>
    data = {
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

  createAndSaveContainer: (done, storage) =>
    c = new Container(storage.data)
    c.generateStorageNamespace()

    c.save(@onSave(done, storage))

  onSave: (done, storage) ->
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot save container to database')
        )

      storage.container = container
      done(storage)

module.exports = CreateContainerCommand
