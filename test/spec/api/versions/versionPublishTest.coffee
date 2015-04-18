'use strict'

describe 'VersionPublishTest', ->
  expect = require('chai').expect
  ASQ = require('asynquence')
  routes = require('../../../../app/api_app/api/routes/versions')
  utils = require('../../../helpers/api_utils')
  _ = require('lodash')

  Container = require('../../../../app/api_app/models/container')
  Version = require('../../../../app/api_app/models/version')
  Tag = require('../../../../app/api_app/models/tag')


  publishRequest = (data) ->
    options = {
      method: 'POST'
      url: "/containers/#{data.container_id}/versions/\
      #{data.version_id}/publish/"

      headers: {'Content-Type': 'application/json'}
      credentials: {name: 'user name', id: data.user_id}
    }

  describe 'when publishing versions', ->
    it 'should create a new editing version', (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({
          status: 'now editing',
          created_at: new Date('2013-01-01')
        }))
        .then(utils.createTag())
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = publishRequest({
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
              expect(versions.length).to.equal(2)
              done()
          )

    it 'should update the published_at field', (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({
          status: 'now editing',
          created_at: new Date('2013-01-01')
        }))
        .then(utils.createTag())
        .then(utils.createTag())
        .then((done, storage) ->
          storage.request = publishRequest({
            user_id: storage.version.user_id
            container_id: storage.version.container_id
            version_id: storage.version._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          result = storage.response.result

          Version.findOne({_id: storage.version.id}, (err, version) ->
            expect(storage.response.statusCode).to.equal(200)
            expect(version.published_at).to.not.be.undefined
            done()
          )

    it 'should archive the last published version', (done) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
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
          storage.request = publishRequest({
            user_id: storage.version2.user_id
            container_id: storage.version2.container_id
            version_id: storage.version2._id.toString()
          })
          done(storage)
        )
        .then(utils.configureServerAndMakeRequest)
        .val (storage) ->
          result = storage.response.result

          Version.findOne({_id: storage.version1.id}, (err, version) ->
            expect(storage.response.statusCode).to.equal(200)
            expect(version.published_at).to.be.undefined
            expect(version.status).to.equal('archived')
            done()
          )

    it 'should copy the published version tags to the new version',
      (done) ->
        ASQ({routes: routes})
          .then(utils.createContainer({storage_namespace: 'publish_test'}))
          .then(utils.createVersion({status: 'now editing'}))
          .then(utils.createTag())
          .then((done, storage) ->
            storage.request = publishRequest({
              user_id: storage.version.user_id
              container_id: storage.version.container_id
              version_id: storage.version._id.toString()
            })
            done(storage)
          )
          .then(utils.configureServerAndMakeRequest)
          .val (storage) ->
            result = storage.response.result
            storage.done = done

            ASQ(storage)
              .then (done, storage) ->
                Version.findOne {_id: storage.version.id}, (err, version) ->
                  return done.fail(err) if (err)

                  storage.version = version
                  done(storage)

              .then (done, storage) ->
                Tag.count {version_id: storage.version._id}, (err, count) ->
                  return done.fail(err) if (err)

                  expect(storage.response.statusCode).to.equal(200)
                  expect(count).to.equal(1)
                  storage.done()

  it 'should allow version publish only to the container owner', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = publishRequest({
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

  it 'should allow version publish only from existing containers', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = publishRequest({
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

  it 'should allow version publishing only on existing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({status: 'now editing'}))
      .then((done, storage) ->
        storage.request = publishRequest({
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

  it 'should allow  publishing only on editing versions', (done) ->
    ASQ({routes: routes})
      .then(utils.createContainer({storage_namespace: 'publish_test'}))
      .then(utils.createVersion({
        status: 'published',
        created_at: new Date('2013-01-01')
      }))
      .then(utils.createTag())
      .then(utils.createTag())
      .then((done, storage) ->
        storage.request = publishRequest({
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

  describe 'when trying to publish versions', ->
    showListWithInvalidId = (done, main_storage) ->
      ASQ({routes: routes})
        .then(utils.createContainer({storage_namespace: 'publish_test'}))
        .then(utils.createVersion({status: 'now editing'}))
        .then((done, storage) ->
          storage.request = publishRequest(_.merge({
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

    describe 'when generating assets', ->
      publish = (done, main_storage) ->
        ASQ({routes: routes})
          .then(utils.createContainer({storage_namespace: 'publish_test'}))
          .then(utils.createVersion({
            status: 'now editing',
            created_at: new Date('2013-01-01')
          }))
          .then(utils.createTag({onload: 'some code'}))
          .then(utils.createTag({type: 'js'}))
          .then((done, storage) ->
            storage.request = publishRequest(_.merge({
              user_id: storage.version.user_id
              container_id: storage.version.container_id
              version_id: storage.version._id.toString()
            }, main_storage.data || {}))
            done(storage)
          ).then(utils.configureServerAndMakeRequest)
          .val (storage) ->
            done(storage)

      it 'should generate asset folder', (done) ->
        ASQ({})
          .then(publish)
          .val (storage) ->
            fs = require('fs')
            folder = "#{__dirname}/../../../../storage/libs/\
              #{storage.container.storage_namespace}"

            stats = fs.lstat folder, (err, stats) ->
              done() if stats.isDirectory()


      it 'should generate library', (done) ->
        ASQ({})
          .then(publish)
          .val (storage) ->
            fs = require('fs')
            file = "#{__dirname}/../../../../storage/libs/\
              #{storage.container.storage_namespace}/ptm.lib.js"

            stats = fs.lstat file, (err, stats) ->
              done() if stats.isFile()

      it 'should generate config', (done) ->
        ASQ({})
          .then(publish)
          .val (storage) ->
            fs = require('fs')
            file = "#{__dirname}/../../../../storage/libs/\
              #{storage.container.storage_namespace}/ptm.lib.js"

            fs.readFile file, 'utf8', (err, data) ->
              done() if data.indexOf('%s') == -1

  beforeEach (done) ->
    ASQ((done) -> utils.emptyColection(Container, done))
      .then((done) -> utils.emptyColection(Version, done))
      .val(-> utils.emptyColection(Tag, done))
