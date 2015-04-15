'use strict';

var React = require('react');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var ContainerActions = require('../../actions/container_actions');

var ContainerItem = React.createClass({
  getInitialState: function() {
    return {error: null};
  },

  onDelete: function() {
    ContainerActions.removeContainer(this.props.id).catch(this.onDeleteFail);
  },

  onDeleteFail: function() {
    this.setState({
      error: 'Cannot delete container'
    });
  },

  render: function() {
    return (
      <tr>
        <td>
          <Link to="versions/overview" params={{containerId: this.props.id}}>
            {this.props.name}
          </Link>
          &nbsp;
          {this.state.error && (
            <span title={this.state.error} className="glyphicon glyphicon-remove-sign" aria-hidden="true"></span>
          )}
        </td>
        <td className="options">
          <Link to="versions/overview" params={{containerId: this.props.id}} className="btn btn-default btn-xs">
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
