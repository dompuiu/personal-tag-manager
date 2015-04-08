_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
ContainerSchema = require('./schemas/container')
CreateContainerCommand = require('../../../commands/container_create')
CreateVersionCommand = require('../../../commands/version_create')

class ContainerCreate
  route: ->
    {
      method: 'POST'
      path:'/containers/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Create a new container'
      notes: 'Returns a container object'
      tags: ['api']
      plugins: {
        'hapi-swagger': {
          responseMessages: [
            {code: 200, message: 'OK'}
            {code: 400, message: 'Bad Request'}
            {code: 409, message: 'Conflict'}
            {code: 500, message: 'Internal Server Error'}
          ]
        }
      }
      validate: @validate()
      response: {
        schema : ContainerSchema
      }
    }

  validate: ->
    {
      payload: {
        name: Joi.string().required().regex(/^[A-Za-z0-9 -\.]+$/)
          .min(5).description('Container name').example('some name')

        domain: Joi.string().hostname().required()
          .description('Domain name').example('www.google.com')
      }
    }

  handler: (request, reply) =>
    ASQ({request: request})
      .then(@createContainer)
      .then(@createInitialVersion)
      .val((storage) -> reply(storage.container.toSwaggerFormat()))
      .or((err) -> reply(err))

  createContainer: (done, storage) =>
    data = _.pick(storage.request.payload, 'name', 'domain')
    data.user_id = storage.request.auth.credentials.id

    c = new CreateContainerCommand(data)
    c.run(@onContainerCreate(done, storage))

  onContainerCreate: (done, storage) ->
    (err, container) ->
      if (err)
        done.fail(err)
      else
        storage.container = container
        done(storage)

  createInitialVersion: (done, storage) =>
    c = new CreateVersionCommand({
      container_id: storage.container._id
      user_id: storage.container.user_id
      status: 'now editing'
    })
    c.run(@onVersionCreate(done, storage))

  onVersionCreate: (done, storage) ->
    (err, version) ->
      if (err)
        done.fail(err)
      else
        storage.version = version
        done(storage)

module.exports = ContainerCreate
