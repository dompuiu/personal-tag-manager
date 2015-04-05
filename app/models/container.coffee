mongoose = require('mongoose')
_ = require('lodash')
bcrypt = require('bcrypt')

ContainerSchema = new mongoose.Schema({
  name: {type: String, required: true},
  storage_namespace: {type: String, unique: true},
  user_id: {type: String, required: true},
  created_at: {type: Date, default: Date.now, required: true},
  updated_at: {type: Date, default: Date.now, required: true},
  deleted_at: Date
})

ContainerSchema.methods.generateStorageNamespace = ->
  c = require('crypto')
  key = @name + @user_id + bcrypt.genSaltSync()
  @storage_namespace =
    c.createHash('md5').update(key).digest('hex')

ContainerSchema.methods.toSwaggerFormat = ->
  container = this

  data = _.pick(container, ['name', 'storage_namespace', 'user_id'])

  data.id = container._id.toString()
  data.created_at = container.created_at.toISOString()
  data.updated_at = container.updated_at.toISOString()

  return data

Container = mongoose.model('Container', ContainerSchema)

module.exports = Container
