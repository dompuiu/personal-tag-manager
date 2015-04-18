'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var VersionActions = Reflux.createActions({
  "get": {},
  "load": {aSync: true, children: ['completed', 'failed']},
  "publish": {aSync: true, children: ['completed', 'failed']},
  "editasnew": {aSync: true, children: ['completed', 'failed']},
  "getOverviewInfo": {aSync: true, children: ['completed', 'failed']}
});

VersionActions.load.listen(function(container_id) {
  request.get(API_URL + '/containers/' + container_id + '/versions/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(JSON.parse(res.text).items);
      }
    }.bind(this));
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

VersionActions.publish.listen(function(container_id, version_id) {
  request.post(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/publish/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(container_id);
      }
    }.bind(this));
});

VersionActions.editasnew.listen(function(container_id, version_id) {
  request.post(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/editasnew/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(container_id);
      }
    }.bind(this));
});

module.exports = VersionActions;
