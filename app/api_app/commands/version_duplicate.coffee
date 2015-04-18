Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')
Tag = require('../models/tag')

mongoose = require('mongoose')
ObjectId = mongoose.Types.ObjectId

ASQ = require('asynquence')
Server = require('../api/server')

CreateVersionCommand = require('./version_create')

class VersionDuplicateCommand
  constructor: (@data) ->
    Joi.assert(
      @data.version_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@findVersion)
      .then(@createNewVersion)
      .then(@findTags)
      .then(@duplicateTags)
      .val((storage) -> done(null, storage.new_version))
      .or((err) -> done(err, null))

  findVersion: (done, storage) =>
    data = {
      _id: storage.data.version_id
    }

    Version.findOne(data, @onVersionFind(done, storage))

  onVersionFind: (done, storage) =>
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !version
        return done.fail(
          Boom.notFound('Version not found')
        )

      storage.version = version
      done(storage)

  createNewVersion: (done, storage) =>
    c = new CreateVersionCommand({
      container_id: storage.version.container_id
      user_id: storage.version.user_id
      status: 'now editing'
    })
    c.run(@onVersionCreate(done, storage))

  onVersionCreate: (done, storage) ->
    (err, version) ->
      if (err)
        done.fail(err)
      else
        storage.new_version = version
        done(storage)

  findTags: (done, storage) =>
    Tag.find({
      version_id: storage.data.version_id
    }, @onFind(done, storage))

  onFind: (done, storage) =>
    (err, tags) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.tags = tags
      done(storage)

  duplicateTags: (done, storage) =>
    segments = storage.tags.map(@duplicateTag(done, storage))
    ASQ()
      .all.apply(null, segments)
      .val(@onDuplicateTags(done, storage))
      .or(@onDuplicateTags(done, storage))

  duplicateTag: (done, storage) =>
    (tag) =>
      ASQ((done) =>
        tag_data = @getDataForNewTag(tag, storage.new_version._id)

        t = new Tag(tag_data)
        t.save((err, tag) ->
          if err
            done.fail(err)
          else
            done(tag)
        )
      )

  getDataForNewTag: (tag, new_version_id) ->
    pickNonfalsy = _.partial(_.pick, _, _.identity)
    d = pickNonfalsy(_.pick(tag, 'name', 'dom_id', 'type', 'src',
      'onload', 'container_id', 'user_id', 'inject_position', 'match'))
    d.version_id = new_version_id
    d

  onDuplicateTags: (done, storage) ->
    (tags...) ->
      storage.tags = tags
      done(storage)

module.exports = VersionDuplicateCommand
