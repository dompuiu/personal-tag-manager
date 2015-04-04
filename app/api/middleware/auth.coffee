Bcrypt = require('bcrypt')
Basic = require('hapi-auth-basic')
User = require('../../models/user')

authenticated_user = null

validate = (username, password, callback) ->
  query = User.findOne({'email': username}).exec((err, user) ->
    return callback(null, false) if err or !user

    Bcrypt.compare(password, user.password, (err, isValid) ->
      authenticated_user = user if isValid
      callback(err, isValid, {id: user.id, name: user.name})
    )
  )

module.exports = {
  register: (server) ->
    server.register(Basic, (err) ->
      server.auth.strategy('simple', 'basic', {validateFunc: validate})
    )
}


