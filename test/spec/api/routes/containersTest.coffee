'use strict'

expect = require('chai').expect

Server = require('../../../../app/api/server')
routes = require('../../../../app/api/routes/containers')

describe 'containersTest', ->
  it 'should create a container', (done) ->
    server = Server.get()
    server.route(routes)

    options = {
      method: 'PUT'
      url: '/v1/containers/'
      headers: {
        'Content-Type': 'application/json'
      }
      payload: {
        name: 'some name'
      }

      credentials: {
        name: 'user name'
        id: '10'
      }

    }

    server.inject(options, (response) ->
      result = response.result

      expect(response.statusCode).to.equal(200)
      expect(result.name).to.equal('some name')

      done()
    )
  before(->
    d = require('../../../../app/database/connection')
    d.dropCollection('containers')
  )



