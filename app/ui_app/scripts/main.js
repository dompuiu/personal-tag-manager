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
var { Route, RouteHandler, Link } = Router;

var auth = require('./auth');
var ContainersList = require('./components/ContainersList');
var Login = require('./components/Login');
var Logout = require('./components/Logout');

class App extends React.Component {
  constructor () {
    this.state = {
      loggedIn: auth.loggedIn()
    };
  }

  setStateOnAuth (loggedIn) {
    this.setState({
      loggedIn: loggedIn
    });
  }

  componentWillMount () {
    auth.onChange = this.setStateOnAuth.bind(this);
    auth.login();
  }

  render () {
    return (
      <div>
        <ul>
          <li>
            {this.state.loggedIn ? (
              <Link to="logout">Log out</Link>
            ) : (
              <Link to="login">Sign in</Link>
            )}
          </li>
          <li><Link to="containers">Containers</Link></li>
        </ul>
        <RouteHandler/>
      </div>
    );
  }
}

var Routes = (
  <Route handler={Login}>
    <Route name="login" handler={Login}/>
    <Route name="logout" handler={Logout}/>
    <Route name="containers" handler={ContainersList}/>
  </Route>
);

Router.run(Routes, function (Handler) {
  React.render(<Handler/>, document.getElementById('content'));
});
