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

  onListChange: function(list) {
    this.setState({
      list: list
    });
  },

  componentDidMount: function() {
    this.listenTo(ContainersListStore, this.onListChange);
  },

  render () {
    return (
      <div className="container-fluid">
        <h1>Containers list</h1>
        <ContainerList list={this.state.list} />

        <Link className="btn btn-primary" to="containers/new">
          <span className="glyphicon glyphicon-plus" aria-hidden="true"></span>
          New container
        </Link>
      </div>
    );
  }
});

module.exports = ContainersView;
