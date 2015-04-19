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
    this.listenTo(TagActions.newTriggerCondition, this.onNewTriggerCondition);
    this.listenTo(TagActions.removeTriggerCondition, this.onRemoveTriggerCondition);
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
      inject_position: 1,
      match: []
    });

    this.trigger({
      result: true,
      tag: currentTag.getState()
    });
  },

  onNewTriggerCondition: function() {
    currentTag.addTriggerCondition();
    this.triggerChange();
  },

  onRemoveTriggerCondition: function(id) {
    currentTag.removeTriggerCondition(id);
    this.triggerChange();
  },

  onUpdate: function (data) {
    this.onLoad(data);
  },

  onLoad: function (data) {
    currentTag = new Tag(data);

    VersionActions.getOverviewInfo.triggerAsync(data.container_id);
    this.triggerChange();
  },

  onFail: function (err) {
    this.trigger({
      result: false,
      error: err.message || err.error
    });
  },

  onChange: function(key, value, id) {
    if (key === 'match') {
      currentTag.setMatch(id, value);
    } else {
      currentTag.set(key, value);
    }
    this.triggerChange();
  },

  getActionData: function() {
    return currentTag.getActionData();
  },

  triggerChange: function() {
    this.trigger({
      result: true,
      tag: currentTag.getState()
    });
  }
});

module.exports = TagStore;
