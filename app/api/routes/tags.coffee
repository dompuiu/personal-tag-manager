TagCreate = require('../modules/tags/tag_create')
TagUpdate = require('../modules/tags/tag_update')

module.exports = [
  new TagCreate().route()
  new TagUpdate().route()
]

