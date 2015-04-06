'use strict'

describe 'ContainersListTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  listContainerRequest = (user_id) ->
    options = {
      method: 'GET'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: user_id}
    }

  it 'should list containers', (done) ->
    callback = utils.createContainer()

    ASQ(callback).val (container) ->
      request = listContainerRequest(container.user_id)
      ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
        .val (server, response) ->
          result = response.result

          expect(result.items[0].name).to.equal(container.name)
          expect(result.count).to.equal(1)
          expect(response.statusCode).to.equal(200)
          done()

  it 'should list only owned containers', (done) ->
    callback_1 = utils.createContainer({user_id: '10'})
    callback_2 = utils.createContainer({user_id: '11'})

    ASQ().all(callback_1, callback_2).val (container1, container2) ->
      request = listContainerRequest(container1.user_id)
      ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
        .val (server, response) ->
          result = response.result

          expect(result.items[0].name).to.equal(container1.name)
          expect(result.count).to.equal(1)
          expect(response.statusCode).to.equal(200)
          done()

  it 'should not list deleted containers', (done) ->
    callback_1 = utils.createContainer({user_id: '11', deleted_at: new Date()})
    callback_2 = utils.createContainer({user_id: '11'})

    ASQ().all(callback_1, callback_2).val (container1, container2) ->
      request = listContainerRequest(container2.user_id)
      ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
        .val (server, response) ->
          result = response.result

          expect(result.items[0].name).to.equal(container2.name)
          expect(result.count).to.equal(1)
          expect(response.statusCode).to.equal(200)
          done()

  beforeEach (done) ->
    utils.emptyColection(Container, done)
