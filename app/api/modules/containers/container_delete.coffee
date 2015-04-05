_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerDeleteSchema = require('./schemas/container_delete')
DeleteContainerCommand = require('../../../commands/container_delete')

class ContainerDelete
  route: ->
    {
      method: 'DELETE'
      path:'/v1/containers/'
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
            {code: 200, message: 'OK'},
            {code: 400, message: 'Bad Request'},
            {code: 401, message: 'Unauthorized'},
            {code: 404, message: 'Not found'},
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
      payload: {
        id: Joi.string().required()
          .description('Container id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.payload, 'id')
    data.user_id = request.auth.credentials.id

    c = new DeleteContainerCommand(data)
    c.run(reply)

module.exports = ContainerDelete
