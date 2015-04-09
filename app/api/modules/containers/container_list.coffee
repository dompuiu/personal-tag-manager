_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
ContainerListSchema = require('./schemas/container_list')
ContainersListCommand = require('../../../commands/container_list')

class ContainersList
  route: ->
    {
      method: 'GET'
      path:'/containers/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show container list of the user'
      notes: 'Returns an array with all the containers'
      tags: ['api']
      plugins: {
        'hapi-swagger': {
          responseMessages: [
            {code: 200, message: 'OK'}
            {code: 500, message: 'Internal Server Error'}
          ]
        }
      }
      response: {
        schema : ContainerListSchema
      }
    }

  handler: (request, reply) ->
    data = {user_id: request.auth.credentials.id}
    new ContainersListCommand(data).run(reply)

module.exports = ContainersList
