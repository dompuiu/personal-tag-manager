'use strict';

var requireAuth = require('require_auth');
var React = require('react/addons');
var Router = require('react-router');
var Reflux = require('reflux');
var { Route, DefaultRoute, RouteHandler, Link } = Router;

var VersionOverviewStore = require('../../stores/version_overview_store');
var ContainerStore = require('../../stores/container_store');
var ContainerActions = require('../../actions/container_actions');
var VersionActions = require('../../actions/version_actions');
var Sidebar = require('./Sidebar');

var ContainerDetailsView = requireAuth(React.createClass({
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

  loadVersionOverviewData: function() {
    VersionActions.getOverviewInfo.triggerAsync(this.getParams().container_id);
  },

  componentWillMount: function() {
    this.listenTo(VersionOverviewStore, this.onOverviewData);
    this.listenTo(ContainerStore, this.onContainerData);

    ContainerActions.loadContainer.triggerAsync(this.getParams().container_id);
    VersionActions.get(this.getParams().container_id);

    this.loadVersionOverviewData();
  },

  getParams: function() {
    var {router} = this.context;
    return router.getCurrentParams();
  },

  onContainerData: function(data) {
    if (data.result) {
      this.setState({
        error: null,
        container_name: data.container.get('name'),
        container_domain: data.container.get('domain'),
        container_storage_namespace: data.container.get('storage_namespace')
      });
    } else {
      this.setState({
        error: data.error
      });
    }
  },

  onOverviewData: function(data) {
    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    if (data.reload) {
      return this.loadVersionOverviewData();
    }

    var state = {
      error: null,
      editing_version: data.versions_info.editing
    };

    if (data.versions_info.published) {
      state.published_version = data.versions_info.published;
    }

    this.setState(state);
  },

  isEditable: function() {
    if (!this.state.editing_version) {
      return false;
    }
    return this.getParams().version_id === this.state.editing_version.version_id;
  },

  render: function() {
    return (
      <div className="container-fluid container-details">
        <div className="row">
          <div className="col-md-2"><Sidebar {...this.getParams()} editing_version={this.state.editing_version} published_version={this.state.published_version}/></div>
          <div className="col-md-10">
            <div className="row">
              <div className="page-header">
                <h1>{this.state.container_name} <small>{this.state.container_domain}</small></h1>
              </div>
            </div>
            <RouteHandler {...this.getParams()} editing_version={this.state.editing_version} published_version={this.state.published_version} editable={this.isEditable()} storage_namespace={this.state.container_storage_namespace}/>
          </div>
        </div>
      </div>
    );
  }
}));

module.exports = ContainerDetailsView;
