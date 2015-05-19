'use strict';

var _ = require('lodash');
var uniqueId = 0;

var Tag = function (data) {
  if (!data) {
    data = {};
  }

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
    match: this.parseMatchData(data.match),

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
  addTriggerCondition: function() {
    this.state.match.push({
      id: this.generateNewId()
    });
  },

  removeTriggerCondition: function(id) {
    this.state.match = _.reject(this.state.match, function (item) {
      return item.id === id;
    });
  },

  generateNewId: function() {
    return ++uniqueId;
  },

  setMatch: function(id, values) {
    var obj = _.find(this.state.match, {id: id});

    _.merge(obj, values);
    if (values.dow) {
      obj.dow = values.dow;
    }
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
    return this['get' + t[0].toUpperCase() + t.slice(1) + 'Data']();
  },

  getHtmlData: function() {
    return {
      name: this.state.name,
      dom_id: this.state.dom_id,
      type: this.state.type,
      src: this.state.src,
      onload: this.state.onload,
      inject_position: Number(this.state.inject_position),
      match: this.getMatchData()
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
      inject_position: Number(this.state.inject_position),
      match: this.getMatchData()
    };
  },

  getJsData: function() {
    return this.getHtmlData();
  },

  getMatchData: function() {
    return this.state.match.map(function(rule) {
      var rule_result = {
        condition: rule.condition,
        not: false,
        param: rule.param,
        param_name: false
      };

      if (rule.condition[0] === '!') {
        rule_result.not = true;
        rule_result.condition = rule_result.condition.substring(1);
      }

      if (rule.param_name) {
        rule_result.param_name = rule.param_name;
      }

      if (rule_result.condition === 'contains') {
        rule_result.values = {
          scalar: rule.scalar
        };
      }

      if (rule_result.condition === 'regex') {
        rule_result.values = {
          pattern: rule.pattern
        };
      }

      if (rule_result.condition === 'daterange') {
        rule_result.values = {
          min: rule.date_min,
          max: rule.date_max
        };
      }

      if (rule_result.condition === 'dow') {
        rule_result.values = {
          days: rule.dow
        };
      }

      return rule_result;
    });
  },

  parseMatchData: function(data) {
    if (!_.isArray(data)) {
      return [];
    }

    return data.map(function(rule) {
      var rule_state = {
        id: this.generateNewId(),
        condition: (rule.not ? '!' : '') + rule.condition,
        param: rule.param,
        param_name: rule.param_name
      };

      if (rule.condition === 'contains') {
        rule_state.scalar = rule.values.scalar;
      }

      if (rule.condition === 'regex') {
        rule_state.pattern = rule.values.pattern;
      }

      if (rule.condition === 'daterange') {
        rule_state.date_min = rule.values.min;
        rule_state.date_max = rule.values.max;
      }

      if (rule.condition === 'dow') {
        rule_state.dow = rule.values.days;
      }

      return rule_state;
    }.bind(this));
  }
};

module.exports = Tag;
