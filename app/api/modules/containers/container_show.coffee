_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerSchema = require('./schemas/container')
ShowContainerCommand = require('../../../commands/container_show')

class ContainerShow
  route: ->
    {
      method: 'GET'
      path:'/containers/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show an existing container'
      notes: 'Returns the container object'
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
        schema : ContainerSchema
      }
    }

  validate: ->
    {
      params: {
        id: Joi.string().required()
          .description('Container id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = {
      id: request.params.id
      user_id: request.auth.credentials.id
    }

    new ShowContainerCommand(data).run(reply)

module.exports = ContainerShow
