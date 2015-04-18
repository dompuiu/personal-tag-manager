Joi = require('joi')
Boom = require('boom')

Container = require('../models/container')
Version = require('../models/version')
Tag = require('../models/tag')

mongoose = require('mongoose')
ObjectId = mongoose.Types.ObjectId

ASQ = require('asynquence')
Server = require('../api/server')

class CreateTagCommand
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
      @data.name,
      Joi.string().required()
    )

    Joi.assert(
      @data.dom_id,
      Joi.string().required().regex(/^[A-Za-z0-9_\-\.]+$/)
    )

    Joi.assert(
      @data.type,
      Joi.string().required().valid('html', 'js', 'script', 'block-script')
    )

    Joi.assert(
      @data.src,
      Joi.string()
    )

    Joi.assert(
      @data.onload,
      Joi.string()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@checkContainerAndAuthId)
      .then(@checkVersionId)
      .then(@checkDomIdIsUnique)
      .then(@createAndSaveTag)
      .val((storage) -> done(null, storage.tag))
      .or((err) -> done(err, null))

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

      done(storage)

  checkDomIdIsUnique: (done, storage) =>
    data = {
      version_id: new ObjectId(storage.data.version_id)
      container_id: new ObjectId(storage.data.container_id)
      user_id: storage.data.user_id
      dom_id: storage.data.dom_id
    }
    Tag.count(data, @onTagCount(done, storage))

  onTagCount: (done, storage) =>
    (err, count) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if count > 0
        return done.fail(
          Boom.conflict('A tag with the same ID already exists')
        )

      done(storage)

  createAndSaveTag: (done, storage) =>
    c = new Tag(storage.data)
    c.save(@onSave(done, storage))

  onSave: (done, storage) ->
    (err, tag) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot save tag to database')
        )

      storage.tag = tag
      done(storage)

module.exports = CreateTagCommand
