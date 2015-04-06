'use strict'

describe 'ContainersUpdateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  faker = require('faker')
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

  createUpdateRequest = (container) ->
    options = {
      method: 'POST'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {id: container._id, name: 'some updated name'}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should update a container', (done) ->
    ASQ(createContainer('some name'))
      .val((container) ->
        ASQ(configureServer)
        .then(makeRequest(createUpdateRequest(container)))
        .val((server, response) ->
          expect(response.statusCode).to.equal(200)
          Container.findOne({_id: container._id}, (err, container) ->
            expect(container.name).to.equal('some updated name')
            done()
          )
        )
      )

  it 'should not accept un invalid object id', (done) ->
    ASQ(configureServer)
    .then(makeRequest(createUpdateRequest(
      {
        user_id: '10'
        _id: '111'
      }
    )))
    .val((server, response) ->
      expect(response.statusCode).to.equal(400)
      done()
    )

  it 'should not delete an unexisting container', (done) ->
    ASQ(configureServer)
    .then(makeRequest(createUpdateRequest(
      {
        user_id: '10'
        name: 'some updated name'
        _id: '00219cdb4fd2759a0b228099'
      }
    )))
    .val((server, response) ->
      expect(response.statusCode).to.equal(404)
      done()
    )


  it 'should allow deleting only containers they own', (done) ->
    ASQ(createContainer())
      .val((container) ->
        ASQ(configureServer)
        .then(makeRequest(createUpdateRequest(
          {
            user_id: '20'
            name: 'some updated name'
            _id: container._id
          }
        )))
        .val((server, response) ->
          expect(response.statusCode).to.equal(401)
          done()
        )
      )

  before((done) ->
    d = require('../../../utils')

    d.emptyColection(Container, done)
  )



