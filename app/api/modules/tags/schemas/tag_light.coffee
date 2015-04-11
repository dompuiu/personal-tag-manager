Joi = require('joi')

TagLightSchema = Joi.object({
  id: Joi.string().required().description('Tag ID')
  container_id: Joi.string().required().description('Container ID')
  version_id: Joi.string().required().description('Version ID')
  name: Joi.string().required().description('Tag name')
  type: Joi.string().required().description('Tag Type')
  updated_at: Joi.string().isoDate().description('ISO date string')
}).meta({
  className: 'TagLightSchema'
})

module.exports = TagLightSchema
