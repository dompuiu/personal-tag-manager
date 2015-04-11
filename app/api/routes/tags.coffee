TagCreate = require('../modules/tags/tag_create')
TagUpdate = require('../modules/tags/tag_update')
TagDelete = require('../modules/tags/tag_delete')

module.exports = [
  new TagCreate().route()
  new TagUpdate().route()
  new TagDelete().route()
]

