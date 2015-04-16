'use strict';
var Reflux = require('reflux');
var VersionActions = require('../actions/version_actions');
var date = require('../helpers/date');


var ContainerInfoStore = Reflux.createStore({
  init: function () {
    this.listenTo(VersionActions.getOverviewInfo.completed, this.onOverviewLoad);
    this.listenTo(VersionActions.getOverviewInfo.failed, this.onOverviewFail);
  },

  onOverviewLoad: function (data) {
    data.editing.created_at = date.getDate(data.editing.created_at);
    if (data.published) {
      data.published.published_at = date.getDate(data.published.published_at);
    }

    this.trigger({
      result: true,
      versions_info: data
    });
  },

  onOverviewFail: function (err) {
    this.trigger({
      result: false,
      error: (err.response && JSON.parse(err.response.text)) || err
    });
  }
});

module.exports = ContainerInfoStore;
