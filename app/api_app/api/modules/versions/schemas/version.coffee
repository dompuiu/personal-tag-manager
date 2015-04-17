Joi = require('joi')

VersionSchema = Joi.object({
  id: Joi.string().required().description('Version ID')
  container_id: Joi.string().required().description('Container ID')
  version_number: Joi.number().required().description('Verion Number')
  status: Joi.string().required().description('Version Status')
  created_at: Joi.string().isoDate().description('ISO date string')
  published_at: Joi.string().isoDate().description('ISO date string')
}).meta({
  className: 'VersionSchema'
})

module.exports = VersionSchema
