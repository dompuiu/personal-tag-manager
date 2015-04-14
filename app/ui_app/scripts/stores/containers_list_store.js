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

    this.listenTo(ContainerActions.load.completed, this.onListFetched);
    this.listenTo(ContainerActions.removeContainer.completed, this.onRemoveContainer);
  },

  onListFetched: function (containers) {
    this.list = containers.map(function (container) {
      return new Container(container.id, container.name);
    });

    this.trigger(this.list);
  },

  onRemoveContainer: function (container_id) {
    var list = _.reject(this.list, function (item) {
      return item.id === container_id;
    });

    this.updateList(list);
  },

  updateList: function (list) {
    this.list = list;
    this.trigger(list);
  }
});

module.exports = ContainersStore;
