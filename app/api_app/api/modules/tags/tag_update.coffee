_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
TagSchema = require('./schemas/tag')
UpdateTagCommand = require('../../../commands/tag_update')

class TagCreate
  route: ->
    {
      method: 'PUT'
      path: '/containers/{container_id}/versions/{version_id}/tags/{id}/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      auth: 'simple'
      description: 'Update a tag'
      notes: 'Returns the updated tag object'
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
        container_id: Joi.string().required()\
          .description('Container id').example('55217ae69aa4cb095dc12650')

        version_id: Joi.string().required()\
          .description('Version id').example('55217ae69aa4cb095dc12650')

        id: Joi.string().required()\
          .description('Tag id').example('55217ae69aa4cb095dc12650')
      }
      payload: {
        name: Joi.string()\
          .description('Tag Name').example('Google Analytics Tag')

        dom_id: Joi.string().regex(/^[A-Za-z0-9_\-\.]+$/)\
          .description('Tag ID to be used in DOM').example('mytag')

        type: Joi.string().description('Tag type')\
          .example('html, js, block-script, script')

        src: Joi.string()\
          .description('Tag source').example('console.log("a");')

        onload: Joi.string()\
          .description('Code to be executed after tag load')
      }
    }

  handler: (request, reply) =>
    ASQ({request: request})
      .then(@createTag)
      .val((storage) -> reply(storage.tag.toSwaggerFormat()))
      .or((err) -> reply(err))

  createTag: (done, storage) =>
    data = _.pick(storage.request.params, 'version_id', 'container_id', 'id')
    data.user_id = storage.request.auth.credentials.id

    payload = _.pick(
      storage.request.payload,
      'name', 'dom_id', 'type', 'src', 'onload'
    )
    _.merge(data, payload)

    c = new UpdateTagCommand(data)
    c.run(@onTagCreate(done, storage))

  onTagCreate: (done, storage) ->
    (err, tag) ->
      if (err)
        done.fail(err)
      else
        storage.tag = tag
        done(storage)

module.exports = TagCreate
