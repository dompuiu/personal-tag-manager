'use strict'

describe 'ContainersCreateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  Version = require('../../../../app/models/version')
  utils = require('../../../utils')

  mongoose = require('mongoose')
  ObjectId = mongoose.Types.ObjectId

  createContainerRequest = (container) ->
    if !container.user_id
      container.user_id = faker.helpers.randomNumber(10).toString()

    options = {
      method: 'POST'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {name: container.name, domain: faker.internet.domainName()}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should create a container', (done) ->
    request = createContainerRequest({name: 'some name'})
    ASQ({routes: routes, request: request})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        result = response.result

        expect(response.statusCode).to.equal(200)
        expect(result.name).to.equal('some name')
        expect(result.storage_namespace).to.not.be.empty
        expect(result.user_id).to.not.be.empty

        done()
      .or((err) -> console.error(err))

  it 'should allow creation of containers with unique names', (done) ->
    request = createContainerRequest({name: 'some new name', user_id: '10'})

    ASQ({routes: routes, request: request})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(409)
        done()
      .or((err) -> console.error(err))

  it 'should allow creation of containers with names of deleted containers',
    (done) ->
      container_data = {
        name: 'some unexisting name'
        user_id: '10'
        deleted_at: new Date()
      }
      ASQ({routes: routes})
        .then(utils.createContainer(container_data))
        .then(utils.configureServer)
        .then((done, storage) ->
          storage.request = createContainerRequest(storage.container)
          done(storage)
        )
        .then(utils.makeRequest)
        .val (storage) ->
          response = storage.response
          expect(response.statusCode).to.equal(200)
          done()
        .or((err) -> console.error(err))

  describe 'after a container is created', ->
    before (done) ->
      utils.emptyColection(Version, done)

    getInitialVersion = (done, storage) ->
      container = storage.response.result
      Version.find {container_id: new ObjectId(container.id)},
        (err, versions) ->
          storage.versions = versions
          done(storage)

    it 'should create an editinng version', (done) ->
      request = createContainerRequest({name: 'some name'})

      ASQ({routes: routes, request: request})
        .then(utils.configureServer)
        .then(utils.makeRequest)
        .then(getInitialVersion)
        .val (storage) ->
          response = storage.response
          versions = storage.versions

          version = versions[0]
          expect(versions.length).to.equal(1)
          expect(version.version_number).to.equal(1)
          expect(version.user_id).to.equal(storage.response.result.user_id)
          expect(version.status).to.equal('now editing')
          expect(version.created_at).to.exists

          done()
        .or((err) -> console.error(err))

  beforeEach (done) ->
    utils.emptyColection(Container, done)
