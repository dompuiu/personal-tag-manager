'use strict';

require('../../styles/main.css');

var React = require('react/addons');

var Index = React.createClass({
  render: function() {
    return (
      <div className="inner cover">
        <h1 className="cover-heading">Personal Tag Manager</h1>
        <p className="lead">Bachlor's degree project</p>
      </div>
    );
  }
});

module.exports = Index;



