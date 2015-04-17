'use strict';

var requireAuth = require('require_auth');
var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var VersionsListStore = require('../../../stores/versions_list_store');
var VersionsList = require('./VersionsList');

var VersionActions = require('../../../actions/version_actions');

var VersionsListView = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function () {
    return {list: []};
  },

  componentWillMount: function() {
    this.listenTo(VersionsListStore, this.onChange);
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
        <h1>Versions list</h1>
        <VersionsList list={this.state.list} error={this.state.error} {...this.props} />
        <div className="pull-right">
          <Link className="btn btn-default" to="container_overview" params={{container_id: this.props.container_id}}>Back to Overview</Link>
        </div>
      </div>
    );
  }
});

module.exports = VersionsListView;
