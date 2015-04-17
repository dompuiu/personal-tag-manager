Joi = require('joi')
VersionSchema = require('./version')

VersionListSchema = Joi.object({
  items: Joi.array().required()\
    .items(VersionSchema).description('Version list')
  count: Joi.number().required().description('Count of returned items')
}).meta({
  className: 'VersionListSchema'
})

module.exports = VersionListSchema
