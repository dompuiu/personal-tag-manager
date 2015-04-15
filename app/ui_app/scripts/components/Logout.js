'use strict';

var React = require('react');
var auth = require('auth');

class Logout extends React.Component {
  componentDidMount () {
    auth.logout();
  }

  render () {
    return (
      <div className="inner cover">
        <p className="lead">You are now logged out</p>
      </div>
    );
  }
}

module.exports = Logout;
