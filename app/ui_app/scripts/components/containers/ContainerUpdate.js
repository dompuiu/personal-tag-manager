'use strict';

var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var ContainerActions = require('../../actions/container_actions');

var ContainerDetail = React.createClass({
  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function () {
    return {error: null};
  },

  componentDidMount: function () {
    this.formValidator = new Parsley('.container-form form');
    this.loadContainerData();
  },

  loadContainerData: function() {
    var {router} = this.context;
    var container_id = router.getCurrentParams().container_id;

    ContainerActions.getContainer.triggerPromise(container_id)
      .then(this.onLoad).catch(this.onLoadFail);
  },

  onLoad: function(container) {
    this.setState(container);
    this.setState({
      error: null
    });
  },

  onLoadFail: function(err) {
    this.setState({
      error: err.message
    });
  },

  handleChange: function(evt) {
    var state = {};
    state[evt.target.id] = evt.target.value;
    this.setState(state);
  },

  handleSubmit: function(event) {
    if (!this.formValidator.isValid()) {
      return false;
    }

    this.disableForm();
    event.preventDefault();

    ContainerActions.updateContainer.triggerPromise({
      id: this.state.id,
      name: this.refs.name.getDOMNode().value,
      domain: this.refs.domain.getDOMNode().value
    }).then(this.onUpdate).catch(this.onUpdateFail);
  },

  onUpdate: function(container) {
    this.setState(container);
    this.enableForm();
    this.setState({
      error: null
    });
  },

  onUpdateFail: function(err) {
    this.enableForm();
    this.setState({
      error: err.message || err.error
    });
  },

  disableForm: function() {
    this.refs.name.getDOMNode().disabled = 'disabled';
    this.refs.domain.getDOMNode().disabled = 'disabled';
    $(this.refs.update.getDOMNode()).button('loading');
  },

  enableForm: function() {
    this.refs.name.getDOMNode().removeAttribute('disabled');
    this.refs.domain.getDOMNode().removeAttribute('disabled');
    $(this.refs.update.getDOMNode()).button('reset');
  },

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">Container Details</h3>
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
              <div className="form-group">
                <label>Container Id</label>
                 <p className="form-control-static">{this.state.id}</p>
              </div>
              <div className="form-group">
                <label htmlFor="name">Container Name</label>
                <input ref="name" type="text" className="form-control" id="name" placeholder="" value={this.state.name} onChange={this.handleChange} minlength="5" data-parsley-minlength="5" required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="domain">Domain</label>
                <input ref="domain" type="url" className="form-control" id="domain" placeholder="www.somedomain.com" value={this.state.domain} onChange={this.handleChange} data-parsley-type="url" required />
              </div>
              <div className="form-group">
                <label>Storage Folder</label>
                 <p className="form-control-static">{this.state.storage_namespace}</p>
              </div>
              <div className="form-group">
                <label>Created At</label>
                 <p className="form-control-static">{this.state.created_at}</p>
              </div>
              <div className="form-group">
                <label>Updated At</label>
                 <p className="form-control-static">{this.state.updated_at}</p>
              </div>
              <div className="pull-left">
                <button ref="update" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Updating ..." className="btn btn-primary" type="submit">Update</button>
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to="containers">
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

module.exports = ContainerDetail;
