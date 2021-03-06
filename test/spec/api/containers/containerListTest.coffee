'use strict'

describe 'ContainersListTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/containers')
  utils = require('../../../helpers/api_utils')

  listContainerRequest = (user_id) ->
    options = {
      method: 'GET'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: user_id}
    }

  it 'should list containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = listContainerRequest(storage.container.user_id)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(result.items[0].name).to.equal(storage.container.name)
        expect(result.count).to.equal(1)
        expect(response.statusCode).to.equal(200)
        done()
      .or((err) -> console.error(err))

  it 'should list only owned containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({user_id: '10'}, 'container1'))
      .then(utils.createContainer({user_id: '11'}, 'container2'))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = listContainerRequest(storage.container1.user_id)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(result.items[0].name).to.equal(storage.container1.name)
        expect(result.count).to.equal(1)
        expect(response.statusCode).to.equal(200)
        done()
      .or((err) -> console.error(err))

  it 'should not list deleted containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({
        user_id: '11',
        deleted_at: new Date()
      }, 'container1'))
      .then(utils.createContainer({user_id: '11'}, 'container2'))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = listContainerRequest(storage.container2.user_id)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(result.items[0].name).to.equal(storage.container2.name)
        expect(result.count).to.equal(1)
        expect(response.statusCode).to.equal(200)
        done()
      .or((err) -> console.error(err))

  beforeEach (done) ->
    Container = require('../../../../app/api_app/models/container')
    utils.emptyColection(Container, done)
