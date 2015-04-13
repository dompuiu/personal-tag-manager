UserLogin = require('../modules/users/user_login')

module.exports = [
  new UserLogin().route()
]

