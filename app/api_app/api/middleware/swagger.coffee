ASQ = require('asynquence')

registerHapiSwagger = (done, storage) ->
  config = {
    register: require('hapi-swagger'),
    options: {
      apiVersion: '1.0'
      info: {
        title: 'Personal Tag Manager API'
        description: 'API pentru lucrarea de licenta'
      }
    }
  }

  storage.server.register(config, onRegister(done, storage))

onRegister = (done, storage) ->
  (err) ->
    if err
      storage.server.log(['error'], 'hapi-swagger load error: ' + err)
      done.fail(err)
    else
      storage.server.log(['start'], 'hapi-swagger interface loaded')
      done(storage)


module.exports = {
  register: (done, storage) ->
    ASQ({server: storage.server})
      .then(registerHapiSwagger)
      .val((storage) -> done(storage))
      .or((err) -> done.fail(err))
}
