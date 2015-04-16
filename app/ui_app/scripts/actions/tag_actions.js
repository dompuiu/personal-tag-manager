'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var TagActions = Reflux.createActions({
  "load": {aSync: true, children: ['completed', 'failed']},
  "loadTag": {aSync: true, children: ['completed', 'failed']},
  "removeTag": {aSync: true, children: ['completed', 'failed']},
  "createTag": {aSync: true, children: ['completed', 'failed']},
  "updateTag": {aSync: true, children: ['completed', 'failed']}
});


TagActions.load.listen(function(container_id, version_id) {
  request.get(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/tags/')
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

TagActions.removeTag.listen(function(container_id, version_id, tag_id) {
  request.del(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/tags/' + tag_id + '/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(tag_id);
      }
    }.bind(this));
});

TagActions.loadTag.listen(function(container_id, version_id, tag_id) {
  request.get(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/tags/' + tag_id + '/')
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

TagActions.updateTag.listen(function(container_id, version_id, tag_id, data) {
  request.put(API_URL + '/containers/' + container_id + '/versions/' + version_id + '/tags/' + tag_id + '/')
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
