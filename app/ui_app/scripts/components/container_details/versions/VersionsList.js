'use strict';

var _ = require('lodash');
var React = require('react');
var VersionActions = require('../../../actions/version_actions');
var VersionsListItem = require('./VersionsListItem');

var VersionsList = React.createClass({
  getInitialState: function() {
    return {};
  },

  loadList: function() {
    VersionActions.load.triggerAsync(this.props.container_id);
  },

  componentWillMount: function() {
    this.loadList();
  },

  getRows: function() {
    var props = _.pick(this.props, 'container_id');

    return this.props.list.map(function(item) {
      return <VersionsListItem {...item} {...props} key={item.version_id} />;
    });
  },

  render: function() {
    return (
      <table className="containers-list table table-bordered table-striped">
        <thead>
          <tr>
            <th>Version Number</th>
            <th>Status</th>
            <th>Created At</th>
            <th>Published At</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {this.props.error && (
            <tr>
              <td colSpan="5" className="text-center">
                <br/>
                <div className="alert alert-danger" role="alert">
                  <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                  <span className="sr-only">Error:</span>
                  &nbsp;&nbsp;{this.props.error}&nbsp;&nbsp;
                  <button onClick={this.loadList} type="button" className="btn btn-default btn-xs">
                    <span className="glyphicon glyphicon-repeat" aria-hidden="true"></span>Reload
                  </button>
                </div>
              </td>
            </tr>
          )}
          {this.props.list.length === 0 && !this.props.error && (
            <tr>
              <td colSpan="4" className="text-center">
                There are no versions at this moment.
              </td>
            </tr>
          )}
          {this.props.list.length > 0 && !this.props.error && this.getRows()}
        </tbody>
      </table>
    );
  }
});

module.exports = VersionsList;
