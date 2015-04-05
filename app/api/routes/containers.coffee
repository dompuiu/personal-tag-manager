ContainerCreate = require('../modules/containers/container_create')
ContainerDelete = require('../modules/containers/container_delete')

module.exports = [
  new ContainerCreate().route()
  new ContainerDelete().route()
]

