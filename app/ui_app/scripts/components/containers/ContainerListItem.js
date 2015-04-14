'use strict';

var React = require('react');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var ContainerActions = require('../../actions/container_actions');

var ContainerItem = React.createClass({
  onDelete: function() {
    ContainerActions.removeContainer.triggerAsync(this.props.id);
  },

  render: function() {
    return (
      <tr>
        <td>{this.props.name}</td>
        <td className="options">
          <Link to="containers/:containerId/versions/current" params={{containerId: this.props.id}} className="btn btn-default btn-xs">
            <span className="glyphicon glyphicon-tag" aria-hidden="true"></span> Tags
          </Link>
          &nbsp;
          <Link to="containers/:containerId" params={{containerId: this.props.id}} className="btn btn-default btn-xs">
            <span className="glyphicon glyphicon-wrench" aria-hidden="true"></span> Settings
          </Link>
          &nbsp;
          <button onClick={this.onDelete} type="button" className="btn btn-default btn-xs">
            <span className="glyphicon glyphicon-remove" aria-hidden="true"></span> Delete
          </button>
        </td>
      </tr>
    );
  }
});

module.exports = ContainerItem;
