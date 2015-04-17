'use strict'

describe 'VersionsListTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/versions')
  utils = require('../../../helpers/api_utils')
  _ = require('lodash')

  showListRequest = (data) ->
    options = {
      method: 'GET'
      url: "/containers/#{data.container_id}/versions/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: data.user_id}
    }

  it 'should list versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        expect(result.items[0].name).to.equal(storage.version.name)
        expect(result.count).to.equal(1)
        expect(storage.response.statusCode).to.equal(200)

        done()

  it 'should show versions only to the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: '100'
          container_id: storage.version.container_id
          id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should show versions only from existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = showListRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
          id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  describe 'when trying to show versions list', ->
    showListWithInvalidId = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({status: 'now editing'}))
        .then((done, storage) ->
          storage.request = showListRequest(_.merge({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            id: storage.version._id.toString()
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

  beforeEach (done) ->
    Container = require('../../../../app/api_app/models/container')
    Version = require('../../../../app/api_app/models/version')
    Tag = require('../../../../app/api_app/models/tag')

    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
