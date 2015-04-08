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
      payload: {name: container.name, domain: 'somedomain.com'}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should create a container', (done) ->
    request = createContainerRequest({name: 'some name'})
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
        name: 'some unexisting name'
        user_id: '10'
        deleted_at: new Date()
      })

      ASQ(callback).val (container) ->
        request = createContainerRequest(container)
        ASQ(utils.configureServer(routes)).then(utils.makeRequest(request))
          .val (server, response) ->
            expect(response.statusCode).to.equal(200)
            done()

  describe 'after a container is created', ->
    before (done) ->
      utils.emptyColection(Version, done)

    getInitialVersion = (done, server, response) ->
      container = response.result
      Version.find {container_id: new ObjectId(container.id)},
        (err, versions) ->
          done(container, versions)

    it 'should create an editinng version', (done) ->
      request = createContainerRequest({name: 'some name'})
      ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(request))
        .then(getInitialVersion)
        .val (container, versions) ->
          version = versions[0]
          expect(versions.length).to.equal(1)

          expect(version.version_id).to.equal(1)
          expect(version.user_id).to.equal(container.user_id)
          expect(version.status).to.equal('now editing')
          expect(version.created_at).to.exists

          done()

  beforeEach (done) ->
    utils.emptyColection(Container, done)
