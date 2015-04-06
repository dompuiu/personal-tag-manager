'use strict'

describe 'ContainersDeleteTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createDeleteRequest = (container) ->
    options = {
      method: 'DELETE'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {id: container._id}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should delete a container', (done) ->
    ASQ(utils.createContainer())
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createDeleteRequest(container)))
        .val((server, response) ->
          expect(response.statusCode).to.equal(200)
          Container.findOne({_id: container._id}, (err, container) ->
            expect(container.deleted_at).to.exist
            done()
          )
        )
      )

  it 'should not accept un invalid object id', (done) ->
    ASQ(utils.configureServer(routes))
    .then(utils.makeRequest(createDeleteRequest(
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
    ASQ(utils.configureServer(routes))
    .then(utils.makeRequest(createDeleteRequest(
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
    ASQ(utils.createContainer())
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createDeleteRequest(
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

  it 'should not allow deletion of already deleted containers', (done) ->
    ASQ(utils.createContainer({deleted_at: new Date()}))
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createDeleteRequest(
          {
            user_id: '20',
            _id: container._id
          }
        )))
        .val((server, response) ->
          expect(response.statusCode).to.equal(404)
          done()
        )
      )

  before((done) ->
    utils.emptyColection(Container, done)
  )



