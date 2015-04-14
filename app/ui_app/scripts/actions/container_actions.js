'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var ContainerActions = Reflux.createActions({
  "load": {aSync: true, children: ['completed', 'failed']},
  "removeContainer": {aSync: true, children: ['completed', 'failed']},
  "createContainer": {aSync: true, children: ['completed', 'failed']},
  "getContainer": {aSync: true, children: ['completed', 'failed']},
  "updateContainer": {aSync: true, children: ['completed', 'failed']}
});

ContainerActions.load.listen(function(data) {
  request.get(API_URL + '/containers/')
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

ContainerActions.removeContainer.listen(function(container_id) {
  request.del(API_URL + '/containers/' + container_id + '/')
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

ContainerActions.createContainer.listen(function(data) {
  request.post(API_URL + '/containers/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .send(JSON.stringify(data))
    .end(function (err, res) {
      if (err) {
        this.failed((err.response && JSON.parse(err.response.text)) || err);
      } else {
        this.completed(JSON.parse(res.text));
      }
    }.bind(this));
});

ContainerActions.getContainer.listen(function(id) {
  request.get(API_URL + '/containers/' + id + '/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .end(function (err, res) {
      if (err) {
        this.failed(JSON.parse(err.response.text));
      } else {
        this.completed(JSON.parse(res.text));
      }
    }.bind(this));
});

ContainerActions.updateContainer.listen(function(data) {
  var id = data.id;
  delete data.id;

  request.put(API_URL + '/containers/' + id + '/')
    .set('Authorization', 'Basic ' + auth.getToken())
    .set('Content-Type', 'application/json')
    .send(JSON.stringify(data))
    .end(function (err, res) {
      if (err) {
        this.failed(JSON.parse(err.response.text));
      } else {
        this.completed(JSON.parse(res.text));
      }
    }.bind(this));
});

module.exports = ContainerActions;
