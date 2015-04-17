'use strict';
var Reflux = require('reflux');
var ContainerActions = require('../actions/container_actions');
var Container = require('../models/Container');

var ContainerStore = Reflux.createStore({
  init: function () {
    this.listenTo(ContainerActions.createContainer.completed, this.onCreate);
    this.listenTo(ContainerActions.createContainer.failed, this.onFail);
    this.listenTo(ContainerActions.updateContainer.completed, this.onUpdate);
    this.listenTo(ContainerActions.updateContainer.failed, this.onFail);
    this.listenTo(ContainerActions.loadContainer.completed, this.onLoad);
    this.listenTo(ContainerActions.loadContainer.failed, this.onFail);
  },

  onCreate: function (data) {
    this.onLoad(data, 'create');
  },

  onUpdate: function (data) {
    this.onLoad(data);
  },

  onLoad: function (data, action) {
    this.trigger({
      result: true,
      container: new Container(data, action)
    });
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message || err.error
    });
  }
});

module.exports = ContainerStore;
