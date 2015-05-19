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

        onload: Joi.string().allow('')\
          .description('Code to be executed after tag load')

        inject_position: Joi.number()\
          .description('Position where to trigger the tag\
          (accepted values: 1 (page top), 2 (page bottom))')

        match: Joi.array().items(
          Joi.object().keys({
            condition: Joi.string().required()\
              .allow('contains', 'daterange', 'dow', 'regex')
            not: Joi.boolean().required()
            param: Joi.string().required()\
              .allow('host', 'path', 'cookie', 'query', 'date')
            param_name: Joi.any().required()
            values: Joi.object().keys({
              days: Joi.array().items(Joi.number()).max(7).unique()
              min: Joi.string()
              max: Joi.string()
              scalar: Joi.string()
              pattern: Joi.string()
            }).required()
          })
        ).description('Trigger type object')
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
    data.onload = storage.request.payload.onload

    payload = _.pick(
      storage.request.payload,
      'name', 'dom_id', 'type', 'src', 'inject_position', 'match'
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
