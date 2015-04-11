'use strict'

describe 'TagsCreateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/tags')
  Container = require('../../../../app/models/container')
  Version = require('../../../../app/models/version')
  Tag = require('../../../../app/models/tag')
  utils = require('../../../utils')

  mongoose = require('mongoose')
  ObjectId = mongoose.Types.ObjectId

  createTagRequest = (data) ->
    options = {
      method: 'POST'
      url: "/containers/#{data.container_id}/versions/#{data.version_id}/tags/"
      headers: {'Content-Type': 'application/json'}

      payload: {
        name: data.name || faker.name.firstName()
        dom_id: data.dom_id || faker.internet.userName()
        type: data.type || 'html'
        src: data.src || '<div>some html code</div>'
        on_load: data.onload || 'console.log("JS")'
      }

      credentials: {name: 'user name', id: data.user_id}
    }

  it 'should create a tag', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        expect(storage.response.statusCode).to.equal(200)
        expect(result.dom_id).to.not.be.empty
        expect(result.src).to.not.be.empty
        expect(result.on_load).to.not.be.empty
        expect(result.type).to.not.be.empty

        done()

  it 'should allow tag creation only by the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: '100'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should allow tag creation only on existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag creation only on existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: '111111111111111111111111'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag creation only on versions that are editable', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion())
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should not allow tag having the same DOM Id', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion())
      .then(utils.createTag({dom_id: 'same'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          dom_id: 'same'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()


  beforeEach (done) ->
    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))