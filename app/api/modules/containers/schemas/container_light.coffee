Joi = require('joi')

ContainerLightSchema = Joi.object({
  id: Joi.string().required().description('Container ID')
  name: Joi.string().required().description('Container name')
}).meta({
  className: 'ContainerSchema'
})

module.exports = ContainerLightSchema
