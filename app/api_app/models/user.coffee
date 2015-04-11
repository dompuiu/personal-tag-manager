mongoose = require('mongoose')

UserSchema = new mongoose.Schema({
  name: {type: String, required: true},
  email: {type: String, unique: true},
  password: {type: String, required: true},
  created_at: {type: Date, default: Date.now},
  updated_at: {type: Date, default: Date.now},
  deleted_at: Date
})

UserSchema.statics.makePassword = (password) ->
  bcrypt = require('bcrypt')
  return bcrypt.hashSync(password, bcrypt.genSaltSync())

User = mongoose.model('User', UserSchema)

module.exports = User
