'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var VersionActions = Reflux.createActions({
  "getOverviewInfo": {aSync: true, children: ['completed', 'failed']}
});

VersionActions.getOverviewInfo.listen(function(container_id) {
  request.get(API_URL + '/containers/' + container_id + '/versions/info/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(JSON.parse(res.text));
      }
    }.bind(this));
});

module.exports = VersionActions;
