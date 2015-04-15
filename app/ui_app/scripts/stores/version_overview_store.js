'use strict';
var Reflux = require('reflux');

var VersionActions = require('../actions/version_actions');
var getDate = function(date_string) {
  var myDate = new Date(date_string),
    year = myDate.getFullYear(),
    month = myDate.getMonth() + 1,
    date = myDate.getDate(),
    hours = myDate.getHours(),
    minutes = myDate.getMinutes();

  if (month < 10) {
    month = '0' + month;
  }

  return year + '-' + month + "-" + date + ' ' + hours + ':' + minutes;
};


var ContainerInfoStore = Reflux.createStore({
  init: function () {
    this.listenTo(VersionActions.getOverviewInfo.completed, this.onOverviewLoad);
    this.listenTo(VersionActions.getOverviewInfo.failed, this.onOverviewFail);
  },

  onOverviewLoad: function (data) {
    data.editing.created_at = getDate(data.editing.created_at);
    if (data.published) {
      data.published.published_at = getDate(data.published.published_at);
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
