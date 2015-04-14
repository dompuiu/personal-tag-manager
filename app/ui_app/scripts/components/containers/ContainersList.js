'use strict';

var React = require('react');
var ContainerActions = require('../../actions/container_actions');
var ContainerListItem = require('./ContainerListItem');

var ContainersList = React.createClass({
  componentDidMount: function() {
    ContainerActions.load();
  },

  getContainersRows: function() {
    return this.props.list.map(function(item){
      return <ContainerListItem name={item.name} id={item.id} key={item.id}/>;
    });
  },

  getEmptyMessage: function() {
    return (
      <tr>
        <td colSpan="2" className="text-center">
          There are no containers at this moment.
        </td>
      </tr>
    );
  },

  render: function() {
    var items;

    if (this.props.list.length > 0) {
      items = this.getContainersRows();
    } else {
      items = this.getEmptyMessage();
    }

    return (
      <table className="containers-list table table-bordered table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {items}
        </tbody>
      </table>
    );
  }
});

module.exports = ContainersList;
