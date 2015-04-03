mongoose = require('mongoose')

Database = {
  connection_string: 'mongodb://localhost/personal_tag_manager',
  connection: null,

  openConnection: (done) ->
    if @connection
      return done(@connection)

    @connect()

    @connection = mongoose.connection
    @connection.once('open', =>
      console.log('Connected to Mongo.')
      done(@connection)
    )

  closeConnection: ->
    console.log('Disconnected from Mongo.')
    @connection.close()

  connect: ->
    mongoose.connect(@connection_string)
}

module.exports = Database
