Joi = require('joi')

ContainerLightSchema = Joi.object({
  id: Joi.string().required().description('Container ID')
  name: Joi.string().required().description('Container name')
}).meta({
  className: 'ContainerLightSchema'
})

module.exports = ContainerLightSchema
