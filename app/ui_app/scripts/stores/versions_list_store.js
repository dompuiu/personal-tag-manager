'use strict';
var Reflux = require('reflux');
var _ = require('lodash');

var VersionsActions = require('../actions/version_actions');
var ListVersion = require('../models/ListVersion');

var VersionsListStore = Reflux.createStore({
  init: function () {
    this.list = null;

    this.listenTo(VersionsActions.load.completed, this.onLoad);
    this.listenTo(VersionsActions.load.failed, this.onFail);
    this.listenTo(VersionsActions.publish.completed, this.onPublished);
    this.listenTo(VersionsActions.publish.failed, this.onFail);
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

  onPublished: function (response) {
    this.trigger({
      result: true,
      reload: true
    });
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message || err.error
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

module.exports = VersionsListStore;
