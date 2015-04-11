'use strict'

describe 'TagsListTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/tags')
  Container = require('../../../../app/models/container')
  Version = require('../../../../app/models/version')
  Tag = require('../../../../app/models/tag')
  utils = require('../../../utils')
  _ = require('lodash')

  showListRequest = (data) ->
    options = {
      method: 'GET'
      url: "/containers/#{data.container_id}/versions/#{data.version_id}/tags/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: data.user_id}
    }

  it 'should list tags', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        expect(result.items[0].name).to.equal(storage.tag.name)
        expect(result.count).to.equal(1)
        expect(storage.response.statusCode).to.equal(200)

        done()

  it 'should show tags only to the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: '100'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
          id: storage.tag._id.toString()
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
        storage.request = showListRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
          version_id: storage.version._id.toString()
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should show tags only from existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: '111111111111111111111111'
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  describe 'when trying to show a tag', ->
    showListWithInvalidId = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = showListRequest(_.merge({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
            id: storage.tag._id.toString()
          }, main_storage.data || {}))
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          done(storage)

    it 'should not accept un invalid container id', (done) ->
      ASQ({data: {container_id: '111'}})
        .then(showListWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

    it 'should not accept un version id', (done) ->
      ASQ({data: {version_id: '111'}})
        .then(showListWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

  beforeEach (done) ->
    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
