Joi = require('joi')

ContainerDeleteSchema = Joi.object({
  result: Joi.boolean().required().description('Operation result')
  message: Joi.string().required().description('Message')
}).meta({
  className: 'ContainerDeleteSchema'
})

module.exports = ContainerDeleteSchema
