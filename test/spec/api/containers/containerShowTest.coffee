'use strict'

describe 'ContainersShowTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  faker = require('faker')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createShowRequest = (container) ->
    options = {
      method: 'GET'
      url: "/containers/#{container._id}/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should show a container', (done) ->
    callback = utils.createContainer()
    ASQ(callback).val (container) ->
      request = createShowRequest(container)

      ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(request))
        .val (server, response) ->
          result = response.result

          expect(result.name).to.equal(container.name)
          expect(response.statusCode).to.equal(200)
          done()

  it 'should not accept un invalid object id', (done) ->
    request = createShowRequest({
      user_id: '10'
      _id: '111'
    })

    ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(request))
      .val (server, response) ->
        expect(response.statusCode).to.equal(400)
        done()

  it 'should not show an unexisting container', (done) ->
    request = createShowRequest({
      user_id: '10'
      _id: '111111111111111111111111'
    })

    ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(request))
      .val (server, response) ->
        expect(response.statusCode).to.equal(404)
        done()

  it 'should not show an deleted container', (done) ->
    callback = utils.createContainer({deleted_at: new Date('2013-01-01')})

    ASQ(callback).val (container) ->
      request = createShowRequest({
        user_id: container.user_id
        _id: container._id
      })

      ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(request))
        .val (server, response) ->
          expect(response.statusCode).to.equal(404)
          done()

  it 'should show only containers they own', (done) ->
    ASQ(utils.createContainer()).val (container) ->
      request = createShowRequest({
        user_id: '20'
        _id: container._id
      })

      ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(request))
      .val (server, response) ->
        expect(response.statusCode).to.equal(401)
        done()

  beforeEach (done) ->
    utils.emptyColection(Container, done)
