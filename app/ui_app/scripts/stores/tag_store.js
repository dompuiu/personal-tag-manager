'use strict';
var Reflux = require('reflux');
var TagActions = require('../actions/tag_actions');

var TagCreateStore = Reflux.createStore({
  init: function () {
    this.listenTo(TagActions.createTag.completed, this.onCreate);
    this.listenTo(TagActions.createTag.failed, this.onFail);
    this.listenTo(TagActions.updateTag.completed, this.onUpdate);
    this.listenTo(TagActions.updateTag.failed, this.onFail);
    this.listenTo(TagActions.loadTag.completed, this.onLoad);
    this.listenTo(TagActions.loadTag.failed, this.onFail);
  },

  onCreate: function (data) {
    data.action = 'create';
    this.onLoad(data);
  },

  onUpdate: function (data) {
    data.action = 'update';
    this.onLoad(data);
  },

  onLoad: function (data) {
    if (!data.action) {
      data.action = 'load';
    }

    this.trigger({
      result: true,
      tag: data
    });
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message
    });
  }
});

module.exports = TagCreateStore;
