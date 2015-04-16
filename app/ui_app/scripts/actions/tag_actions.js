'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var TagActions = Reflux.createActions({
  "createTag": {aSync: true, children: ['completed', 'failed']}
});

TagActions.createTag.listen(function(container_id, version_id, data) {
  request.post(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/tags/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .send(JSON.stringify(data))
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(JSON.parse(res.text));
      }
    }.bind(this));
});

module.exports = TagActions;
