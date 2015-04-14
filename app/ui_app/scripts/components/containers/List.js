'use strict';

var requireAuth = require('../../auth/require_auth');
var React = require('react');
var ReactAddOns = require('react/addons');
var ReactTransitionGroup = ReactAddOns.addons.TransitionGroup;

var Header = require('../Header');
var imageURL = require('../../../images/yeoman.png');

var ContainersList = requireAuth(class extends React.Component {
  render () {
    return (
      <div className='main'>
        <ReactTransitionGroup transitionName="fade">
          <img src={imageURL} />
          <div className='main'>
            Hello there
          </div>
        </ReactTransitionGroup>
      </div>
    );
  }
});

module.exports = ContainersList;
