Good = require('good')
ASQ = require('asynquence')

registerLog = (done, storage) ->
  config = {
    register: Good,
    options: {
      reporters: [{
        reporter: require('good-console'),
        events: {
          error: '*',
          request: '*',
          log: 'error'
        }
      }]
    }
  }

  storage.server.register(config, onRegister(done, storage))

onRegister = (done, storage) ->
  (err) ->
    if err
      storage.server.log(['error'], 'log load error: ' + err)
      done.fail(err)
    else
      storage.server.log(['start'], 'log interface loaded')
      done(storage)


module.exports = {
  register: (done, storage) ->
    ASQ({server: storage.server})
      .then(registerLog)
      .val((storage) -> done(storage))
      .or((err) -> done.fail(err))
}
