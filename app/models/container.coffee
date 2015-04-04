mongoose = require('mongoose')

ContainerSchema = new mongoose.Schema({
  name: {type: String, required: true},
  storage_namespace: {type: String, unique: true},
  user_id: {type: String, required: true},
  created_at: {type: Date, default: Date.now, required: true},
  updated_at: {type: Date, default: Date.now, required: true},
  deleted_at: Date
})

ContainerSchema.methods.generateStorageNamespace = ->
  c = require('bcrypt')
  @storage_namespace = c.hashSync(@name + @user_id, c.genSaltSync())

Container = mongoose.model('Container', ContainerSchema)

module.exports = Container
