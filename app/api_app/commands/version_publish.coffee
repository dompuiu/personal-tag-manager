Joi = require('joi')
Boom = require('boom')
_ = require('lodash')

Container = require('../models/container')
Version = require('../models/version')

VersionDuplicateCommand = require('./version_duplicate')

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
      .then(@checkVersionId)
      .then(@duplicateVersion)
      .then(@publishVersion)
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

  checkVersionId: (done, storage) =>
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

      if storage.data.user_id != version.user_id \
      || 'now editing' != version.status
        return done.fail(
          Boom.unauthorized('Not authorized to add tags on this version')
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

  publishVersion: (done, storage) =>
    storage.version.status = 'published'
    storage.version.save(@onVersionSave(done, storage))

  onVersionSave: (done, storage) =>
    (err, version) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.version = version
      done(storage)

module.exports = VersionPublishCommand
