ContainerCreate = require('../modules/containers/container_create')
ContainerDelete = require('../modules/containers/container_delete')
ContainerUpdate = require('../modules/containers/container_update')
ContainersList = require('../modules/containers/container_list')
ContainerShow = require('../modules/containers/container_show')

module.exports = [
  new ContainerCreate().route()
  new ContainerDelete().route()
  new ContainerUpdate().route()
  new ContainerShow().route()
  new ContainersList().route()
]

