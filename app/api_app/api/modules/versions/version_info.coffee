_ = require('lodash')
Joi = require('joi')
Server = require('../../server')
VersionInfoSchema = require('./schemas/version_info')
VersionInfoCommand = require('../../../commands/version_info')

class ContainerShow
  route: ->
    {
      method: 'GET'
      path:'/containers/{id}/versions/info/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show container versions info'
      notes: 'Returns an object containing details about the versions'
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
        schema : VersionInfoSchema
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
      container_id: request.params.id
      user_id: request.auth.credentials.id
    }

    new VersionInfoCommand(data).run(reply)

module.exports = ContainerShow
