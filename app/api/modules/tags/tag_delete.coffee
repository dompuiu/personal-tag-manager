_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
TagDeleteSchema = require('./schemas/tag_delete')
DeleteTagCommand = require('../../../commands/tag_delete')

class TagDelete
  route: ->
    {
      method: 'DELETE'
      path: '/containers/{container_id}/versions/{version_id}/tags/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Delete a tag'
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
        schema : TagDeleteSchema
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

    new DeleteTagCommand(data).run(reply)

module.exports = TagDelete
