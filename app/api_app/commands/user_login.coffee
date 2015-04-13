Bcrypt = require('bcrypt')
Joi = require('joi')
Boom = require('boom')
_ = require('lodash')
User = require('../models/user')

ASQ = require('asynquence')
Server = require('../api/server')

class UserLoginCommand
  constructor: (@data) ->
    Joi.assert(
      @data.email,
      Joi.string().email().required()
    )

    Joi.assert(
      @data.password,
      Joi.string().required()
    )

    Server.get((server) => @server = server)

  run: (done) ->
    ASQ({data: @data})
      .then(@findUser)
      .then(@checkPassword)
      .val( -> done(null, {result: true}))
      .or((err) -> done(err, null))

  findUser: (done, storage) =>
    User.findOne({
      'email': storage.data.email,
      deleted_at: {$exists: false}
    }, @onFind(done, storage))

  onFind: (done, storage) =>
    (err, user) =>
      if err
        @server.log(['error', 'database'], err)
        return done.fail(
          Boom.badImplementation('Cannot read from database')
        )

      unless user
        return done.fail(Boom.unauthorized('Unauthorized'))

      storage.user = user
      done(storage)

  checkPassword: (done, storage) =>
    Bcrypt.compare(
      storage.data.password,
      storage.user.password,
      @onCompareFinished(done, storage)
    )

  onCompareFinished: (done, storage) ->
    (err, isValid) ->
      if err
        @server.log(['error'], err)
        return done.fail(
          Boom.badImplementation('Cannot compare values')
        )

      unless isValid
        return done.fail(Boom.unauthorized('Unauthorized'))

      done(storage)

module.exports = UserLoginCommand
