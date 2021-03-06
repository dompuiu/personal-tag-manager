Database = require('../connection')
User = require('../../models/user')
ASQ = require('asynquence')

class UserSeeder
  constructor: (data) ->
    @data = data
  import: ->
    ASQ(@checkUsersAlreadyExists)
      .then(@dropAllUsers)
      .then(@insertAll)
      .or((err) -> console.log(err); Database.closeConnection())

  checkUsersAlreadyExists: (done) ->
    Database.openConnection((connection) ->
      User.count((err, count) ->
        if process.argv[2] != '--force' && count > 0
          done.fail('Users table has already been seeded')
        else
          done()
      )
    )

  dropAllUsers: (done) ->
    Database.openConnection((connection) ->
      connection.db.dropCollection('users', done)
    )

  insertAll: (done) =>
    Database.openConnection((connection) =>
      segments = @data.map(@insertUser)

      ASQ()
        .all.apply(null, segments)
        .val(@operationResult)
        .or(@operationResult)
    )

  insertUser: (user_data) ->
    return ASQ((done) ->
      u = new User(user_data)

      u.save((err, u) ->
        if err
          done([
            'Failed to insert user:',
            JSON.stringify(user_data),
            'Reason:',
            err.message].join(' '))
        else
          done('Inserted user: ' + JSON.stringify(user_data))
      )
    )

  operationResult: ->
    args = Array.prototype.slice.call(arguments)

    args.forEach((item) -> console.log(item))
    Database.closeConnection()


users = [{
  name: 'Admin user',
  email: 'admin@somedomain.com',
  password: User.makePassword('admin')
}, {
  name: 'First User',
  email: 'first.user@email.com',
  password: User.makePassword('qwe123')
}, {
  name: 'Second User',
  email: 'second.user@email.com',
  password: User.makePassword('qwe123')
}]

new UserSeeder(users).import()
