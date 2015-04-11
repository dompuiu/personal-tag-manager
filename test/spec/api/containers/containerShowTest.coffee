'use strict'

describe 'ContainersShowTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/containers')
  utils = require('../../../helpers/api_utils')

  createShowRequest = (container) ->
    options = {
      method: 'GET'
      url: "/containers/#{container._id}/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should show a container', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createShowRequest(storage.container)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(result.name).to.equal(storage.container.name)
        expect(response.statusCode).to.equal(200)
        done()
      .or((err) -> console.error(err))

  it 'should not accept un invalid object id', (done) ->
    request = createShowRequest({user_id: '10', _id: '111'})

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(400)
        done()
      .or((err) -> console.error(err))

  it 'should not show an unexisting container', (done) ->
    request = createShowRequest({
      user_id: '10'
      _id: '111111111111111111111111'
    })

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(404)
        done()
      .or((err) -> console.error(err))

  it 'should not show an deleted container', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({deleted_at: new Date('2013-01-01')}))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createShowRequest({
          user_id: storage.container.user_id
          _id: storage.container._id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(response.statusCode).to.equal(404)
        done()
      .or((err) -> console.error(err))

  it 'should show only containers they own', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createShowRequest({
          user_id: '20'
          _id: storage.container._id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(response.statusCode).to.equal(401)
        done()
      .or((err) -> console.error(err))

  beforeEach (done) ->
    Container = require('../../../../app/api_app/models/container')
    utils.emptyColection(Container, done)
