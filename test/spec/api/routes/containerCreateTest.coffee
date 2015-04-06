'use strict'

describe 'ContainersCreateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createContainerRequest = (container_name) ->
    options = {
      method: 'PUT'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {name: container_name}
      credentials: {name: 'user name', id: '10'}
    }

  it 'should create a container', (done) ->
    ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(createContainerRequest('some name')))
      .val((server, response) ->
        result = response.result

        expect(response.statusCode).to.equal(200)
        expect(result.name).to.equal('some name')
        expect(result.storage_namespace).to.not.be.empty
        expect(result.user_id).to.not.be.empty

        done()
      )

  it 'should allow creation of containers with unique names', (done) ->
    ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(createContainerRequest('some other name')))
      .then(utils.makeRequest(createContainerRequest('some other name')))
      .val((server, response) ->
        expect(response.statusCode).to.equal(409)
        done()
      )

  it 'should allow creation of containers with names of deleted containers', (done) ->
    ASQ(utils.createContainer({name: 'some unexisting name'}))
      .val((container) ->
        ASQ(utils.configureServer(routes))
          .then(utils.makeRequest(createContainerRequest('some unexisting name')))
          .val((server, response) ->
            expect(response.statusCode).to.equal(200)
            done()
          )
        )

  before((done) ->
    utils.emptyColection(Container, done)
  )



