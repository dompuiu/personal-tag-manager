'use strict'

describe 'ContainersCreateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createContainerRequest = (container) ->
    options = {
      method: 'POST'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {name: container.name}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should create a container', (done) ->
    request = createContainerRequest({name: 'some name', user_id: '10'})
    ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
      .val (server, response) ->
        result = response.result

        expect(response.statusCode).to.equal(200)
        expect(result.name).to.equal('some name')
        expect(result.storage_namespace).to.not.be.empty
        expect(result.user_id).to.not.be.empty

        done()

  it 'should allow creation of containers with unique names', (done) ->
    request = createContainerRequest({name: 'some new name', user_id: '10'})

    ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(request))
      .then(utils.makeRequest(request))
      .val (server, response) ->
        expect(response.statusCode).to.equal(409)
        done()

  it 'should allow creation of containers with names of deleted containers',
    (done) ->
      callback = utils.createContainer({
        name: 'some unexisting name',
        user_id: '10',
        deleted_at: new Date()
      })

      ASQ(callback).val (container) ->
        request = createContainerRequest(container)
        ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
          .val (server, response) ->
            expect(response.statusCode).to.equal(200)
            done()

  beforeEach (done) ->
    utils.emptyColection(Container, done)
