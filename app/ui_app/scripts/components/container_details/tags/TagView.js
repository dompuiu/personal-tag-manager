'use strict';

var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;
var _ = require('lodash');

var TagActions = require('../../../actions/tag_actions');
var TagStore = require('../../../stores/tag_store');
var Tag = require('../../../models/Tag');

var TagUpdate = React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function() {
    return {
      type: 'html'
    };
  },

  componentWillMount: function() {
    this.model = new Tag(this.getInitialState());
    this.listenTo(TagStore, this.onTagChange);
  },

  componentDidMount: function() {
    this.formValidator = new Parsley('.container-form form');

    if (this.props.tag_id) {
      TagActions.loadTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        this.props.tag_id
      );
    }
  },

  onTagChange: function(data) {
    this.enableForm();

    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    this.model = data.tag;

    this.setState(this.model.getState());
    if (this.model.isNewlyCreated()) {
      this.onTagCreate(data.tag);
    }
  },

  onTagCreate: function (data) {
    this.context.router.replaceWith('tag_details', {
      container_id: this.model.get('container_id'),
      version_id: this.model.get('version_id'),
      tag_id: this.model.get('tag_id')
    },{
      backPath: this.getBackPath()
    });
  },

  handleChange: function(evt) {
    this.model.set(evt.target.id, evt.target.id === 'sync' ? evt.target.checked : evt.target.value);
    this.setState(this.model.getState());
  },

  handleSubmit: function(event) {
    if (!this.formValidator.isValid()) {
      return false;
    }

    event.preventDefault();
    this.disableForm();

    if (this.props.tag_id) {
      TagActions.updateTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        this.props.tag_id,
        this.model.getActionData()
      );
    } else {
      TagActions.createTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        this.model.getActionData()
      );
    }
  },

  getFieldKeys: function() {
    return ['name', 'dom_id', 'type', 'on_load', 'src', 'sync', 'url'];
  },

  disableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().disabled = 'disabled';
      }
    }.bind(this));
    $(this.refs.submit.getDOMNode()).button('loading');
  },

  enableForm: function() {
    _.each(this.getFieldKeys(), function(key) {
      if (this.refs[key]) {
        this.refs[key].getDOMNode().removeAttribute('disabled');
      }
    }.bind(this));

    $(this.refs.submit.getDOMNode()).button('reset');
  },

  getBackPath: function() {
    var { router } = this.context;
    var backPath = router.getCurrentQuery().backPath;
    if (!backPath) {
      backPath = 'tag_list';
    }

    return backPath;
  },

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">{this.props.tag_id?'Update tag' : 'Create tag'}</h3>
          </div>
          <div className="panel-body">
            {this.state.error && (
              <div className="alert alert-danger" role="alert">
                <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                <span className="sr-only">Error:</span>
                &nbsp;&nbsp;{this.state.error}
              </div>
            )}
            <form onSubmit={this.handleSubmit}>
              {this.props.tag_id && (
              <div className="form-group">
                <label>Tag Id</label>
                 <p className="form-control-static">{this.state.tag_id}</p>
              </div>
              )}
              <div className="form-group">
                <label htmlFor="name">Name</label>
                <input ref="name" type="text" className="form-control" id="name" onChange={this.handleChange} value={this.state.name} required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="dom_id">Unique ID</label>
                <input ref="dom_id" type="text" className="form-control" id="dom_id" onChange={this.handleChange} value={this.state.dom_id} placeholder="Accepted values: numbers, letters, special characters(- _ .). No spaces allowed." data-parsley-pattern="^[A-Za-z0-9_\-\.]+$" required/>
              </div>
              <div className="form-group">
                <label htmlFor="type">Type</label>
                <select className="form-control" name="type" id="type" ref="type" value={this.state.type} onChange={this.handleChange}>
                  <option value="html">HTML</option>
                  <option value="script">Remote script</option>
                  <option value="js">Inline JavaScript</option>
                </select>
              </div>
              {this.state.type !== 'script' && (
                <div className="form-group">
                  <label htmlFor="src">Source Code</label>
                  <textarea ref="src" id="src" name="src" className="form-control" rows="3" onChange={this.handleChange} required value={this.state.src}></textarea>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="form-group">
                  <label htmlFor="url">URL</label>
                  <input ref="url" type="url" className="form-control" id="url" onChange={this.handleChange} value={this.state.url} data-parsley-type="url" required/>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="checkbox form-group">
                  <label htmlFor="sync">
                    <input id="sync" ref="sync" checked={this.state.sync} name="sync" type="checkbox" onChange={this.handleChange}/>
                    <strong>Load synchronously</strong>
                  </label>
                </div>
              )}
              <div className="form-group">
                <label htmlFor="on_load">Run the following code after tag is loaded</label>
                <textarea ref="on_load" id="on_load" className="form-control" rows="3" value={this.state.on_load} onChange={this.handleChange}></textarea>
              </div>
              {this.props.tag_id && (
                <div className="form-group">
                  <label>Created At</label>
                   <p className="form-control-static">{this.state.created_at}</p>
                </div>
              )}
              {this.props.tag_id && (
                <div className="form-group">
                  <label>Updated At</label>
                   <p className="form-control-static">{this.state.updated_at}</p>
                </div>
              )}
              <div className="pull-left">
                {this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Updating ..." className="btn btn-primary" type="submit">Update</button>
                )}
                {!this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
                )}
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to={this.getBackPath()} params={{container_id: this.props.container_id, version_id: this.props.version_id}}>
                  Back
                </Link>
              </div>
            </form>
          </div>
        </div>
        {this.formValidator && this.formValidator.reset()}
      </div>
    );
  }
});

module.exports = TagUpdate;
