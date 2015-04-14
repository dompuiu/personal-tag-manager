'use strict';

require('../../styles/main.css');

var React = require('react');
var auth = require('../auth/auth');

class Logout extends React.Component {
  componentDidMount () {
    auth.logout();
  }

  render () {
    return (
      <div className="inner cover">
        <h1 className="cover-heading">Personal Tag Manager</h1>
        <p className="lead">You are now logged out</p>
      </div>
    );
  }
}

module.exports = Logout;
