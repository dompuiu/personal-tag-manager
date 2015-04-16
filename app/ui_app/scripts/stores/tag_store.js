'use strict';
var Reflux = require('reflux');
var TagActions = require('../actions/tag_actions');
var Tag = require('../models/Tag');

var TagStore = Reflux.createStore({
  init: function () {
    this.listenTo(TagActions.createTag.completed, this.onCreate);
    this.listenTo(TagActions.createTag.failed, this.onFail);
    this.listenTo(TagActions.updateTag.completed, this.onUpdate);
    this.listenTo(TagActions.updateTag.failed, this.onFail);
    this.listenTo(TagActions.loadTag.completed, this.onLoad);
    this.listenTo(TagActions.loadTag.failed, this.onFail);
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
      tag: new Tag(data, action)
    });
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message
    });
  }
});

module.exports = TagStore;
