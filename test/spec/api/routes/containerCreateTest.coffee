'use strict'

describe 'ContainersCreateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')

  createContainer = (container_name = 'some unexisting name') ->
    (done) ->
      c = new Container({
        name: container_name,
        user_id: faker.helpers.randomNumber(10),
        storage_namespace: faker.lorem.sentence(),
        deleted_at: new Date()
      })
      c.save((err, container) -> done(container))


  configureServer = (done) ->
    Server = require('../../../../app/api/server')
    server = Server.get()
    server.route(routes)

    done(server)

  makeRequest = (config) ->
    (done, server) ->
      server.inject(config, (response) ->
        done(server, response)
      )

  createContainerRequest = (container_name) ->
    options = {
      method: 'PUT'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {name: container_name}
      credentials: {name: 'user name', id: '10'}
    }

  it 'should create a container', (done) ->
    ASQ(configureServer)
      .then(makeRequest(createContainerRequest('some name')))
      .val((server, response) ->
        result = response.result

        expect(response.statusCode).to.equal(200)
        expect(result.name).to.equal('some name')
        expect(result.storage_namespace).to.not.be.empty
        expect(result.user_id).to.not.be.empty

        done()
      )

  it 'should allow creation of containers with unique names', (done) ->
    ASQ(configureServer)
      .then(makeRequest(createContainerRequest('some other name')))
      .then(makeRequest(createContainerRequest('some other name')))
      .val((server, response) ->
        expect(response.statusCode).to.equal(409)
        done()
      )

  it 'should allow creation of containers with names of deleted containers', (done) ->
    ASQ(createContainer('some unexisting name'))
      .val((container) ->
        ASQ(configureServer)
          .then(makeRequest(createContainerRequest('some unexisting name')))
          .val((server, response) ->
            expect(response.statusCode).to.equal(200)
            done()
          )
        )

  before((done) ->
    d = require('../../../utils')
    Container = require('../../../../app/models/container')

    d.emptyColection(Container, done)
  )



