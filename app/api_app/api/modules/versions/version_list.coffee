_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
VersionListSchema = require('./schemas/version_list')
ShowVersionListCommand = require('../../../commands/version_list')

class VersionList
  route: ->
    {
      method: 'GET'
      path: '/containers/{container_id}/versions/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show versions list'
      notes: 'Returns an array with all the versions'
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
        schema : VersionListSchema
      }
    }

  validate: ->
    {
      params: {
        container_id: Joi.string().required()\
          .description('Container id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.params, 'container_id')
    data.user_id = request.auth.credentials.id

    new ShowVersionListCommand(data).run(reply)

module.exports = VersionList
