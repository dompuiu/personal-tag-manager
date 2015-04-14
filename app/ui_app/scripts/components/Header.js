'use strict';

var React = require('react');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;
var auth = require('../auth/auth');


var Header = class extends React.Component {
  constructor (props, context) {
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
  }

  loggedInItems () {
    var { router } = this.context;
    var path = router.getCurrentPathname();

    return (
      <ul className="nav navbar-nav">
        <li className={path === "/containers" ? "active" : ""}><Link to="containers">Containers</Link></li>
        <li><Link to="logout">Log out</Link></li>
      </ul>
    );
  }

  notLoggedInItems () {
    var { router } = this.context;
    var path = router.getCurrentPathname();

    return (
      <ul className="nav navbar-nav">
        <li className={path === "/login" ? "active" : ""}><Link to="login">Log in</Link></li>
      </ul>
    );
  }

  render () {
    return (
      <nav className="navbar navbar-default">
        <div className="container">
          <div className="navbar-header">
            <a className="navbar-brand" href="/">Personal Tag Manager</a>
          </div>
          <div id="navbar" className="navbar-collapse collapse">
              {this.state.loggedIn ? this.loggedInItems() : this.notLoggedInItems()}
          </div>
        </div>
      </nav>
    );
  }
};

Header.contextTypes = {
  router: React.PropTypes.func
};

module.exports = Header;
