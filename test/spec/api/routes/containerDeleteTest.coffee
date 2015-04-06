'use strict'

describe 'ContainersDeleteTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  faker = require('faker')
  Container = require('../../../../app/models/container')

  createContainer = (done) ->
    c = new Container({
      name: faker.name.findName(),
      user_id: faker.helpers.randomNumber(10)
      storage_namespace: faker.lorem.sentence()
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

  createDeleteRequest = (container) ->
    options = {
      method: 'DELETE'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {id: container._id}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should delete a container', (done) ->
    ASQ(createContainer)
      .val((container) ->
        ASQ(configureServer)
        .then(makeRequest(createDeleteRequest(container)))
        .val((server, response) ->
          expect(response.statusCode).to.equal(200)
          Container.findOne({_id: container._id}, (err, container) ->
            expect(container.deleted_at).to.exist
            done()
          )
        )
      )

  it 'should not accept un invalid object id', (done) ->
    ASQ(configureServer)
    .then(makeRequest(createDeleteRequest(
      {
        user_id: '10',
        _id: '111'
      }
    )))
    .val((server, response) ->
      expect(response.statusCode).to.equal(400)
      done()
    )

  it 'should not delete an unexisting container', (done) ->
    ASQ(configureServer)
    .then(makeRequest(createDeleteRequest(
      {
        user_id: '10',
        _id: '00219cdb4fd2759a0b228099'
      }
    )))
    .val((server, response) ->
      expect(response.statusCode).to.equal(404)
      done()
    )


  it 'should allow deleting only containers they own', (done) ->
    ASQ(createContainer)
      .val((container) ->
        ASQ(configureServer)
        .then(makeRequest(createDeleteRequest(
          {
            user_id: '20',
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



