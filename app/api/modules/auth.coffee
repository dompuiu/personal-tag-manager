Bcrypt = require('bcrypt')
Basic = require('hapi-auth-basic')
User = require('../../models/user')

users = {
  john: {
    username: 'john'
    password:
      '$2a$10$iqJSHD.BGr0E2IxQwYgJmeP3NvhPrXAeLSaGCj6IR/XU5QtjVu5Tm'
    name: 'John Doe'
    id: '2133d32a'
  }
}

validate = (username, password, callback) ->
  user = users[username]
  query = User.findOne({'email': username}).exec((err, user) ->
    return callback(null, false) if err

    Bcrypt.compare(password, user.password, (err, isValid) ->
      console.log(password, user.password)
      callback(err, isValid, {id: user.id, name: user.name})
    )
  )

module.exports = (server) ->
  server.register(Basic, (err) ->
    server.auth.strategy('simple', 'basic', {validateFunc: validate})
    )


