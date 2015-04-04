Joi = require('joi')
Container = require('../models/container')

class CreateContainerCommand
  constructor: (@data) ->
    Joi.assert(
      @data.name,
      Joi.string().required().regex(/^[A-Za-z0-9 -]+$/).min(5)
    )

    Joi.assert(
      @data.user_id,
      Joi.string().required()
    )

  run: ->
    c = new Container(@data)
    c.generateStorageNamespace()

    console.log(c)



module.exports = CreateContainerCommand
