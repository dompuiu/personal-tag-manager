'use strict';

var React = require('react/addons');
var Router = require('react-router');
var Reflux = require('reflux');
var { Route, DefaultRoute, RouteHandler, Link } = Router;

var VersionOverviewStore = require('../../stores/version_overview_store');
var ContainerStore = require('../../stores/container_store');
var ContainerActions = require('../../actions/container_actions');
var VersionActions = require('../../actions/version_actions');
var Sidebar = require('./Sidebar');

var ContainerDetails = React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function() {
    return {
      error: null,
      container_name: 'Loading...',
      container_domain: 'Loading...'
    };
  },

  componentWillMount: function() {
    this.listenTo(VersionOverviewStore, this.onVersionData);
    this.listenTo(ContainerStore, this.onContainerData);

    ContainerActions.loadContainer.triggerAsync(this.getParams().container_id);
    VersionActions.getOverviewInfo.triggerAsync(this.getParams().container_id);
  },

  getParams: function() {
    var {router} = this.context;
    return router.getCurrentParams();
  },

  onContainerData: function(data) {
    if (data.result) {
      this.setState({
        error: null,
        container_name: data.container.name,
        container_domain: data.container.domain
      });
    } else {
      this.setState({
        error: data.error
      });
    }
  },

  onVersionData: function(data) {
    this.setState({
      version_id: data.versions_info.editing.version_id
    });
  },

  render: function() {
    return (
      <div className="container-fluid container-details">
        <div className="row">
          <div className="col-md-2"><Sidebar {...this.getParams()} version_id={this.state.version_id}/></div>
          <div className="col-md-10">
            <div className="row">
              <div className="page-header">
                <h1>{this.state.container_name} <small>{this.state.container_domain}</small></h1>
              </div>
            </div>
            <RouteHandler {...this.getParams()}/>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = ContainerDetails;
