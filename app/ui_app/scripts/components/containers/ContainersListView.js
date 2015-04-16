'use strict';

var requireAuth = require('../../auth/require_auth');
var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var ContainersListStore = require('../../stores/containers_list_store');
var ContainerList = require('./ContainersList');

var ContainersView = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function () {
    return {list: []};
  },

  componentWillMount: function() {
    this.listenTo(ContainersListStore, this.onChange);
  },

onChange: function(data) {
    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    this.setState({
      error: null,
      list: data.list
    });
  },

  render () {
    return (
      <div className="container-fluid">
        <h1>Containers list</h1>
        <ContainerList list={this.state.list} error={this.state.error} />

        <Link className="btn btn-primary" to="container_new">
          <span className="glyphicon glyphicon-plus" aria-hidden="true"></span>
          New container
        </Link>
      </div>
    );
  }
});

module.exports = ContainersView;
