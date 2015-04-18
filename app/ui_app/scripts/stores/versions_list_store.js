'use strict';
var Reflux = require('reflux');
var _ = require('lodash');

var VersionActions = require('../actions/version_actions');
var ListVersion = require('../models/ListVersion');

var VersionsListStore = Reflux.createStore({
  init: function () {
    this.list = null;

    this.listenTo(VersionActions.get, this.onGet);
    this.listenTo(VersionActions.load.completed, this.onLoad);
    this.listenTo(VersionActions.load.failed, this.onFail);
    this.listenTo(VersionActions.publish.completed, this.onPublished);
    this.listenTo(VersionActions.publish.failed, this.onFail);
    this.listenTo(VersionActions.editasnew.completed, this.onEditAsNew);
    this.listenTo(VersionActions.editasnew.failed, this.onFail);
  },

  onGet: function(container_id) {
    if (this.list) {
      return this.trigger({
        result: true,
        list: this.list
      });
    }

    VersionActions.load.triggerAsync(container_id);
  },

  onLoad: function (versions) {
    this.list = versions.map(function (version) {
      return new ListVersion(version);
    });

    this.trigger({
      result: true,
      list: this.list
    });
  },

  onPublished: function (container_id) {
    VersionActions.load.triggerAsync(container_id);
    VersionActions.getOverviewInfo.triggerAsync(container_id);
  },

  onEditAsNew: function (container_id) {
    VersionActions.load.triggerAsync(container_id);
    VersionActions.getOverviewInfo.triggerAsync(container_id);
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message || err.error
    });
  },

  getVersionNumber: function(version_id) {
    return _.result(_.find(this.list, function(version) {
      return version.version_id === version_id;
    }), 'version_number');
  }
});

module.exports = VersionsListStore;
