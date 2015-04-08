_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerSchema = require('./schemas/container')
CreateContainerCommand = require('../../../commands/container_create')

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
        name: Joi.string().required().regex(/^[A-Za-z0-9 -]+$/)
          .min(5).description('Container name').example('some name')

        domain: Joi.string().hostname().required()
          .description('Domain name').example('www.google.com')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.payload, 'name', 'domain')
    data.user_id = request.auth.credentials.id

    c = new CreateContainerCommand(data)
    c.run(reply)

module.exports = ContainerCreate
