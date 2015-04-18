Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')

VersionDuplicateCommand = require('./version_duplicate')
GenerateAssetsCommand = require('./generate_assets')

ASQ = require('asynquence')
Server = require('../api/server')

class VersionPublishCommand
  constructor: (@data) ->
    Joi.assert(
      @data.container_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.version_id,
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
      .then(@checkContainerAndAuthId)
      .then(@checkVersion)
      .then(@duplicateVersion)
      .then(@findPublishedVersion)
      .then(@archivePublishedVersion)
      .then(@publishVersion)
      .then(@generateAssets)
      .val((storage) ->
        done(
          null,
          {result: true, message: 'Version was successfully published'}
        )
      )
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    valid = true
    _.each(['container_id', 'version_id'], (key) ->
      unless /^[0-9a-fA-F]{24}$/.test(storage.data[key])
        valid = false
        return false
    )

    unless valid
      return done.fail(Boom.badRequest('Wrong Id Format'))

    done(storage)

  checkContainerAndAuthId: (done, storage) =>
    data = {
      _id: storage.data.container_id
    }

    Container.findOne(data, @onContainerFind(done, storage))

  onContainerFind: (done, storage) =>
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !container
        return done.fail(
          Boom.notFound('Container not found')
        )

      if storage.data.user_id != container.user_id
        return done.fail(
          Boom.unauthorized('Not authorized to add tags on this container')
        )

      done(storage)

  checkVersion: (done, storage) =>
    data = {
      _id: storage.data.version_id
      container_id: storage.data.container_id
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

      if storage.data.user_id != version.user_id
        return done.fail(
          Boom.unauthorized('Not authorized to add tags on this version')
        )

      if 'now editing' != version.status
        return done.fail(
          Boom.preconditionFailed('Can publish only now editing versions')
        )


      storage.version = version
      done(storage)

  duplicateVersion: (done, storage) =>
    c = new VersionDuplicateCommand({version_id: storage.data.version_id})
    c.run(@onDuplicateVersion(done, storage))

  onDuplicateVersion: (done, storage) =>
    (err, new_version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.new_version = new_version
      done(storage)

  findPublishedVersion: (done, storage) =>
    data = {
      status: 'published'
      container_id: storage.data.container_id
      user_id: storage.version.user_id
    }

    Version.findOne(data, @onPublishedVersionFind(done, storage))

  onPublishedVersionFind: (done, storage) =>
    (err, published_version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if published_version
        storage.published_version = published_version

      done(storage)

  archivePublishedVersion: (done, storage) =>
    if !storage.published_version
      return done(storage)

    storage.published_version.status = 'archived'
    storage.published_version.published_at = undefined
    storage.published_version.save(@onArchivedVersionSave(done, storage))

  onArchivedVersionSave: (done, storage) =>
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      done(storage)

  publishVersion: (done, storage) =>
    storage.version.status = 'published'
    storage.version.published_at = new Date()
    storage.version.save(@onVersionSave(done, storage))

  onVersionSave: (done, storage) =>
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.version = version
      done(storage)

  generateAssets: (done, storage) =>
    c = new GenerateAssetsCommand({
      container_id: storage.data.container_id
      version_id: storage.data.version_id
    })
    c.run(@onGenerateAssets(done, storage))

  onGenerateAssets: (done, storage) =>
    (err, new_version) =>
      if err
        @server.log(['error'], err)
        return done.fail(Boom.badImplementation('Cannot generate assets'))

      storage.new_version = new_version
      done(storage)


module.exports = VersionPublishCommand
