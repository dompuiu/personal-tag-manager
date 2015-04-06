ContainerCreate = require('../modules/containers/container_create')
ContainerDelete = require('../modules/containers/container_delete')
ContainerUpdate = require('../modules/containers/container_update')

module.exports = [
  new ContainerCreate().route()
  new ContainerDelete().route()
  new ContainerUpdate().route()
]

