mongoose = require('mongoose')
db_sufix = process.env.DB_SUFFIX || '_test'

Database = {
  connection_string: "mongodb://localhost/personal_tag_manager#{db_sufix}",
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
