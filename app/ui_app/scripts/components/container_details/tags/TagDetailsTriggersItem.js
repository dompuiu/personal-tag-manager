'use strict';

var React = require('react');
var TagActions = require('../../../actions/tag_actions');
var _ = require('lodash');

var TagDetailsTriggersItem = React.createClass({
  handleChange: function(evt) {
    var state = {};

    state[evt.target.name] = evt.target.value;

    if (evt.target.name === 'dow') {
      state.dow = this.getDowValues();
    }

    if (evt.target.name === 'param') {
      state.condition = '';
      state.param_name = '';
    }

    if (evt.target.name === 'condition') {
      state.scalar = '';
      state.pattern = '';
      state.dow = [];
    }

    TagActions.changeState('match', state, this.props.id);
  },

  onRemoveClick: function() {
    TagActions.removeTriggerCondition(this.props.id);
  },

  getDowValues: function() {
    var result = [];

    [0, 1, 2, 3, 4, 5, 6].forEach(function(item) {
      if (this.refs['dow' + item].getDOMNode().checked) {
        result.push(item);
      }
    }.bind(this));

    return result;
  },

  getFieldKeys: function() {
    return ['param', 'param_name', 'condition', 'scalar', 'pattern', 'date_min', 'date_max', 'dow0', 'dow2', 'dow3', 'dow4', 'dow5', 'dow6', 'dow6'];
  },

  disableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().disabled = 'disabled';
      }
    }.bind(this));

    if (this.refs.remove) {
      $(this.refs.remove.getDOMNode()).button('loading');
    }
  },

  enableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().removeAttribute('disabled');
      }
    }.bind(this));

    if (this.refs.remove) {
      $(this.refs.remove.getDOMNode()).button('reset');
    }
  },

  render: function() {
    return (
      <div className="list-group-item">
        <h4>
          <div className="pull-right">
            <button ref="remove" data-loading-text="Remove" type="button" className="btn btn-danger btn-xs" onClick={this.onRemoveClick}>
              <span className="glyphicon glyphicon-remove" aria-hidden="true"></span>&nbsp;Remove
            </button>
          </div>
          Trigger Condition
        </h4>
        <div className="form-group">
          <label htmlFor="param{this.props.id}">Parameter</label>
          <select ref="param" className="form-control" name="param" id="param{this.props.id}" value={this.props.param} onChange={this.handleChange} required>
            <option value="">Select parameter to match</option>
            <option value="host">Host</option>
            <option value="path">Path</option>
            <option value="cookie">Cookie</option>
            <option value="query">Query Parameter</option>
            <option value="date">Date</option>
          </select>
        </div>

        {(this.props.param === 'cookie' || this.props.param === 'query') && (
          <div className="form-group">
            <label htmlFor="param_name{this.props.id}">{this.props.param === 'cookie' ? 'Cookie' : 'Query parameter'}</label>
            <input ref="param_name" type="text" name="param_name" className="form-control" id="param_name{this.props.id}" onChange={this.handleChange} value={this.props.param_name} placeholder={this.props.param === 'cookie' ? "Enter cookie name" : "Enter query name"} required/>
          </div>
        )}

        {this.props.param && this.props.param !== 'date' && (
          <div className="form-group">
            <label htmlFor="condition{this.props.id}">Condition</label>
            <select ref="condition" className="form-control" name="condition" id="condition{this.props.id}" value={this.props.condition} onChange={this.handleChange} required>
              <option value="">Select condition</option>
              <option value="contains">Contains</option>
              <option value="regex">Matches RegEx</option>
              <option value="!contains">Does not contain</option>
              <option value="!regex">Does not match RegEx</option>
            </select>
          </div>
        )}

        {this.props.param && this.props.param === 'date' && (
          <div className="form-group">
            <label htmlFor="condition{this.props.id}">Condition</label>
            <select ref="condition" className="form-control" name="condition" id="condition{this.props.id}" value={this.props.condition} onChange={this.handleChange} required>
              <option value="">Select condition</option>
              <option value="daterange">Between</option>
              <option value="dow">Day of week</option>
              <option value="!dow">Not day of week</option>
            </select>
          </div>
        )}

        {(this.props.condition === 'contains' || this.props.condition === '!contains') && (
          <div className="form-group">
            <label htmlFor="scalar{this.props.id}">Value</label>
            <input ref="scalar" type="text" name="scalar" className="form-control" id="scalar{this.props.id}" onChange={this.handleChange} value={this.props.scalar} required/>
          </div>
        )}

        {(this.props.condition === 'regex' || this.props.condition === '!regex') && (
          <div className="form-group">
            <label htmlFor="pattern{this.props.id}">Pattern</label>
            <div className="input-group">
              <span className="input-group-addon" id="sizing-addon1">/</span>
              <input ref="pattern" type="text" name="pattern" className="form-control" id="pattern{this.props.id}" onChange={this.handleChange} value={this.props.pattern} placeholder="[a-z0-9]+" required/>
              <span className="input-group-addon" id="sizing-addon1">/</span>
            </div>
          </div>
        )}

        {this.props.condition === 'daterange' && (
          <div className="form-group">
            <label htmlFor="min{this.props.id}">Date min</label>
            <input ref="date_min" type="text" name="date_min" className="form-control" id="min{this.props.id}" onChange={this.handleChange} value={this.props.date_min} placeholder="yyyy/mm/dd" required data-parsley-pattern="^\d{4}\/(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])$"/>
          </div>
        )}

        {this.props.condition === 'daterange' && (
          <div className="form-group">
            <label htmlFor="max{this.props.id}">Date max</label>
            <input ref="date_max" type="text" name="date_max" className="form-control" id="max{this.props.id}" onChange={this.handleChange} value={this.props.date_max} placeholder="yyyy/mm/dd" required data-parsley-pattern="^\d{4}\/(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])$"/>
          </div>
        )}

        {(this.props.condition === 'dow' || this.props.condition === '!dow') && (
          <div className="form-group dow">
            <label>Select day(s)</label>
            <div className="checkbox">
              <label><input ref="dow1" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(1) !== -1} name="dow" onChange={this.handleChange} required /> Monday</label>
              <label><input ref="dow2" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(2) !== -1} name="dow" onChange={this.handleChange} /> Tuesday</label>
              <label><input ref="dow3" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(3) !== -1} name="dow" onChange={this.handleChange} /> Wednesday</label>
              <label><input ref="dow4" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(4) !== -1} name="dow" onChange={this.handleChange} /> Thursday</label>
              <label><input ref="dow5" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(5) !== -1} name="dow" onChange={this.handleChange} /> Friday</label>
              <label><input ref="dow6" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(6) !== -1} name="dow" onChange={this.handleChange} /> Saturday</label>
              <label><input ref="dow0" type="checkbox" checked={this.props.dow && this.props.dow.indexOf(0) !== -1} name="dow" onChange={this.handleChange} /> Sunday</label>
            </div>
          </div>
        )}
      </div>
    );
  }
});

module.exports = TagDetailsTriggersItem;
