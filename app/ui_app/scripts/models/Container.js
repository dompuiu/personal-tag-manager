'use strict';

var _ = require('lodash');

var Container = function (data) {
  if (!data) {
    data = {};
  }

  this.state = {
    container_id: data.id,

    name: data.name,
    domain: data.domain,
    storage_namespace: data.storage_namespace,

    created_at: data.created_at,
    updated_at: data.updated_at
  };
};

Container.prototype = {
  set: function(key, value) {
    this.state[key] = value;
  },

  get: function(key) {
    return this.state[key];
  },

  getState: function() {
    return _.merge(this.state, {error: null});
  },

  getActionData: function() {
    return {
      name: this.state.name,
      domain: this.state.domain
    };
  },
};

module.exports = Container;
