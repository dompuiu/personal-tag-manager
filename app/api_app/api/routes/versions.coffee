VersionInfo = require('../modules/versions/version_info')
VersionList = require('../modules/versions/version_list')
VersionPublish = require('../modules/versions/version_publish')
VersionEditAsNew = require('../modules/versions/version_editasnew')

module.exports = [
  new VersionInfo().route()
  new VersionList().route()
  new VersionPublish().route()
  new VersionEditAsNew().route()
]

