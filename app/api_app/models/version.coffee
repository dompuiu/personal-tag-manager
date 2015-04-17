mongoose = require('mongoose')
_ = require('lodash')
bcrypt = require('bcrypt')

VersionSchema = new mongoose.Schema({
  version_number: {type: Number, required: true, index: true},
  container_id: {type: mongoose.Schema.ObjectId, required: true},
  user_id: {type: String, required: true},
  status: {type: String},
  created_at: {type: Date, default: Date.now},
  published_at: {type: Date}
})

VersionSchema.statics.generateNewVersionNumber = (container_id, done) ->
  Version.count({container_id: container_id}, (err, count) ->
    if err
      done(err, null)
    else
      done(null, count + 1)
  )

VersionSchema.methods.toSwaggerFormat = ->
  version = this

  data = _.pick(version,
    [
      'user_id',
      'status',
      'version_number'
    ]
  )

  data.id = version._id.toString()
  data.container_id = version.container_id.toString()
  data.created_at = version.created_at.toISOString()

  if (version.published_at)
    data.published_at = version.published_at.toISOString()

  return data

Version = mongoose.model('Version', VersionSchema)

module.exports = Version
