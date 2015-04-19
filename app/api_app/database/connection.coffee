mongoose = require('mongoose')
db_sufix = process.env.DB_SUFFIX || '_test'
db_connection_string = process.env.DB_CONNECTION_STRING

Database = {
  connection_string: "#{db_connection_string}#{db_sufix}",
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

process.on('SIGINT', ->
  Database.closeConnection()
  process.exit(0)
)

module.exports = Database
