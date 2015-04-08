mongoose = require('mongoose')
_ = require('lodash')
bcrypt = require('bcrypt')

VersionSchema = new mongoose.Schema({
  version_id: {type: Number, required: true},
  container_id: {type: mongoose.Schema.ObjectId, required: true},
  user_id: {type: String, required: true},
  status: {type: String},
  created_at: {type: Date, default: Date.now},
  published_at: {type: Date}
})

VersionSchema.statics.generateNewVersionId = (container_id, done) ->
  Version.count({container_id: container_id}, (err, count) ->
    if err && done.fail
      done.fail(err)
    else if err
      done(err)
    else
      done(count + 1)
  )

Version = mongoose.model('Version', VersionSchema)

module.exports = Version
