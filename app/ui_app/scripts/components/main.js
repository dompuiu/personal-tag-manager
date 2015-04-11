'use strict';

var PersonalTagManagerEnhancedApp = require('./PersonalTagManagerEnhancedApp');
var React = require('react');
var Router = require('react-router');
var Route = Router.Route;

var content = document.getElementById('content');

var Routes = (
  <Route handler={PersonalTagManagerEnhancedApp}>
    <Route name="/" handler={PersonalTagManagerEnhancedApp}/>
  </Route>
);

Router.run(Routes, function (Handler) {
  React.render(<Handler/>, content);
});
