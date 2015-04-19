Joi = require('joi')
Boom = require('boom')
_ = require('lodash')
fs = require('fs')
jsStringEscape = require('js-string-escape')

Container = require('../models/container')
Version = require('../models/version')
Tag = require('../models/tag')

ASQ = require('asynquence')
Server = require('../api/server')

class GenerateAssetsCommand
  constructor: (@data) ->
    Joi.assert(
      @data.version_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.container_id,
      Joi.string().required()
    )

    Joi.assert(
      @data.stage,
      Joi.boolean()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@findContainer)
      .then(@findVersion)
      .then(@createStorageFolder)
      .then(@readJsLibraryContent)
      .then(@findTags)
      .then(@generateConfig)
      .then(@writeJsLibraryContent)
      .val((storage) -> done(null, true))
      .or((err) -> done(err, null))

  getStorageFolder: (storage) ->
    "#{__dirname}/../../../storage/libs/#{storage.container.storage_namespace}"

  findContainer: (done, storage) =>
    Container.findOne({_id: storage.data.container_id},
      @onContainerFind(done, storage))

  onContainerFind: (done, storage) =>
    (err, container) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      if !container
        return done.fail(
          Boom.notFound('Container not found')
        )

      storage.container = container
      done(storage)

  findVersion: (done, storage) =>
    Version.findOne({_id: storage.data.version_id},
      @onVersionFind(done, storage))

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

  createStorageFolder: (done, storage) =>
    mkdirp = require('mkdirp')
    mkdirp(@getStorageFolder(storage), @onCreateStorageFolder(done, storage))

  onCreateStorageFolder: (done, storage) =>
    (err) =>
      if err
        @server.log(['error'], err)
        return done.fail(Boom.badImplementation('Cannot create storage folder'))

      done(storage)

  readJsLibraryContent: (done, storage) =>
    js_library_path = "#{__dirname}/../../../js_library/atm.debug.js"
    fs.readFile(js_library_path, 'utf8', @onReadJsLibraryContent(done, storage))

  onReadJsLibraryContent: (done, storage) =>
    (err, data) =>
      if err
        @server.log(['error'], err)
        return done.fail(Boom.badImplementation('Cannot read JS library'))

      storage.js_library_data = data
      done(storage)

  findTags: (done, storage) =>
    Tag.find({
      version_id: storage.data.version_id
      container_id: storage.data.container_id
    }, @onFind(done, storage))

  onFind: (done, storage) =>
    (err, tags) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(Boom.badImplementation('Database error'))

      storage.tags = tags
      done(storage)

  generateConfig: (done, storage) =>
    segments = storage.tags.map(@generateTagConfig)
    storage.config = segments
    done(storage)

  generateTagConfig: (tag) ->
    pickNonfalsy = _.partial(_.pick, _, _.identity)
    config = pickNonfalsy(
      _.pick(tag, 'dom_id', 'type', 'src', 'onload', 'match')
    )

    config.inject = {
      position: tag.inject_position,
      tag: 2
    }
    config.id = config.dom_id
    delete config.dom_id

    if (config.type == 'block-script' || config.type == 'script')
      unless /^http(s?):\/\//.test(config.src)
        config.src = "http://#{config.src}"

    return config

  writeJsLibraryContent: (done, storage) =>
    config = jsStringEscape(JSON.stringify(storage.config))
    file = switch storage.data.stage
      when true then 'ptm.stage.lib.js'
      else 'ptm.lib.js'

    fs.writeFile(
      "#{@getStorageFolder(storage)}/#{file}"
      storage.js_library_data.replace('%s', config),
      'utf8',
      @onWriteJsLibraryContent(done, storage)
    )

  onWriteJsLibraryContent: (done, storage) =>
    (err) =>
      if err
        @server.log(['error'], err)
        return done.fail(Boom.badImplementation('Cannot write JS library'))

      done(storage)

module.exports = GenerateAssetsCommand
