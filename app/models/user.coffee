mongoose = require('mongoose')

userSchema = new mongoose.Schema({
  name: String,
  email: {type: String, unique: true},
  password: String,
  created_at: Date,
  updated_at: {type: Date, default: Date.now},
  deleted_at: Date
})

userSchema.statics.makePassword = (password) ->
  crypto = require('crypto')
  return crypto.createHash('md5').update(password).digest('hex')

User = mongoose.model('User', userSchema)

module.exports = User
