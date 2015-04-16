'use strict';

var React = require('react');
var ContainerActions = require('../../actions/container_actions');
var ContainersListItem = require('./ContainersListItem');

var ContainersList = React.createClass({
  getInitialState: function() {
    return {error: null};
  },

  loadList: function() {
    ContainerActions.load.triggerAsync();
  },

  componentWillMount: function() {
    this.loadList();
  },

  getRows: function() {
    return this.props.list.map(function(item){
      return <ContainersListItem name={item.name} id={item.id} key={item.id}/>;
    });
  },

  render: function() {
    return (
      <table className="containers-list table table-bordered table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {this.props.error && (
            <tr>
              <td colSpan="4" className="text-center">
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
              <td colSpan="2" className="text-center">
                There are no tags at this moment.
              </td>
            </tr>
          )}
          {this.props.list.length > 0 && !this.props.error && this.getRows()}
        </tbody>
      </table>
    );
  }
});

module.exports = ContainersList;
