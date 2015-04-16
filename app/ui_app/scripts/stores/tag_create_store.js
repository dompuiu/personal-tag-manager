'use strict';
var Reflux = require('reflux');
var TagActions = require('../actions/tag_actions');
var date = require('../helpers/date');

var TagCreateStore = Reflux.createStore({
  init: function () {
    this.listenTo(TagActions.createTag.completed, this.onOverviewLoad);
    this.listenTo(TagActions.createTag.failed, this.onOverviewFail);
  },

  onOverviewLoad: function (data) {
    data.editing.created_at = date.getDate(data.editing.created_at);
    data.published.updated_at = date.getDate(data.published.updated_at);

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
