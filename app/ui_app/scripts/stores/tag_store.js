'use strict';
var Reflux = require('reflux');
var TagActions = require('../actions/tag_actions');
var VersionActions = require('../actions/version_actions');
var Tag = require('../models/Tag');

var currentTag = null;

var TagStore = Reflux.createStore({
  init: function () {
    this.listenTo(TagActions.createTag.completed, this.onCreate);
    this.listenTo(TagActions.createTag.failed, this.onFail);
    this.listenTo(TagActions.updateTag.completed, this.onUpdate);
    this.listenTo(TagActions.updateTag.failed, this.onFail);
    this.listenTo(TagActions.loadTag.completed, this.onLoad);
    this.listenTo(TagActions.loadTag.failed, this.onFail);
    this.listenTo(TagActions.changeState, this.onChange);
    this.listenTo(TagActions.new, this.onNew);
  },

  onCreate: function (data) {
    this.onLoad(data);

    this.trigger({
      redirect: {
        container_id: currentTag.get('container_id'),
        version_id: currentTag.get('version_id'),
        tag_id: currentTag.get('tag_id')
      }
    });
  },

  onNew: function() {
    currentTag = new Tag({
      type: 'html',
      inject_position: 1
    });
  },

  onUpdate: function (data) {
    this.onLoad(data);
  },

  onLoad: function (data) {
    VersionActions.getOverviewInfo.triggerAsync(data.container_id);
    currentTag = new Tag(data);

    this.trigger({
      result: true,
      tag: currentTag.getState()
    });
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message || err.error
    });
  },

  onChange: function(key, value) {
    currentTag.set(key, value);
    this.trigger({
      result: true,
      tag: currentTag.getState()
    });
  },

  getActionData: function() {
    return currentTag.getActionData();
  }
});

module.exports = TagStore;
