'use strict';

var requireAuth = require('require_auth');
var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var TagsListStore = require('../../../stores/tags_list_store');
var VersionsListStore = require('../../../stores/versions_list_store');
var TagsList = require('./TagsList');

var TagsListView = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function () {
    return {list: []};
  },

  componentWillMount: function() {
    this.listenTo(TagsListStore, this.onTagsChange);
    this.listenTo(VersionsListStore, this.onVersionsChange);

    this.setState({
      version_number: VersionsListStore.getVersionNumber(this.props.version_id)
    });
  },

  onTagsChange: function(data) {
    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    this.setState({
      error: null,
      list: data.list
    });
  },

  onVersionsChange: function(data) {
    this.setState({
      version_number: VersionsListStore.getVersionNumber(this.props.version_id)
    });
  },

  render: function() {
    return (
      <div className="container-fluid">
        <h1>Tags list {this.state.version_number && (<small>Version {this.state.version_number}</small>)}</h1>
        <TagsList list={this.state.list} error={this.state.error} editable={this.props.editable} {...this.props}/>
        <div className="pull-right">
            <Link className="btn btn-default" to="version_list" params={{container_id: this.props.container_id}}>Back to versions list</Link>
          </div>
        {this.props.editable && (
          <Link className="btn btn-primary" to="tag_new" params={{container_id: this.props.container_id, version_id: this.props.version_id}}>
            <span className="glyphicon glyphicon-plus" aria-hidden="true"></span> New tag
          </Link>
        )}
      </div>
    );
  }
});

module.exports = TagsListView;
