'use strict';

var React = require('react');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var TagActions = require('../../../actions/tag_actions');

var TagsListItem = React.createClass({
  getInitialState: function() {
    return {};
  },

  onDelete: function() {
    TagActions.removeTag.triggerAsync(this.props.container_id, this.props.version_id, this.props.id);
  },

  render: function() {
    return (
      <tr>
        <td>
          <Link to="tag_details" params={{container_id: this.props.container_id, version_id: this.props.version_id, tag_id: this.props.id}}>
            {this.props.name}
          </Link>
        </td>
        <td>{this.props.type}</td>
        <td>{this.props.updated_at}</td>
        <td className="options">
            {this.props.editable ? (
              <Link to="tag_details" params={{container_id: this.props.container_id, version_id: this.props.version_id, tag_id: this.props.id}} className="btn btn-default btn-xs">
                <span className="glyphicon glyphicon-edit" aria-hidden="true"></span> Edit
              </Link>
            ):(
              <Link to="tag_details" params={{container_id: this.props.container_id, version_id: this.props.version_id, tag_id: this.props.id}} className="btn btn-default btn-xs">
                <span className="glyphicon glyphicon-eye-open" aria-hidden="true"></span> View
              </Link>
            )}
          &nbsp;
          {this.props.editable && (
            <button onClick={this.onDelete} type="button" className="btn btn-default btn-xs">
              <span className="glyphicon glyphicon-remove" aria-hidden="true"></span> Delete
            </button>
          )}
        </td>
      </tr>
    );
  }
});

module.exports = TagsListItem;
