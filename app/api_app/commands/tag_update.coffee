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

class CreateTagCommand
  constructor: (@data) ->
    Joi.assert(
      @data.id,
      Joi.string().required()
    )

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
      Joi.string()
    )

    Joi.assert(
      @data.dom_id,
      Joi.string().regex(/^[A-Za-z0-9_\-\.]+$/)
    )

    Joi.assert(
      @data.type,
      Joi.string().valid('html', 'js', 'script', 'block-script')
    )

    Joi.assert(
      @data.src,
      Joi.string()
    )

    Joi.assert(
      @data.on_load,
      Joi.string()
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@checkObjectIdFormat)
      .then(@checkDomIdIsUnique)
      .then(@checkVersionId)
      .then(@findById)
      .then(@tryToUpdate)
      .val((storage) -> done(null, storage.tag))
      .or((err) -> done(err, null))

  checkObjectIdFormat: (done, storage) ->
    valid = true
    _.each(['id', 'container_id', 'version_id'], (key) ->
      unless /^[0-9a-fA-F]{24}$/.test(storage.data[key])
        valid = false
        return false
    )

    unless valid
      return done.fail(Boom.badRequest('Wrong Id Format'))

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
      _id: {$ne: storage.data.id}
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

  findById: (done, storage) =>
    Tag.findOne({
      _id: storage.data.id,
      container_id: storage.data.container_id,
      version_id: storage.data.version_id,
      user_id: storage.data.user_id,
    }, @onFind(done, storage))

  onFind: (done, storage) =>
    (err, tag) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !tag
        return done.fail(Boom.notFound('Tag not found'))

      storage.tag = tag
      done(storage)

  tryToUpdate: (done, storage) =>
    _.each(['name', 'dom_id', 'type', 'src', 'on_load'], (key) ->
      storage.tag[key] = storage.data[key] if storage.data[key]
    )
    storage.tag.updated_at = new Date()
    storage.tag.save(@onUpdate(done, storage))

  onUpdate: (done, storage) ->
    (err, tag) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot save tag to database')
        )

      storage.tag = tag
      done(storage)

module.exports = CreateTagCommand
