Database = require('../connection')
User = require('../../models/user')
ASQ = require('asynquence')

class UserSeeder
  constructor: (data) ->
    @data = data
  import: ->
    ASQ(@dropAllUsers.bind(this)).then(@insertAll.bind(this))

  dropAllUsers: (done) ->
    Database.openConnection((connection) ->
      connection.db.dropCollection('users', done)
    )

  insertAll: (done) ->
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
  name: 'Serban Stancu',
  email: 'serban.stancu@yahoo.com',
  password: User.makePassword('qwe123'),
  created_at: new Date('2014-01-01')
}, {
  name: 'First User',
  email: 'first.user@email.com',
  password: User.makePassword('qwe123'),
  created_at: new Date('2015-01-01')
}, {
  name: 'Second User',
  email: 'second.user@email.com',
  password: User.makePassword('qwe123'),
  created_at: new Date('2015-01-01')
}]

new UserSeeder(users).import()
