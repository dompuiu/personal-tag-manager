_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
TagSchema = require('./schemas/tag')
ShowTagCommand = require('../../../commands/tag_show')

class TagShow
  route: ->
    {
      method: 'GET'
      path: '/containers/{container_id}/versions/{version_id}/tags/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show a tag'
      notes: 'Returns the tag object'
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
        schema : TagSchema
      }
    }

  validate: ->
    {
      params: {
        container_id: Joi.string().required()
          .description('Container id').example('55217ae69aa4cb095dc12650')

        version_id: Joi.string().required()
          .description('Version id').example('55217ae69aa4cb095dc12650')

        id: Joi.string().required()
          .description('Tag id').example('55217ae69aa4cb095dc12650')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.params, 'version_id', 'container_id', 'id')
    data.user_id = request.auth.credentials.id

    new ShowTagCommand(data).run(reply)

module.exports = TagShow
