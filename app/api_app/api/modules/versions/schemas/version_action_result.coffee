Joi = require('joi')

VersionAtionResultSchema = Joi.object({
  result: Joi.boolean().required().description('Operation result')
  message: Joi.string().required().description('Message')
}).meta({
  className: 'VersionAtionResultSchema'
})

module.exports = VersionAtionResultSchema
