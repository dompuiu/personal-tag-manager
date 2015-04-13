_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
TagListSchema = require('./schemas/tag_list')
ShowListCommand = require('../../../commands/tag_list')

class TagList
  route: ->
    {
      method: 'GET'
      path: '/containers/{container_id}/versions/{version_id}/tags/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Show tags list'
      notes: 'Returns an array with all the tags'
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
        schema : TagListSchema
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
    data = _.pick(request.params, 'version_id', 'container_id')
    data.user_id = request.auth.credentials.id

    new ShowListCommand(data).run(reply)

module.exports = TagList
