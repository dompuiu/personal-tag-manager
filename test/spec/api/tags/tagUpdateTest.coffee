'use strict'

describe 'TagsUpdateTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/tags')
  utils = require('../../../helpers/api_utils')
  _ = require('lodash')

  mongoose = require('mongoose')
  ObjectId = mongoose.Types.ObjectId

  updateTagRequest = (data) ->
    payload = {}
    payload.name = data.name if data.name
    payload.dom_id = data.dom_id if data.dom_id
    payload.type = data.type if data.type
    payload.src = data.src if data.src
    payload.onload = data.onload if typeof data.onload != 'undefined'
    payload.inject_position = data.inject_position if data.inject_position
    payload.match = data.match if data.match

    options = {
      method: 'PUT'
      url: "/containers/#{data.container_id}/versions/#{data.version_id}/tags/\
      #{data.id}/"
      headers: {'Content-Type': 'application/json'}
      payload: payload
      credentials: {name: 'user name', id: data.user_id}
    }

  describe 'when trying to update a tag', ->
    updateTag = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.createTag({
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
        }))
        .then((done, storage) ->
          storage.request = updateTagRequest(_.merge({
            id: storage.tag._id.toString()
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
          }, main_storage.data || {}))
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          done(storage)

    it 'should update the dom_id', (done) ->
      ASQ({data: {dom_id: 'updated_dom_id'}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.dom_id).to.equal('updated_dom_id')

          done()

    it 'should update the name', (done) ->
      ASQ({data: {name: 'updated_name'}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.name).to.equal('updated_name')

          done()

    it 'should update the type', (done) ->
      ASQ({data: {type: 'block-script'}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.type).to.equal('block-script')

          done()

    it 'should update the src', (done) ->
      ASQ({data: {src: 'updated_src'}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.src).to.equal('updated_src')

          done()

    it 'should update the onload', (done) ->
      ASQ({data: {onload: 'updated_onload'}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.onload).to.equal('updated_onload')

          done()

    it 'should allow update to an empty onload', (done) ->
      ASQ({data: {onload: ''}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.onload).to.equal('')

          done()

    it 'should update the inject position', (done) ->
      ASQ({data: {inject_position: 2}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.inject_position).to.equal(2)

          done()

    it 'should update the match', (done) ->
      ASQ({data: {match: []}})
        .then(updateTag)
        .val (storage) ->
          result = storage.response.result

          expect(storage.response.statusCode).to.equal(200)
          expect(result.match.length).to.equal(0)

          done()


  it 'should refresh updated_at field on any update', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag({updated_at: new Date('2013-02-02')}))
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        result = storage.response.result

        updated_at = new Date(result.updated_at)
        now = new Date()

        expect(updated_at.getYear()).to.equal(now.getYear())
        expect(updated_at.getMonth()).to.equal(now.getMonth())

        done()

  it 'should allow tag update only by the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: '100'
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(401)
        done()

  it 'should allow tag update only on existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: storage.version.user_id
          container_id: '111111111111111111111111'
          version_id: storage.version._id.toString()
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag update only on existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: '111111111111111111111111'
          id: storage.tag._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow update only on existing tags', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: storage.version.user_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
          id: '111111111111111111111111'
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(404)
        done()

  it 'should allow tag creation only on versions that are editable',
    (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion())
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = updateTagRequest({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
            id: storage.tag._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(401)
          done()

  describe 'when trying to update a tag', ->
    updateTagWithInvalidId = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = updateTagRequest(_.merge({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
            id: storage.tag._id.toString()
          }, main_storage.data || {}))
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          done(storage)

    it 'should not accept un invalid tag id', (done) ->
      ASQ({data: {id: '111'}})
        .then(updateTagWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

    it 'should not accept un invalid container id', (done) ->
      ASQ({data: {container_id: '111'}})
        .then(updateTagWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

    it 'should not accept un version id', (done) ->
      ASQ({data: {version_id: '111'}})
        .then(updateTagWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

  it 'should not allow tag having the same DOM Id', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag({dom_id: 'same'}, 'version', 'tag1'))
      .then(utils.createTag({}, 'version', 'tag2'))
      .then((done, storage) ->
        storage.request = updateTagRequest({
          user_id: storage.version.user_id
          dom_id: storage.tag1.dom_id
          container_id: storage.version.container_id
          version_id: storage.version._id.toString()
          id: storage.tag2._id.toString()
        })
        done(storage)
      )
      .then(utils.configureServerAndMakeRequest)
      .val (storage) ->
        expect(storage.response.statusCode).to.equal(409)
        done()

  it 'should allow tag update with an unchanged DOM ID in request',
    (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({status: 'now editing'}))
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = updateTagRequest({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
            id: storage.tag._id.toString()
            dom_id: storage.tag.dom_id
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(200)
          done()

  it 'should generate stage library', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then(utils.createTag({
        inject_position: 1
      }))
      .then((done, storage) ->
        storage.request = updateTagRequest({
          id: storage.tag._id.toString()
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

    ASQ((done) -> fs.unlink(file, done))
      .then((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
