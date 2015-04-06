'use strict'

describe 'ContainersUpdateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api/routes/containers')
  faker = require('faker')
  Container = require('../../../../app/models/container')
  utils = require('../../../utils')

  createUpdateRequest = (container) ->
    options = {
      method: 'POST'
      url: '/containers/'
      headers: {'Content-Type': 'application/json'}
      payload: {id: container._id, name: container.name}
      credentials: {name: 'user name', id: container.user_id}
    }

  it 'should update a container', (done) ->
    ASQ(utils.createContainer({name: 'some name'}))
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createUpdateRequest({
            _id: container._id
            name: 'some updated name'
            user_id: container.user_id
          })))
        .val((server, response) ->
          expect(response.statusCode).to.equal(200)
          Container.findOne({_id: container._id}, (err, container) ->
            expect(container.name).to.equal('some updated name')
            done()
          )
        )
      )

  it 'should refresh updated_at field on any update', (done) ->
    ASQ(utils.createContainer({updated_at: new Date('2013-01-01')}))
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createUpdateRequest(container)))
        .val((server, response) ->
          Container.findOne({_id: container._id}, (err, container) ->
            updated_at = container.updated_at
            now = new Date()

            expect(updated_at.getYear()).to.equal(now.getYear())
            expect(updated_at.getMonth()).to.equal(now.getMonth())
            done()
          )
        )
      )

  it 'should not accept un invalid object id', (done) ->
    ASQ(utils.configureServer(routes))
    .then(utils.makeRequest(createUpdateRequest(
      {
        user_id: '10'
        name: 'some name'
        _id: '111'
      }
    )))
    .val((server, response) ->
      expect(response.statusCode).to.equal(400)
      done()
    )

  it 'should not update an unexisting container', (done) ->
    ASQ(utils.configureServer(routes))
    .then(utils.makeRequest(createUpdateRequest(
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

  it 'should not update an deleted container', (done) ->
    ASQ(utils.createContainer({deleted_at: new Date('2013-01-01')}))
      .val((container) ->
        ASQ(utils.configureServer(routes))
        .then(utils.makeRequest(createUpdateRequest(
          {
            user_id: container.user_id
            name: 'some updated name'
            _id: container._id
          }
        )))
        .val((server, response) ->
          expect(response.statusCode).to.equal(404)
          done()
        )
      )

  it 'should allow updating only containers they own', (done) ->
    ASQ(utils.createContainer()).val((container) ->
      request = createUpdateRequest({
        user_id: '20'
        name: 'some updated name'
        _id: container._id
      })

      ASQ(utils.configureServer(routes))
      .then(utils.makeRequest(request))
      .val((server, response) ->
        expect(response.statusCode).to.equal(401)
        done()
      )
    )

  before((done) ->
    utils.emptyColection(Container, done)
  )



