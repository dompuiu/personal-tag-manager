Joi = require('joi')

module.exports = (server) ->
  server.route({
    method: 'GET'
    path:'/hello/{id}/'
    config: {
      description: 'Hello'
      notes: 'Returns a todo item by the id passed in the path'
      tags: ['api']
      auth: 'simple'
      validate: {
        params: {
          id: Joi.number().required()
            .description('the id for the todo item'),
        }
      }
    }
    handler: (request, reply) ->
      console.log(request.headers)
      reply('hello world')
  })

