'use strict';

var React = require('react');
var TagActions = require('../../../actions/tag_actions');
var _ = require('lodash');

var TagDetailsGeneralView = React.createClass({
  getDefaultProps: function() {
    return {
      type: 'html',
      inject_position: 1
    };
  },

  componentDidUpdate: function() {
    if (this.props.editable) {
      this.enableForm();
    } else {
      this.disableForm();
    }
  },

  getFieldKeys: function() {
    return ['name', 'dom_id', 'type', 'onload', 'inject_position', 'src', 'sync', 'url'];
  },

  disableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().disabled = 'disabled';
      }
    }.bind(this));

    if (this.refs.submit) {
      $(this.refs.submit.getDOMNode()).button('loading');
    }
  },

  enableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().removeAttribute('disabled');
      }
    }.bind(this));

    if (this.refs.submit) {
      $(this.refs.submit.getDOMNode()).button('reset');
    }
  },

  handleChange: function(evt) {
    TagActions.changeState(evt.target.id, evt.target.id === 'sync' ? evt.target.checked : evt.target.value);
  },

  render: function() {
    return (
      <div className="panel-body">
        {this.props.tag_id && (
          <div className="form-group">
            <label>Tag Id</label>
             <p className="form-control-static">{this.props.tag_id}</p>
          </div>
          )}
          <div className="form-group">
            <label htmlFor="name">Name</label>
            <input ref="name" type="text" className="form-control" id="name" onChange={this.handleChange} value={this.props.name} required autoFocus/>
          </div>
          <div className="form-group">
            <label htmlFor="dom_id">Unique ID</label>
            <input ref="dom_id" type="text" className="form-control" id="dom_id" onChange={this.handleChange} value={this.props.dom_id} placeholder="Accepted values: numbers, letters, special characters(- _ .). No spaces allowed." data-parsley-pattern="^[A-Za-z0-9_\-\.]+$" required/>
          </div>
          <div className="form-group">
            <label htmlFor="type">Type</label>
            <select className="form-control" name="type" id="type" ref="type" value={this.props.type} onChange={this.handleChange}>
              <option value="html">HTML</option>
              <option value="script">Remote script</option>
              <option value="js">Inline JavaScript</option>
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="inject_position">Execute at</label>
            <select className="form-control" name="inject_position" id="inject_position" ref="inject_position" value={this.props.inject_position} onChange={this.handleChange}>
              <option value="1">Top of the page</option>
              <option value="2">Bottom of the page</option>
            </select>
          </div>
          {this.props.type !== 'script' && (
            <div className="form-group">
              <label htmlFor="src">Source Code</label>
              <textarea ref="src" id="src" name="src" className="form-control" rows="3" onChange={this.handleChange} required value={this.props.src}></textarea>
            </div>
          )}
          {this.props.type === 'script' && (
            <div className="form-group">
              <label htmlFor="url">URL</label>
              <input ref="url" type="url" className="form-control" id="url" onChange={this.handleChange} value={this.props.url} data-parsley-type="url" required/>
            </div>
          )}
          {this.props.type === 'script' && (
            <div className="checkbox form-group">
              <label htmlFor="sync">
                <input id="sync" ref="sync" checked={this.props.sync} name="sync" type="checkbox" onChange={this.handleChange}/>
                <strong>Load synchronously</strong>
              </label>
            </div>
          )}
          <div className="form-group">
            <label htmlFor="onload">Run the following code after tag is loaded</label>
            <textarea ref="onload" id="onload" className="form-control" rows="3" value={this.props.onload} onChange={this.handleChange}></textarea>
          </div>
          {this.props.tag_id && (
            <div className="form-group">
              <label>Created At</label>
               <p className="form-control-static">{this.props.created_at}</p>
            </div>
          )}
          {this.props.tag_id && (
            <div className="form-group">
              <label>Updated At</label>
               <p className="form-control-static">{this.props.updated_at}</p>
            </div>
          )}
      </div>
    );
  }
});

module.exports = TagDetailsGeneralView;
