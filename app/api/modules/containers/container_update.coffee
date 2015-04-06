_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerSchema = require('./schemas/container')
UpdateContainerCommand = require('../../../commands/container_update')

class ContainerUpdate
  route: ->
    {
      method: 'PUT'
      path:'/containers/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Update an existing container'
      notes: 'Returns the updated container object'
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
      payload: {
        name: Joi.string().required().regex(/^[A-Za-z0-9 -\.]+$/)
          .min(5).description('Container name').example('some name')
      },
      params: {
        id: Joi.string().required()
          .description('Container id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.payload, 'name')
    data.id = request.params.id
    data.user_id = request.auth.credentials.id

    c = new UpdateContainerCommand(data)
    c.run(reply)

module.exports = ContainerUpdate
