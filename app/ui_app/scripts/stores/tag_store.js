'use strict';
var Reflux = require('reflux');
var TagActions = require('../actions/tag_actions');

var TagCreateStore = Reflux.createStore({
  init: function () {
    this.listenTo(TagActions.createTag.completed, this.onOverviewLoad);
    this.listenTo(TagActions.createTag.failed, this.onOverviewFail);
    this.listenTo(TagActions.updateTag.completed, this.onOverviewLoad);
    this.listenTo(TagActions.updateTag.failed, this.onOverviewFail);
    this.listenTo(TagActions.loadTag.completed, this.onOverviewLoad);
    this.listenTo(TagActions.loadTag.failed, this.onOverviewFail);
  },

  onOverviewLoad: function (data) {
    this.trigger({
      result: true,
      tag: data
    });
  },

  onOverviewFail: function (err) {
    this.trigger({
      result: false,
      error: err.message
    });
  }
});

module.exports = TagCreateStore;
