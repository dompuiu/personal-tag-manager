'use strict';

//Load Bootstrap & Parsley in all app modules
require('bootstrap/dist/css/bootstrap.css');
require('imports?jQuery=jquery!bootstrap/dist/js/bootstrap');

require('parsleyjs/src/parsley.css');
require('imports?jQuery=jquery!parsleyjs/dist/parsley');

// CSS
require('normalize.css');

var React = require('react');
var Router = require('react-router');
var { Route, DefaultRoute, RouteHandler, Link } = Router;

var auth = require('./auth/auth');
var Index = require('./components/Index');
var Header = require('./components/Header');
var Login = require('./components/Login');
var Logout = require('./components/Logout');
var ContainersList = require('./components/containers/List');

class App extends React.Component {
  render () {
    return (
      <div>
        <Header />
        <RouteHandler/>
      </div>
    );
  }
}

var Routes = (
  <Route handler={App}>
    <DefaultRoute handler={Index}/>
    <Route name="login" handler={Login}/>
    <Route name="logout" handler={Logout}/>
    <Route name="containers" handler={ContainersList}/>
  </Route>
);

Router.run(Routes, function (Handler) {
  React.render(<Handler/>, document.getElementById('content'));
});
