Joi = require('joi')

VersionInfoSchema = Joi.object({
  editing: Joi.object().required().keys({
    version_id: Joi.string().required().description('Editing Version Id'),
    version_number: Joi.number().required()\
      .description('Editing Version Number')
    created_at: Joi.string().isoDate().required().description('ISO date string')
    tags_count: Joi.number().required()\
      .description('Tags in the editing version')
  }),
  published: Joi.object().keys({
    version_id: Joi.string().description('Published Version Id'),
    version_number: Joi.number().description('Published Version Number')
    published_at: Joi.string().isoDate().description('ISO date string')
    tags_count: Joi.number().description('Tags in the published version')
  })
}).meta({
  className: 'VersionInfoSchema'
})

module.exports = VersionInfoSchema
