'use strict'

describe 'UserLoginTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  _ = require('lodash')

  routes = require('../../../../app/api_app/api/routes/users')
  utils = require('../../../helpers/api_utils')
  User = require('../../../../app/api_app/models/user')

  userLoginRequest = (data = {}) ->
    options = {
      method: 'POST'
      url: '/users/login/'
      headers: {'Content-Type': 'application/json'}
      payload: {
        email: data.email || faker.internet.email()
        password: data.password || faker.internet.password()
      }
    }

  it 'should return unauthorized for a non existing email', (done) ->
    ASQ({routes: routes, request: userLoginRequest()})
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        expect(storage.response.statusCode).to.equal(401)

        done()

  it 'should return unauthorized for wrong password', (done) ->
    ASQ({routes: routes})
      .then(utils.createUser())
      .then((done, storage) ->
        storage.request = userLoginRequest({
          email: storage.user.email
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result
        expect(storage.response.statusCode).to.equal(401)

        done()

  it 'should return 200 for correct password', (done) ->
    ASQ({routes: routes})
      .then(utils.createUser({password: User.makePassword('qwe123')}))
      .then((done, storage) ->
        storage.request = userLoginRequest({
          email: storage.user.email
          password: 'qwe123'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result
        expect(storage.response.statusCode).to.equal(200)

        done()

  it 'should return unauthorized for deleted users', (done) ->
    ASQ({routes: routes})
      .then(utils.createUser({
        password: User.makePassword('qwe123'),
        deleted_at: new Date()
      }))
      .then((done, storage) ->
        storage.request = userLoginRequest({
          email: storage.user.email
          password: 'qwe123'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result
        expect(storage.response.statusCode).to.equal(401)

        done()

  beforeEach (done) ->
    utils.emptyColection(User, done)
