TagCreate = require('../modules/tags/tag_create')
TagUpdate = require('../modules/tags/tag_update')
TagDelete = require('../modules/tags/tag_delete')
TagShow = require('../modules/tags/tag_show')
TagsList = require('../modules/tags/tag_list')

module.exports = [
  new TagCreate().route()
  new TagUpdate().route()
  new TagDelete().route()
  new TagShow().route()
  new TagsList().route()
]

