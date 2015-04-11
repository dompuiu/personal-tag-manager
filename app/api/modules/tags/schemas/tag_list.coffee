Joi = require('joi')
TagLightSchema = require('./tag_light')

TagListSchema = Joi.object({
  items: Joi.array().required()
    .items(TagLightSchema).description('Tag list')
  count: Joi.number().required().description('Count of returned items')
}).meta({
  className: 'TagListSchema'
})

module.exports = TagListSchema
