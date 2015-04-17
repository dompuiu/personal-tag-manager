'use strict';
var Reflux = require('reflux');
var _ = require('lodash');

var TagsActions = require('../actions/tag_actions');
var ListTag = require('../models/ListTag');

var ContainersStore = Reflux.createStore({
  init: function () {
    this.list = null;

    this.listenTo(TagsActions.load.completed, this.onLoad);
    this.listenTo(TagsActions.load.failed, this.onFail);
    this.listenTo(TagsActions.removeTag.completed, this.onRemove);
    this.listenTo(TagsActions.removeTag.failed, this.onFail);
  },

  onLoad: function (tags) {
    this.list = tags.map(function (tag) {
      return new ListTag(tag);
    });

    this.trigger({
      result: true,
      list: this.list
    });
  },

  onRemove: function (tag_id) {
    var list = _.reject(this.list, function (item) {
      return item.id === tag_id;
    });

    this.updateList(list);
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

module.exports = ContainersStore;
