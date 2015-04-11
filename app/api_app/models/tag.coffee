mongoose = require('mongoose')
_ = require('lodash')

TagSchema = new mongoose.Schema({
  container_id: {type: mongoose.Schema.ObjectId, required: true},
  version_id: {type: mongoose.Schema.ObjectId, required: true},
  user_id: {type: String, required: true},
  name: {type: String, required: true},
  dom_id: {type: String, required: true},
  type: {type: String, required: true},
  src: {type: String},
  on_load: {type: String},
  created_at: {type: Date, default: Date.now},
  updated_at: {type: Date, default: Date.now}
})

TagSchema.methods.toSwaggerFormat = ->
  tag = this

  data = _.pick(tag,
    [
      'user_id',
      'name',
      'dom_id',
      'type',
      'src',
      'on_load'
    ]
  )

  data.id = tag._id.toString()
  data.container_id = tag.container_id.toString()
  data.version_id = tag.version_id.toString()
  data.created_at = tag.created_at.toISOString()
  data.updated_at = tag.updated_at.toISOString()

  return data


Tag = mongoose.model('Tag', TagSchema)

module.exports = Tag
