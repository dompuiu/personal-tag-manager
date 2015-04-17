VersionInfo = require('../modules/versions/version_info')
VersionList = require('../modules/versions/version_list')

module.exports = [
  new VersionInfo().route()
  new VersionList().route()
]

