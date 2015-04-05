_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerValidatorSchema = require('./schemas/container')
CreateContainerCommand = require('../../../commands/create_container')

class ContainerCreate
  route: ->
    {
      method: 'PUT'
      path:'/v1/containers/'
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
            {code: 200, message: 'OK'},
            {code: 400, message: 'Bad Request'},
            {code: 409, message: 'Conflict'},
            {code: 500, message: 'Internal Server Error'}
          ]
        }
      }
      validate: @validate()
      response: {
        schema : ContainerValidatorSchema
      }
    }

  validate: ->
    {
      payload: {
        name: Joi.string().required().regex(/^[A-Za-z0-9 -]+$/)
          .min(5).description('Container name').example('some name')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.payload, 'name')
    data.user_id = request.auth.credentials.id

    c = new CreateContainerCommand(data)
    c.run(reply)

module.exports = ContainerCreate
