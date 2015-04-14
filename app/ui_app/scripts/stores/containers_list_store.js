'use strict';
var Reflux = require('reflux');
var _ = require('lodash');
var request = require('superagent');
var auth = require('auth');
var API_URL = 'http://localhost:8100';

var ContainerActions = require('../actions/container_actions');
var Container = require('../models/container');

var ContainersStore = Reflux.createStore({
  init: function () {
    this.list = null;

    this.listenTo(ContainerActions.load, this.fetchData);
    this.listenTo(ContainerActions.removeContainer, this.onRemoveContainer);
  },

  fetchData: function () {
    var token = auth.getToken();

    request.get(API_URL + '/containers/')
      .set('Authorization', 'Basic ' + token)
      .end(function (err, res) {
        var containers = JSON.parse(res.text).items;
        this.list = containers.map(function (container) {
          return new Container(container.id, container.name);
        });

        this.trigger(this.list);
      }.bind(this));
  },

  onRemoveContainer: function (key) {
    request.del(API_URL + '/containers/' + key + '/')
      .auth('serban.stancu@yahoo.com', 'qwe123')
      .end(function (err, res) {
        var list = _.reject(this.list, function (item) {
          return item.id === key;
        });

        this.updateList(list);
      }.bind(this));
  },

  updateList: function (list) {
    this.list = list;
    this.trigger(list);
  }
});

module.exports = ContainersStore;
