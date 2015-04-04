Joi = require('joi')

ContainerSchema = Joi.object({
  id: Joi.string().required().description('Container ID')
  name: Joi.string().required().description('Container name')
  storage_namespace:
    Joi.string().required().description('Storage folder name')
  user_id: Joi.string().required().description('User ID (owner)')
  created_at: Joi.string().required().isoDate().description('ISO date string')
  updated_at: Joi.string().isoDate().description('ISO date string')
}).meta({
  className: 'ContainerSchema'
})

module.exports = ContainerSchema
