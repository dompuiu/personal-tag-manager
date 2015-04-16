'use strict';

var requireAuth = require('require_auth');
var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var TagsListStore = require('../../../stores/tags_list_store');
var TagsList = require('./TagsList');

var TagsListView = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function () {
    return {list: []};
  },

  componentWillMount: function() {
    this.listenTo(TagsListStore, this.onChange);
  },

  onChange: function(data) {
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

  render () {
    return (
      <div className="container-fluid">
        <h1>Tags list</h1>
        <TagsList list={this.state.list} error={this.state.error} {...this.props} />
        <Link className="btn btn-primary" to="tag_new" params={{container_id: this.props.container_id, version_id: this.props.version_id}}>
          <span className="glyphicon glyphicon-plus" aria-hidden="true"></span>
          New tag
        </Link>
      </div>
    );
  }
});

module.exports = TagsListView;
