'use strict'

describe 'ContainersUpdateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createUpdateRequest = (container) ->
    payload = {}
    payload.name = container.name if container.name
    payload.domain = container.domain if container.domain

    options = {
      method: 'PUT'
      url: "/containers/#{container._id}/"
      headers: {'Content-Type': 'application/json'}
      payload: payload
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should update the container domain', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createUpdateRequest({
          _id: storage.container._id
          domain: 'someupdateddomain.com'
          user_id: storage.container.user_id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(200)
        Container.findOne {_id: storage.container._id}, (err, container) ->
          expect(container.domain).to.equal('someupdateddomain.com')
          done()
      .or((err) -> console.error(err))

  it 'should update the container name', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createUpdateRequest({
          _id: storage.container._id
          name: 'some updated name'
          user_id: storage.container.user_id
        })
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(200)
        Container.findOne {_id: storage.container._id}, (err, container) ->
          expect(container.name).to.equal('some updated name')
          done()
      .or((err) -> console.error(err))

  it 'should refresh updated_at field on any update', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({updated_at: new Date('2013-01-01')}))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createUpdateRequest(storage.container)
        done(storage)
      )
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        Container.findOne storage.container._id, (err, container) ->
          updated_at = container.updated_at
          now = new Date()

          expect(updated_at.getYear()).to.equal(now.getYear())
          expect(updated_at.getMonth()).to.equal(now.getMonth())
          done()
      .or((err) -> console.error(err))

  it 'should not accept un invalid object id', (done) ->
    request = createUpdateRequest({
      user_id: '10'
      name: 'some name'
      _id: '111'
    })

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response
        expect(response.statusCode).to.equal(400)
        done()

  it 'should not update an unexisting container', (done) ->
    request = createUpdateRequest({
      user_id: '10'
      name: 'some updated name'
      _id: '00219cdb4fd2759a0b228099'
    })

    ASQ({routes: routes, request: request})
      .then(utils.configureServer)
      .then(utils.makeRequest)
      .val (storage) ->
        response = storage.response

        expect(response.statusCode).to.equal(404)
        done()
      .or((err) -> console.error(err))

  it 'should not update an deleted container', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({deleted_at: new Date('2013-01-01')}))
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createUpdateRequest({
          user_id: storage.container.user_id
          name: 'some updated name'
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

  it 'should allow updating only containers they own', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.configureServer)
      .then((done, storage) ->
        storage.request = createUpdateRequest({
          user_id: '20'
          name: 'some updated name'
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

  beforeEach (done) ->
    utils.emptyColection(Container, done)
