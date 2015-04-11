Joi = require('joi')
ContainerLightSchema = require('./container_light')

ContainerListSchema = Joi.object({
  items: Joi.array().required()
    .items(ContainerLightSchema).description('Container list')
  count: Joi.number().required().description('Count of returned items')
}).meta({
  className: 'ContainerListSchema'
})

module.exports = ContainerListSchema
