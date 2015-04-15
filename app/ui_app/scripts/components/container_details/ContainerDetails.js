'use strict';

var React = require('react/addons');
var Router = require('react-router');
var Reflux = require('reflux');
var { Route, DefaultRoute, RouteHandler, Link } = Router;

var ContainerInfoStore = require('../../stores/container_info_store');
var ContainerActions = require('../../actions/container_actions');
var Sidebar = require('./Sidebar');

var ContainerDetails = React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function() {
    var {router} = this.context;
    return {
      error: null,
      container_id: router.getCurrentParams().containerId,
      container_name: 'Loading...',
      container_domain: 'Loading...'
    };
  },

  componentDidMount: function() {
    this.listenTo(ContainerInfoStore, this.onContainerData);
    ContainerActions.getContainer(this.state.container_id);
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

  render: function() {
    return (
      <div className="container-fluid container-details">
        <div className="row">
          <div className="col-md-2"><Sidebar container_id={this.state.container_id} /></div>
          <div className="col-md-10">
            <div className="row">
              <div className="page-header">
                <h1>{this.state.container_name} <small>{this.state.container_domain}</small></h1>
              </div>
            </div>
            <RouteHandler/>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = ContainerDetails;
