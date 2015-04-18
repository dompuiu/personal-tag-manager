'use strict';

var _ = require('lodash');

var Tag = function (data, action) {
  if (!data) {
    data = {};
  }

  this.action = action;
  this.initial = {
    type: data.type,
    src: data.src
  };

  this.state = {
    container_id: data.container_id,
    version_id: data.version_id,
    tag_id: data.id,

    name: data.name,
    dom_id: data.dom_id,
    type: data.type,
    src: data.src,
    sync: false,
    onload: data.onload,
    inject_position: data.inject_position,

    created_at: data.created_at,
    updated_at: data.updated_at
  };

  if (data.type === 'block-script') {
    this.state.sync = true;
    this.state.type = 'script';
  }

  if (data.type === 'block-script' || data.type === 'script') {
    this.state.url = data.src;
    this.state.src = '';
  }

};

Tag.prototype = {
  isNewlyCreated: function() {
    return this.action === 'create';
  },

  set: function(key, value) {
    this.state[key] = value;

    if (key === 'type') {
      if (this.initial.type !== this.state.type) {
        this.state.src = '';
      } else {
        this.state.src = this.initial.src;
      }
    }
  },

  get: function(key) {
    return this.state[key];
  },

  getState: function() {
    return _.merge(this.state, {error: null});
  },

  getActionData: function() {
    var t = this.state.type;
    var pickNonfalsy = _.partial(_.pick, _, _.identity);

    return pickNonfalsy(
      this['get' + t[0].toUpperCase() + t.slice(1) + 'Data']()
    );
  },

  getHtmlData: function() {
    return {
      name: this.state.name,
      dom_id: this.state.dom_id,
      type: this.state.type,
      src: this.state.src,
      onload: this.state.onload,
      inject_position: Number(this.state.inject_position)
    };
  },

  getScriptData: function() {
    var sync = this.state.sync;

    return {
      name: this.state.name,
      dom_id: this.state.dom_id,
      type: sync ? 'block-script' : 'script',
      src: this.state.url,
      onload: this.state.onload,
      inject_position: Number(this.state.inject_position)
    };
  },

  getJsData: function() {
    return this.getHtmlData();
  },

};

module.exports = Tag;
