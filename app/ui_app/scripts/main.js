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
var ContainersListView = require('./components/containers/ContainersListView');
var ContainerView = require('./components/containers/ContainerView');
var ContainerDetails = require('./components/container_details/ContainerDetails');
var VersionOverview = require('./components/container_details/versions/VersionOverview');
var TagView = require('./components/container_details/tags/TagView');
var TagListView = require('./components/container_details/tags/TagsListView');
var VersionsListView = require('./components/container_details/versions/VersionsListView');

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
    <Route name="containers" handler={ContainersListView}/>
    <Route name="container_new" path="containers/new" handler={ContainerView}/>
    <Route name="container_details" path="containers/:container_id" handler={ContainerView}/>
    <Route name="containers/:container_id/" handler={ContainerDetails}>
      <Route name="container_overview" path="overview" handler={VersionOverview}/>
      <Route name="tag_new" path="versions/:version_id/tags/new" handler={TagView}/>
      <Route name="tag_details" path="versions/:version_id/tags/:tag_id" handler={TagView}/>
      <Route name="tag_list" path="versions/:version_id/tags/" handler={TagListView}/>
      <Route name="version_list" path="versions" handler={VersionsListView}/>
    </Route>
  </Route>
);

Router.run(Routes, function (Handler) {
  React.render(<Handler/>, document.getElementById('content'));
});
