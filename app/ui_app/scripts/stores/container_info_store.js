'use strict';
var Reflux = require('reflux');

var ContainerActions = require('../actions/container_actions');

var ContainerInfoStore = Reflux.createStore({
  init: function () {
    this.listenTo(ContainerActions.getContainer.completed, this.onContainerLoad);
    this.listenTo(ContainerActions.getContainer.failed, this.onContainerFailed);
  },

  onContainerLoad: function (container) {
    this.trigger({
      result: true,
      container: container
    });
  },

  onContainerFailed: function (err) {
    this.trigger({
      result: false,
      error: err.message
    });
  }
});

module.exports = ContainerInfoStore;
