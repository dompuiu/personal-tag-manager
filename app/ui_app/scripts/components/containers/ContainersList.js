'use strict';

var React = require('react');
var ContainerActions = require('../../actions/container_actions');
var ContainerListItem = require('./ContainerListItem');

var ContainersList = React.createClass({
  getInitialState: function() {
    return {error: null};
  },

  load: function() {
    ContainerActions.load.triggerAsync();
  },

  componentWillMount: function() {
    this.load();
  },

  onLoadFail: function() {
    this.setState({
      error: 'Cannot load list from server'
    });
  },

  getContainersRows: function() {
    return this.props.list.map(function(item){
      return <ContainerListItem name={item.name} id={item.id} key={item.id}/>;
    });
  },

  getErrorMessage: function() {
    return (
      <tr>
        <td colSpan="2" className="text-center">
          <br/>
          <div className="alert alert-danger" role="alert">
            <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
            <span className="sr-only">Error:</span>
            &nbsp;&nbsp;{this.state.error}&nbsp;&nbsp;
            <button onClick={this.loadList} type="button" className="btn btn-default btn-xs">
              <span className="glyphicon glyphicon-repeat" aria-hidden="true"></span>Reload
            </button>
          </div>
        </td>
      </tr>
    );
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
    if (this.state.error) {
      items = this.getErrorMessage();
    } else if (this.props.list.length > 0) {
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
