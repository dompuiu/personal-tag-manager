Bcrypt = require('bcrypt')
Basic = require('hapi-auth-basic')
User = require('../../models/user')
ASQ = require('asynquence')

authenticated_user = null

validate = (username, password, callback) ->
  User.findOne({'email': username}).exec((err, user) ->
    return callback(null, false) if err or !user

    Bcrypt.compare(password, user.password, (err, isValid) ->
      authenticated_user = user if isValid
      callback(err, isValid, {id: user.id, name: user.name})
    )
  )

registerAuth = (done, storage) ->
  storage.server.register(Basic, onRegister(done, storage))

onRegister = (done, storage) ->
  (err) ->
    if err
      storage.server.log(['error'], 'auth load error: ' + err)
      done.fail(err)
    else
      storage.server.auth.strategy('simple', 'basic', {validateFunc: validate})
      storage.server.log(['start'], 'auth interface loaded')
      done(storage)


module.exports = {
  register: (done, storage) ->
    ASQ({server: storage.server})
      .then(registerAuth)
      .val((storage) -> done(storage))
      .or((err) -> done.fail(err))
}


