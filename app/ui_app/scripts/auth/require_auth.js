'use strict';
var auth = require('auth');
var React = require('react');

var requireAuth = (Component) => {
  return class Authenticated extends React.Component {
    static willTransitionTo(transition) {
      if (!auth.loggedIn()) {
        transition.redirect('/login', {}, {'nextPath' : transition.path});
      }
    }
    render () {
      return <Component {...this.props}/>;
    }
  };
};

module.exports = requireAuth;
