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
          responseMessages: Server.standardHTTPErrors
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
    result = c.run()

    console.log(result)

    reply({
      id: '34jkljrklwjr'
      name: 'container name'
      storage_namespace: 'storagefolder'
      user_id: 'sddsfsldk',
      created_at: '2014-01-10'
      updated_at: '2014-01-10'
    })

module.exports = ContainerCreate
