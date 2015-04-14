'use strict';
var Reflux = require('reflux');
var auth = require('auth');
var request = require('superagent');
var API_URL = 'http://localhost:8100';

var ContainerActions = Reflux.createActions({
  "load": {},
  "removeContainer": {},
  "createContainer": {aSync: true, children: ['completed', 'failed']},
  "getContainer": {aSync: true, children: ['completed', 'failed']},
  "updateContainer": {aSync: true, children: ['completed', 'failed']}
});

ContainerActions.createContainer.preEmit = function(data) {
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
};

ContainerActions.getContainer.preEmit = function(id) {
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
};

ContainerActions.updateContainer.preEmit = function(data) {
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
};

module.exports = ContainerActions;
