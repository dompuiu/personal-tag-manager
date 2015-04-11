Joi = require('joi')

TagDeleteSchema = Joi.object({
  result: Joi.boolean().required().description('Operation result')
  message: Joi.string().required().description('Message')
}).meta({
  className: 'TagDeleteSchema'
})

module.exports = TagDeleteSchema
