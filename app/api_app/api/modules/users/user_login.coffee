_ = require('lodash')
Joi = require('joi')
ASQ = require('asynquence')
Server = require('../../server')
UserLoginSchema = require('./schemas/user_login')
UserLoginCommand = require('../../../commands/user_login')

class UserLogin
  route: ->
    {
      method: 'POST'
      path: '/users/login/'
      config: @config()
      handler: @handler
    }

  config: ->
    {
      description: 'Login a new user'
      notes: 'Returns a message containing the login token'
      tags: ['api']
      plugins: {
        'hapi-swagger': {
          responseMessages: [
            {code: 200, message: 'OK'}
            {code: 400, message: 'Bad Request'}
            {code: 401, message: 'Unauthorized'}
            {code: 500, message: 'Internal Server Error'}
          ]
        }
      }
      validate: @validate()
      response: {
        schema : UserLoginSchema
      }
    }

  validate: ->
    {
      payload: {
        email: Joi.string().email().required()\
          .description('Email').example('admin@somedomain.com')

        password: Joi.string().required()\
          .description('Password')
      }
    }

  handler: (request, reply) ->
    data = _.pick(request.payload, 'email', 'password')
    new UserLoginCommand(data).run(reply)

module.exports = UserLogin
