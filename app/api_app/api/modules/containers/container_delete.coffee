_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerDeleteSchema = require('./schemas/container_delete')
DeleteContainerCommand = require('../../../commands/container_delete')

class ContainerDelete
  route: ->
    {
      method: 'DELETE'
      path:'/containers/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Delete an existing container'
      notes: 'Returns a message'
      tags: ['api']
      plugins: {
        'hapi-swagger': {
          responseMessages: [
            {code: 200, message: 'OK'}
            {code: 400, message: 'Bad Request'}
            {code: 401, message: 'Unauthorized'}
            {code: 404, message: 'Not found'}
            {code: 500, message: 'Internal Server Error'}
          ]
        }
      }
      validate: @validate()
      response: {
        schema : ContainerDeleteSchema
      }
    }

  validate: ->
    {
      params: {
        id: Joi.string().required()\
          .description('Container id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = {
      id: request.params.id
      user_id: request.auth.credentials.id
    }

    new DeleteContainerCommand(data).run(reply)

module.exports = ContainerDelete
