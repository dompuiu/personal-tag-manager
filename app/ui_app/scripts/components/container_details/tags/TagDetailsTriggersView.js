'use strict';

var React = require('react');
var TagDetailsTriggersItem = require('./TagDetailsTriggersItem');
var TagActions = require('../../../actions/tag_actions');

var TagDetailsTriggersView = React.createClass({
  onTriggerClick: function() {
    TagActions.newTriggerCondition();
  },

  componentDidUpdate: function() {
    if (this.props.editable) {
      this.enableForm();
    } else {
      this.disableForm();
    }
  },

  disableForm: function() {
    if (this.props.match) {
      this.props.match.forEach(function(item) {
        this.refs['item' + item.id].disableForm();
      }.bind(this));
    }
  },

  enableForm: function() {
    if (this.props.match) {
      this.props.match.forEach(function(item) {
        this.refs['item' + item.id].enableForm();
      }.bind(this));
    }
  },

  render: function() {
    return (
      <div className="panel-body">
        <div className="container-fluid">
          <button type="button" className="btn btn-success" onClick={this.onTriggerClick}>
            <span className="glyphicon glyphicon-lock" aria-hidden="true"></span> Add Trigger Condition
          </button>
        </div>
        {this.props.match && this.props.match.length > 0 && (
          <div className="list-group" style={{marginTop: '10px'}}>
            {this.props.match.map(function(condition) {
              return <TagDetailsTriggersItem ref={'item' + condition.id} {...condition} key={condition.id}/>;
            })}
          </div>
        )}
     </div>
    );
  }
});

module.exports = TagDetailsTriggersView;
