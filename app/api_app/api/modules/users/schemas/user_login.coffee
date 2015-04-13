Joi = require('joi')

UserLoginSchema = Joi.object({
  result: Joi.boolean().required().description('Operation result')
}).meta({
  className: 'UserLoginSchema'
})

module.exports = UserLoginSchema
