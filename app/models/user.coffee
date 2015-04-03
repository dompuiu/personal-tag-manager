mongoose = require('mongoose')

userSchema = mongoose.Schema({
  name: String,
  email: String,
  password: String,
  created_at: Date,
  updated_at: Date,
  deleted_at: Date
})

User = mongoose.Model(userSchema)

module.exports = User
