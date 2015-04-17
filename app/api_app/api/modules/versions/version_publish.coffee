_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
VersionActionResultSchema = require('./schemas/version_action_result')
PublishVersionCommand = require('../../../commands/version_publish')

class VersionPublish
  route: ->
    {
      method: 'POST'
      path: '/containers/{container_id}/versions/{version_id}/publish/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Publishes a version'
      notes: 'Returns a message'
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
        schema : VersionActionResultSchema
      }
    }

  validate: ->
    {
      params: {
        container_id: Joi.string().required()\
          .description('Container id').example('55217ae69aa4cb095dc12650')

        version_id: Joi.string().required()\
          .description('Version id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = {
      container_id: request.params.container_id
      version_id: request.params.version_id
    }
    data.user_id = request.auth.credentials.id

    c = new PublishVersionCommand(data)
    c.run(reply)

module.exports = VersionPublish
