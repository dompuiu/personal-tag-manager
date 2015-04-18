'use strict'

describe 'VersionEditAsNewTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/versions')
  utils = require('../../../helpers/api_utils')
  _ = require('lodash')

  Container = require('../../../../app/api_app/models/container')
  Version = require('../../../../app/api_app/models/version')
  Tag = require('../../../../app/api_app/models/tag')


  editAsNewRequest = (data) ->
    options = {
      method: 'POST'
      url: "/containers/#{data.container_id}/versions/\
      #{data.version_id}/editasnew/"

      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: data.user_id}
    }

  describe 'when editing a version as new', ->
    it 'should create a new editing version', (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({
          status: 'now editing',
        }))
        .then(utils.createVersion({
          status: 'published',
          created_at: new Date('2013-01-01')
        }))
        .then((done, storage) ->
          storage.request = editAsNewRequest({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          result = storage.response.result

          Version.find({container_id: storage.version.container_id},
            (err, versions) ->
              expect(storage.response.statusCode).to.equal(200)

              version_statuses = _.pluck(versions, 'status')
              expect(version_statuses).to.include('published')
              expect(version_statuses).to.include('now editing')
              expect(version_statuses).to.include('archived')
              done()
          )

    it 'should archive the last editing version', (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({
          status: 'published',
          published_at: new Date('2013-01-01')
        }, 'container', 'version1'))
        .then(utils.createTag({}, 'version1'))
        .then(utils.createTag({}, 'version1'))
        .then(utils.createVersion({
          status: 'now editing',
        }, 'container', 'version2'))
        .then(utils.createTag({}, 'version2'))
        .then(utils.createTag({}, 'version2'))
        .then((done, storage) ->
          storage.request = editAsNewRequest({
            user_id: storage.version1.user_id
            container_id: storage.version1.container_id
            version_id: storage.version1._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          result = storage.response.result

          Version.findOne({_id: storage.version2.id}, (err, version) ->
            expect(storage.response.statusCode).to.equal(200)
            expect(version.status).to.equal('archived')
            done()
          )

  it 'should allow editing a new version only to the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = editAsNewRequest({
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

  it 'should allow editing a new version only on existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = editAsNewRequest({
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

  it 'should allow editing a new version only on existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer())
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = editAsNewRequest({
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

  it 'should allow editing a new version only on non editing versions',
    (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({
          status: 'now editing',
          created_at: new Date('2013-01-01')
        }))
        .then(utils.createTag())
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = editAsNewRequest({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(412)
          done()

  describe 'when trying to edit a new version', ->
    showListWithInvalidId = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer())
        .then(utils.createVersion({status: 'now editing'}))
        .then((done, storage) ->
          storage.request = editAsNewRequest(_.merge({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
          }, main_storage.data || {}))
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          done(storage)

    it 'should not accept un invalid container id', (done) ->
      ASQ({data: {container_id: '111'}})
        .then(showListWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

    it 'should not accept un invalid version id', (done) ->
      ASQ({data: {version_id: '111'}})
        .then(showListWithInvalidId)
        .val (storage) ->
          expect(storage.response.statusCode).to.equal(400)
          done()

  beforeEach (done) ->
    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
