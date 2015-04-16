'use strict';
var Reflux = require('reflux');
var _ = require('lodash');
var request = require('superagent');
var auth = require('auth');
var API_URL = 'http://localhost:8100';

var ContainerActions = require('../actions/container_actions');
var ListContainer = require('../models/ListContainer');

var ContainersStore = Reflux.createStore({
  init: function () {
    this.list = null;

    this.listenTo(ContainerActions.load.completed, this.onLoad);
    this.listenTo(ContainerActions.load.failed, this.onFail);
    this.listenTo(ContainerActions.removeContainer.completed, this.onRemove);
    this.listenTo(ContainerActions.removeContainer.failed, this.onFail);
  },

  onLoad: function (containers) {
    this.list = containers.map(function (container) {
      return new ListContainer(container.id, container.name);
    });

    this.trigger({
      result: true,
      list: this.list
    });
  },

  onRemove: function (container_id) {
    var list = _.reject(this.list, function (item) {
      return item.id === container_id;
    });

    this.updateList(list);
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message
    });
  },

  updateList: function (list) {
    this.list = list;
    this.trigger({
      result: true,
      list: this.list
    });
  }
});

module.exports = ContainersStore;
