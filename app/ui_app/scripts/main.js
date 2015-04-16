'use strict';

//Load Bootstrap & Parsley in all app modules
window.ParsleyConfig = {
    errorClass: 'has-error',
    successClass: 'has-success',
    classHandler: function(ParsleyField) {
        return ParsleyField.$element.parents('.form-group');
    },
    errorsContainer: function(ParsleyField) {
        return ParsleyField.$element.parents('.form-group');
    },
    errorsWrapper: '<span class="help-block">',
    errorTemplate: '<div></div>'
};

require('bootstrap/dist/css/bootstrap.css');
require('imports?jQuery=jquery!bootstrap/dist/js/bootstrap');

require('parsleyjs/src/parsley.css');
require('imports?jQuery=jquery!parsleyjs/dist/parsley');

require('../styles/main.css');

var React = require('react');
var Router = require('react-router');
var { Route, DefaultRoute, RouteHandler, Link } = Router;

var Index = require('./components/Index');
var Header = require('./components/Header');
var Login = require('./components/Login');
var Logout = require('./components/Logout');
var ContainersView = require('./components/containers/ContainersView');
var ContainerNew = require('./components/containers/ContainerNew');
var ContainerUpdate = require('./components/containers/ContainerUpdate');
var ContainerDetails = require('./components/container_details/ContainerDetails');
var VersionOverview = require('./components/container_details/VersionOverview');

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
    <Route name="containers" handler={ContainersView}/>
    <Route name="containers/new" handler={ContainerNew}/>
    <Route name="containers/:containerId" handler={ContainerUpdate}/>
    <Route name="containers/:containerId/" handler={ContainerDetails}>
      <Route name="versions/overview" handler={VersionOverview}/>
      <Route name="versions/:versionId/tags/new" handler={ContainerNew}/>
    </Route>
  </Route>
);

Router.run(Routes, function (Handler) {
  React.render(<Handler/>, document.getElementById('content'));
});
