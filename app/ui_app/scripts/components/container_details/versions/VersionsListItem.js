'use strict';

var React = require('react');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var VersionActions = require('../../../actions/version_actions');

var VersionsListItem = React.createClass({
  getInitialState: function() {
    return {};
  },

  onPublish: function() {
    VersionActions.publish.triggerAsync(this.props.container_id, this.props.version_id);
  },

  render: function() {
    return (
      <tr>
        <td>
          Version {this.props.version_number}
        </td>
        <td>
          {this.props.status}
        </td>
        <td>
          {this.props.created_at}
        </td>
        <td>
          {this.props.published_at}
        </td>
        <td className="options">
          <Link to="tag_list" params={{container_id: this.props.container_id, version_id: this.props.version_id}} className="btn btn-default btn-xs">
            <span className="glyphicon glyphicon-tags" aria-hidden="true"></span> View tags
          </Link>
          &nbsp;
          <button onClick={this.onPublish} type="button" className="btn btn-default btn-xs">
            <span className="glyphicon glyphicon-log-in" aria-hidden="true"></span> Publish
          </button>
        </td>
      </tr>
    );
  }
});

module.exports = VersionsListItem;
