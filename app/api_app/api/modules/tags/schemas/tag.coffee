Joi = require('joi')

TagSchema = Joi.object({
  id: Joi.string().required().description('Tag ID')
  container_id: Joi.string().required().description('Container ID')
  version_id: Joi.string().required().description('Version ID')
  user_id: Joi.string().required().description('User ID (owner)')
  name: Joi.string().required().description('Tag name')
  dom_id: Joi.string().required().description('Tag DOM Id')
  type: Joi.string().required().description('Tag Type')
  src: Joi.string().required().description('Tag source')
  onload: Joi.string().description('Code to be executed after tag load')
  inject_position: Joi.number().description('Tag trigger position')
  match: Joi.array().items(
    Joi.object().keys({
      condition: Joi.string().required()\
        .allow('contains', 'daterange', 'dow', 'regex')
      not: Joi.boolean().required()
      param: Joi.string().required()\
        .allow('host', 'path', 'cookie', 'query', 'date')
      param_name: Joi.any().required()
      values: Joi.object().keys({
        days: Joi.array().items(Joi.number()).max(7).unique()
        min: Joi.string()
        max: Joi.string()
        scalar: Joi.string()
      }).required()
    })
  ).description('Trigger type object')
  created_at: Joi.string().required().isoDate().description('ISO date string')
  updated_at: Joi.string().isoDate().description('ISO date string')
}).meta({
  className: 'TagSchema'
})

module.exports = TagSchema
