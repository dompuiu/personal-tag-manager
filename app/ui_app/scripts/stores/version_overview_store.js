'use strict';
var Reflux = require('reflux');
var VersionActions = require('../actions/version_actions');
var date = require('../helpers/date');


var VersionOverviewStore = Reflux.createStore({
  init: function () {
    this.listenTo(VersionActions.getOverviewInfo.completed, this.onLoad);
    this.listenTo(VersionActions.getOverviewInfo.failed, this.onFail);

    this.listenTo(VersionActions.publish.completed, this.onPublished);
    this.listenTo(VersionActions.publish.failed, this.onFail);
  },

  onLoad: function (data) {
    data.editing.created_at = date.getDate(data.editing.created_at);
    if (data.published) {
      data.published.published_at = date.getDate(data.published.published_at);
    }

    this.trigger({
      result: true,
      versions_info: data
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
  }
});

module.exports = VersionOverviewStore;
