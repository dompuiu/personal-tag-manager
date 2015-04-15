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
  },

  handleSubmit: function(event) {
    if (!this.formValidator.isValid()) {
      return false;
    }

    this.disableForm();
    event.preventDefault();

    ContainerActions.createContainer.triggerPromise({
      name: this.refs.name.getDOMNode().value,
      domain: this.refs.domain.getDOMNode().value
    }).then(this.onCreate.bind(this)).catch(this.onCreateFail.bind(this));
  },

  onCreate: function(container) {
    var {router} = this.context;
    router.replaceWith('containers/:containerId', {containerId: container.id});
  },

  onCreateFail: function(err) {
    this.enableForm();
    this.setState({
      error: err.message
    });
  },

  disableForm: function() {
    this.refs.name.getDOMNode().disabled = 'disabled';
    this.refs.domain.getDOMNode().disabled = 'disabled';
    $(this.refs.create.getDOMNode()).button('loading');
  },

  enableForm: function() {
    this.refs.name.getDOMNode().removeAttribute('disabled');
    this.refs.domain.getDOMNode().removeAttribute('disabled');
    $(this.refs.create.getDOMNode()).button('reset');
  },

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">Create new container</h3>
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
                <label htmlFor="name">Container name</label>
                <input ref="name" type="text" className="form-control" id="name" placeholder="" minlength="5" data-parsley-minlength="5" required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="domain">Domain</label>
                <input ref="domain" type="url" className="form-control" id="domain" placeholder="www.somedomain.com" data-parsley-type="url" required />
              </div>
              <div className="pull-left">
                <button ref="create" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to="containers">
                  Back to list
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
