'use strict'

describe 'ContainersDeleteTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/containers')
  Container = require('../../../../app/api_app/models/container')
  utils = require('../../../helpers/api_utils')

  createDeleteRequest = (container) ->
    options = {
      method: 'DELETE'
      url: "/containers/#{container._id}/"
      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should delete a container', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createDeleteRequest(storage.container)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        container = storage.container

        expect(response.statusCode).to.equal(200)
        Container.findOne({_id: container._id}, (err, container) ->
          expect(container.deleted_at).to.exist
          done()
        )
      .or((err) -> console.error(err))

  it 'should not accept un invalid object id', (done) ->
    request = createDeleteRequest({user_id: '10', _id: '111'})

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(400)
        done()
      .or((err) -> console.error(err))

  it 'should not delete an unexisting container', (done) ->
    request =
      createDeleteRequest({user_id: '10', _id: '00219cdb4fd2759a0b228099'})

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(404)
        done()
      .or((err) -> console.error(err))

  it 'should allow deleting only containers they own', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createDeleteRequest({
          user_id: '20',
          _id: storage.container._id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(401)
        done()
      .or((err) -> console.error(err))

  it 'should not allow deletion of already deleted containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({deleted_at: new Date()}))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createDeleteRequest({
          user_id: '20',
          _id: storage.container._id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(404)
        done()
      .or((err) -> console.error(err))

  beforeEach (done) ->
    utils.emptyColection(Container, done)
