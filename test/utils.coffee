Database = require('../app/database/connection')
ASQ = require('asynquence')
Container = require('../app/models/container')

class CollectionEmptyer
  constructor: (data, done) ->
    @data = data
    @done = done

  dropAll: (done) ->
    Database.openConnection((connection) =>
      segments = @data.map(@deleteItem)

      ASQ()
        .all.apply(null, segments)
        .val(@operationResult.bind(this))
    )

  deleteItem: (item) ->
    return ASQ((done) ->
      item.remove((err) ->
        throw new Error(err) if err
        done()
      )
    )

  operationResult: ->
    @done()


module.exports = {
  emptyColection: (collection, done) ->
    collection.find((err, items) ->
      throw new Error(err) if err
      new CollectionEmptyer(items, done).dropAll()
    )
}
