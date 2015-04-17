'use strict';

var requireAuth = require('require_auth');
var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;
var _ = require('lodash');

var ContainerActions = require('../../actions/container_actions');
var ContainerStore = require('../../stores/container_store');
var Container = require('../../models/Container');

var ContainerView = requireAuth(React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function() {
    return {
      container_id: this.context.router.getCurrentParams().container_id
    };
  },

  componentWillMount: function() {
    this.model = new Container({});
    this.listenTo(ContainerStore, this.onContainerChange);
  },

  componentDidMount: function() {
    this.formValidator = new Parsley('.container-form form');

    if (this.state.container_id) {
      ContainerActions.loadContainer.triggerAsync(
        this.state.container_id
      );
    }
  },

  onContainerChange: function(data) {
    this.enableForm();

    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    this.model = data.container;

    this.setState(this.model.getState());
    if (this.model.isNewlyCreated()) {
      this.onTagCreate(data.tag);
    }
  },

  onTagCreate: function (data) {
    this.context.router.transitionTo('container_details', {
      container_id: this.model.get('container_id')
    });
  },

  handleChange: function(evt) {
    this.model.set(evt.target.id, evt.target.value);
    this.setState(this.model.getState());
  },

  handleSubmit: function(event) {
    if (!this.formValidator.isValid()) {
      return false;
    }

    event.preventDefault();
    this.disableForm();
    if (this.state.container_id) {
      ContainerActions.updateContainer.triggerAsync(
        this.state.container_id,
        this.model.getActionData()
      );
    } else {
      ContainerActions.createContainer.triggerAsync(
        this.model.getActionData()
      );
    }
  },

  getFieldKeys: function() {
    return ['name', 'domain'];
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

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">{this.props.tag_id?'Update container' : 'Create container'}</h3>
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
              {this.state.container_id && (
              <div className="form-group">
                <label>Container Id</label>
                 <p className="form-control-static">{this.state.container_id}</p>
              </div>
              )}
              <div className="form-group">
                <label htmlFor="name">Name</label>
                <input ref="name" type="text" className="form-control" id="name" onChange={this.handleChange} value={this.state.name} required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="domain">Domain</label>
                <input ref="domain" type="url" className="form-control" id="domain" onChange={this.handleChange} value={this.state.domain} placeholder="www.somedomain.com" data-parsley-type="url" required />
              </div>
              {this.state.container_id && (
                <div className="form-group">
                  <label>Storage Namespace</label>
                   <p className="form-control-static">{this.state.storage_namespace}</p>
                </div>
              )}
              {this.state.container_id && (
                <div className="form-group">
                  <label>Created At</label>
                   <p className="form-control-static">{this.state.created_at}</p>
                </div>
              )}
              {this.state.container_id && (
                <div className="form-group">
                  <label>Updated At</label>
                   <p className="form-control-static">{this.state.updated_at}</p>
                </div>
              )}
              <div className="pull-left">
                {this.state.container_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Updating ..." className="btn btn-primary" type="submit">Update</button>
                )}
                {!this.state.container_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
                )}
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to="containers">
                  {this.state.container_id ? 'Back' : 'Cancel'}
                </Link>
              </div>
            </form>
          </div>
        </div>
        {this.formValidator && this.formValidator.reset()}
      </div>
    );
  }
}));

module.exports = ContainerView;
