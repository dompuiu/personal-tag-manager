Joi = require('joi')
Boom = require('boom')
Version = require('../models/version')
Tag = require('../models/tag')
ASQ = require('asynquence')
Server = require('../api/server')

mongoose = require('mongoose')
ObjectId = mongoose.Types.ObjectId

class ShowContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.container_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@checkObjectIdFormat)
      .then(@findVersions)
      .then(@checkUserId)
      .then(@getTagsCount)
      .then(@prepareResonse)
      .val((storage) -> done(null, storage.response))
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    unless /^[0-9a-fA-F]{24}$/.test(storage.data.container_id)
      return done.fail(Boom.badRequest('Wrong Id Format'))

    done(storage)

  findVersions: (done, storage) =>
    Version.find({
      container_id: storage.data.container_id
      status: {$in: ['now editing', 'published']}
      deleted_at: {$exists: false}
    },
    @onVersionsFind(done, storage))

  onVersionsFind: (done, storage) =>
    (err, versions) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !versions
        return done.fail(Boom.notFound('Version not found'))

      versions.forEach((version) ->
        if version.status == 'now editing'
          storage.editing_version = version
        else if version.status == 'published'
          storage.published_version = version
      )

      if !storage.editing_version
        return done.fail(Boom.notFound('Version not found'))

      done(storage)

  checkUserId: (done, storage) ->
    if storage.editing_version.user_id != storage.data.user_id or \
    (storage.published_version && \
    storage.published_version.user_id != storage.data.user_id)

      return done.fail(
        Boom.unauthorized('Not authorized to view this version')
      )

    done(storage)

  getTagsCount: (done, storage) =>
    version_ids = [storage.editing_version._id]
    if storage.published_version
      version_ids.push(storage.published_version._id)

    Tag.aggregate([
      {$match : {version_id : {$in: version_ids}}},
      {$group : {_id: '$version_id', count: {$sum: 1}}}
    ], @onTagsCount(done, storage))

  onTagsCount: (done, storage) =>
    (err, result) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.tags_count = {editing_version: 0}
      result.forEach((item) ->
        if item._id.toString() == storage.editing_version._id.toString()
          storage.tags_count.editing_version = item.count
        else
          storage.tags_count.published_version = item.count
      )

      done(storage)


  prepareResonse: (done, storage) ->
    storage.response = {
      editing: {
        version_id: storage.editing_version._id.toString(),
        version_number: storage.editing_version.version_number,
        created_at: storage.editing_version.created_at.toISOString(),
        tags_count: storage.tags_count.editing_version
      }
    }

    if storage.published_version
      storage.response.published = {
        version_id: storage.published_version._id.toString(),
        version_number: storage.published_version.version_number,
        published_at: storage.published_version.published_at.toISOString(),
        tags_count: storage.tags_count.published_version
      }

    done(storage)

module.exports = ShowContainerCommand
