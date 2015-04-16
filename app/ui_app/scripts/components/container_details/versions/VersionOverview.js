'use strict';

var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var VersionOverviewStore = require('../../../stores/version_overview_store');
var VersionsActions = require('../../../actions/version_actions');

var VersionOverview = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function() {
    return {
      editing_version: null,
      published_version: null,
      error: null
    };
  },

  componentWillMount: function() {
    this.listenTo(VersionOverviewStore, this.onOverviewData);
    VersionsActions.getOverviewInfo.triggerAsync(this.props.container_id);
  },

  onOverviewData: function(data) {
    if (data.result) {
      var state = {
        error: null,
        editing_version: data.versions_info.editing
      };

      if (data.versions_info.published) {
        state.published_version = data.versions_info.published;
      }

      this.setState(state);
    } else {
      this.setState({
        error: data.error
      });
    }
  },

  render: function() {
    return (
      <div className="container-fluid container-overview">
        {this.state.error ? (
          <div className="alert alert-danger" role="alert">
          <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
          <span className="sr-only">Error:</span>
          &nbsp;&nbsp;{this.state.error}
          </div>
        ):(
          <div className="row">
            <div className="col-md-4">
              <div className="list-group">
                <div className="list-group-first list-group-item">
                  {this.state.editing_version && (
                    <h4>
                      <Link to="tag_new" params={{container_id: this.props.container_id, version_id: this.state.editing_version.version_id}} query={{backPath: 'container_overview'}}>
                        New tag
                      </Link>
                    </h4>
                  )}
                  Choose from the supported tag types.
                </div>
                <div className="list-group-item">
                  {this.state.editing_version && (
                    <Link to="tag_new" params={{container_id: this.props.container_id, version_id: this.state.editing_version.version_id}} query={{backPath: 'container_overview'}}>
                      <span className="glyphicon glyphicon-tag"></span>
                      &nbsp;Add new tag
                    </Link>
                  )}
                </div>
              </div>
            </div>
            <div className="col-md-4">
              <div className="list-group">
                <div className="list-group-first list-group-item list-group-item-info">
                  <h4>Now editing</h4>
                  {this.state.editing_version && (
                    <strong>Version {this.state.editing_version.version_number}</strong>
                  )}<br/>
                  {this.state.editing_version && (
                    <div className="bottom">Created on: {this.state.editing_version.created_at}</div>
                  )}
                </div>
                {this.state.editing_version && (
                  <div className="list-group-item">Tags: {this.state.editing_version.tags_count}</div>
                )}
                <div className="list-group-item">
                  <a href="#"><span className="glyphicon glyphicon-list-alt"></span>&nbsp;View all versions</a>
                </div>
              </div>
            </div>
            <div className="col-md-4">
              <div className="list-group">
                <div className="list-group-first list-group-item list-group-item-success">
                  {this.state.published_version ? (<h4>Last published</h4>) : (<h4>Container not published</h4>)}
                  {this.state.published_version && (
                    <strong>Version {this.state.published_version.version_number}</strong>
                  )}<br/>
                  {this.state.published_version && (
                    <div className="bottom">Published on: {this.state.published_version.published_at}</div>
                  )}
                </div>
                {this.state.published_version ? (
                  <div className="list-group-item">Tags: {this.state.published_version.tags_count}</div>
                ) : (
                  <div className="list-group-item" style={{paddingBottom: '13px'}}><h4>Add tags and publish to make your changes live</h4></div>
                )}
                {this.state.published_version && (
                  <div className="list-group-item"> <a href="#"><span className="glyphicon glyphicon-list-alt"></span>&nbsp;View published version</a></div>
                )}
               </div>
            </div>
          </div>
        )}
      </div>
    );
  }
});

module.exports = VersionOverview;
