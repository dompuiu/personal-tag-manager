'use strict'

describe 'TagsCreateTest', ->
  _ = require('lodash')
  expect = require('chai').expect
  ASQ = require('asynquence')
  faker = require('faker')
  routes = require('../../../../app/api_app/api/routes/tags')
  utils = require('../../../helpers/api_utils')

  createTagRequest = (data) ->
    url_data = _.pick(data, 'container_id', 'version_id', 'user_id')
    data = _.omit(data, 'container_id', 'version_id', 'user_id')

    options = {
      method: 'POST'
      url: "/containers/#{url_data.container_id}/versions\
      /#{url_data.version_id}/tags/"
      headers: {'Content-Type': 'application/json'}

      payload: _.merge({
        name: faker.name.firstName()
        dom_id: faker.internet.userName()
        type: 'html'
        src: '<div>some html code</div>'
        inject_position: 1
        match: [{
          condition: 'dow'
          not: false
          param: 'date'
          param_name: false
          values: {
            days: [1, 2, 3]
          }
        }]
      }, data)

      credentials: {name: 'user name', id: url_data.user_id}
    }

  it 'should create a tag', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        expect(storage.response.statusCode).to.equal(200)
        expect(result.dom_id).to.not.be.empty
        expect(result.src).to.not.be.empty
        expect(result.type).to.not.be.empty
        expect(result.inject_position).to.not.be.empty

        done()

  it 'should allow tag creation only by the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: '100'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should allow tag creation only on existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag creation only on existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: '111111111111111111111111'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag creation only on versions that are editable', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion())
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should not allow tag having the same DOM Id', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion())
      .then(utils.createTag({dom_id: 'same'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          dom_id: 'same'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should generate stage library', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = createTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        fs = require('fs')
        file = "#{__dirname}/../../../../storage/libs/\
          #{storage.container.storage_namespace}/ptm.stage.lib.js"

        stats = fs.lstat file, (err, stats) ->
          done() if stats.isFile()


  beforeEach (done) ->
    fs = require('fs')
    file = "#{__dirname}/../../../../storage/libs/publish_test/ptm.stage.lib.js"

    Container = require('../../../../app/api_app/models/container')
    Version = require('../../../../app/api_app/models/version')
    Tag = require('../../../../app/api_app/models/tag')

    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
