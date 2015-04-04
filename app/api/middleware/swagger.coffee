module.exports = (server) ->
  server.register({
    register: require('hapi-swagger'),
    options: {
      apiVersion: '1.0'
      info: {
        title: 'Personal Tag Manager API'
        description: 'API pentru lucrarea de licenta'
      }
    }
  }, (err) ->
    if err
      server.log(['error'], 'hapi-swagger load error: ' + err)
    else
      server.log(['start'], 'hapi-swagger interface loaded')
  )


