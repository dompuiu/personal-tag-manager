'use strict'

describe 'VersionInfoTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/versions')
  utils = require('../../../helpers/api_utils')

  showVersionInfoRequest = (data) ->
    options = {
      method: 'GET'
      url: "/containers/#{data.container_id}/versions/info/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: data.user_id}
    }

  describe 'when having only an editing version', ->
    createEditingVersionAndMakeRequest = (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.createTag())
        .then(utils.createTag())
        .then(utils.configureServer)
        .then((done, storage) ->
          storage.request = showVersionInfoRequest({
            container_id: storage.container._id
            user_id: storage.container.user_id
          })
          done(storage)
        )
        .then(utils.makeRequest)
        .val (storage) ->
          done(storage)

    it 'should show info about the editing version', (done) ->
      ASQ(createEditingVersionAndMakeRequest)
        .val (storage) ->
          response = storage.response
          result = response.result

          expect(response.statusCode).to.equal(200)

          expect(result.editing.tags_count).to.equal(2)
          expect(result.editing.version_id).to\
            .equal(storage.version._id.toString())
          expect(result.editing.version_number).to\
            .equal(storage.version.version_number)

          done()
        .or((err) -> console.error(err))

    it 'should not contain info about published version', (done) ->
      ASQ(createEditingVersionAndMakeRequest)
        .val (storage) ->
          response = storage.response
          result = response.result

          expect(response.statusCode).to.equal(200)
          expect(result.published).to.not.exist

          done()
        .or((err) -> console.error(err))

  describe 'when having an editing version with no tags', ->
    createEditingVersionAndMakeRequest = (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.configureServer)
        .then((done, storage) ->
          storage.request = showVersionInfoRequest({
            container_id: storage.container._id
            user_id: storage.container.user_id
          })
          done(storage)
        )
        .then(utils.makeRequest)
        .val (storage) ->
          done(storage)

    it 'should show info about the editing version', (done) ->
      ASQ(createEditingVersionAndMakeRequest)
        .val (storage) ->
          response = storage.response
          result = response.result

          expect(response.statusCode).to.equal(200)
          expect(result.editing.tags_count).to.equal(0)

          done()
        .or((err) -> console.error(err))


  describe 'when having a published version', ->
    createPublishedAndEditingVersionAndMakeRequest = (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({
          status: 'now editing'
        }, 'container', 'editing_version'))
        .then(utils.createVersion({
          status: 'published',
          published_at: new Date()
        }, 'container', 'published_version'))
        .then(utils.createTag({}, 'published_version'))
        .then(utils.createTag({}, 'published_version'))
        .then(utils.createTag({}, 'published_version'))
        .then(utils.createTag({}, 'editing_version'))
        .then(utils.createTag({}, 'editing_version'))
        .then(utils.configureServer)
        .then((done, storage) ->
          storage.request = showVersionInfoRequest({
            container_id: storage.container._id
            user_id: storage.container.user_id
          })
          done(storage)
        )
        .then(utils.makeRequest)
        .val (storage) ->
          done(storage)

    it 'should show info about the published version', (done) ->
      ASQ(createPublishedAndEditingVersionAndMakeRequest)
        .val (storage) ->
          response = storage.response
          result = response.result

          expect(response.statusCode).to.equal(200)

          expect(result.published.tags_count).to.equal(3)
          expect(result.published.version_id).to\
            .equal(storage.published_version._id.toString())
          expect(result.published.version_number).to\
            .equal(storage.published_version.version_number)

          done()
        .or((err) -> console.error(err))

    it 'should contain info about editing version', (done) ->
      ASQ(createPublishedAndEditingVersionAndMakeRequest)
        .val (storage) ->
          response = storage.response
          result = response.result

          expect(response.statusCode).to.equal(200)
          expect(result.editing).to.exist

          done()
        .or((err) -> console.error(err))


  it 'should show tags only to the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showVersionInfoRequest({
          user_id: '100'
          container_id: storage.version.container_id
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should show tags only from existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showVersionInfoRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should not accept un invalid tag id', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showVersionInfoRequest({
          container_id: '111'
          user_id: storage.container.user_id
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(400)
        done()

  beforeEach (done) ->
    Container = require('../../../../app/api_app/models/container')
    Version = require('../../../../app/api_app/models/version')
    Tag = require('../../../../app/api_app/models/tag')

    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
