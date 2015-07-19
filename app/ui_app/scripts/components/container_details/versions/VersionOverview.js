'use strict';

var React = require('react');
var Reflux = require('reflux');

var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var VersionOverviewStore = require('../../../stores/version_overview_store');
var VersionActions = require('../../../actions/version_actions');

var VersionOverview = React.createClass({
  mixins: [Reflux.ListenerMixin],

  getInitialState: function() {
    return {
      editing_version: null,
      published_version: null,
      error: null
    };
  },

  getSnippet: function() {
    return "<script src=\"//localhost:8200/libs/" + this.props.storage_namespace + "/ptm.lib.js\"></script>\n<script>ptm.call(\"init\");</script>";
  },

  getStageSnippet: function() {
    return "<script src=\"//localhost:8200/libs/" + this.props.storage_namespace + "/ptm.stage.lib.js\"></script>\n<script>ptm.call(\"init\");</script>";
  },

  onPublishClick: function() {
    VersionActions.publish.triggerAsync(this.props.container_id, this.props.editing_version.version_id);
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
                  {this.props.editing_version && (
                    <h4>
                      <Link to="tag_new" params={{container_id: this.props.container_id, version_id: this.props.editing_version.version_id}} query={{backPath: 'container_overview'}}>
                        New tag
                      </Link>
                    </h4>
                  )}
                  Choose from the supported tag types.
                </div>
                <div className="list-group-item">
                  {this.props.editing_version && (
                    <Link to="tag_new" params={{container_id: this.props.container_id, version_id: this.props.editing_version.version_id}} query={{backPath: 'container_overview'}}>
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
                  {this.props.editing_version && (
                    <div>
                      <div className="pull-right">
                        <button type="button" className="btn btn-primary btn-xs" data-toggle="modal" data-target="#stagingSnippetModal">
                          <span className="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;Get staging container snippet
                        </button>
                      </div>
                      <div className="pull-right" style={{clear:'right', marginTop: '20px'}}>
                        <button type="button" className="btn btn-warning btn-xs" onClick={this.onPublishClick}>
                          <span className="glyphicon glyphicon-log-in" aria-hidden="true"></span>&nbsp;Publish
                        </button>
                      </div>
                    </div>
                  )}
                  <h4>Now editing</h4>
                  {this.props.editing_version && (
                    <strong>Version {this.props.editing_version.version_number}</strong>
                  )}<br/>
                  {this.props.editing_version && (
                    <div className="bottom">Created on: {this.props.editing_version.created_at}</div>
                  )}
                </div>
                {this.props.editing_version && (
                  <div className="list-group-item">Tags: {this.props.editing_version.tags_count}</div>
                )}
                <div className="list-group-item">
                  <Link to="version_list" params={{container_id: this.props.container_id}}>
                    <span className="glyphicon glyphicon-list-alt"></span>&nbsp;View all versions
                  </Link>
                </div>
              </div>
            </div>
            <div className="col-md-4">
              <div className="list-group">
                <div className="list-group-first list-group-item list-group-item-success">
                  {this.props.published_version && (
                    <div className="pull-right">
                      <button type="button" className="btn btn-success btn-xs" data-toggle="modal" data-target="#snippetModal">
                        <span className="glyphicon glyphicon-link" aria-hidden="true"></span>&nbsp;Get container snippet
                      </button>
                    </div>
                  )}
                  {this.props.published_version ? (<h4>Last published</h4>) : (<h4>Container not published</h4>)}
                  {this.props.published_version && (
                    <strong>Version {this.props.published_version.version_number}</strong>
                  )}<br/>
                  {this.props.published_version && (
                    <div className="bottom">Published on: {this.props.published_version.published_at}</div>
                  )}
                </div>
                {this.props.published_version ? (
                  <div className="list-group-item">Tags: {this.props.published_version.tags_count}</div>
                ) : (
                  <div className="list-group-item" style={{paddingBottom: '13px'}}><h4>Add tags and publish to make your changes live</h4></div>
                )}
                {this.props.published_version && (
                  <div className="list-group-item">
                    <Link to="tag_list" params={{container_id: this.props.container_id, version_id: this.props.published_version.version_id}}>
                      <span className="glyphicon glyphicon-tags" aria-hidden="true"></span> View published version tags
                    </Link>
                  </div>
                )}
               </div>
            </div>
          </div>
        )}

        <div className="modal fade" id="snippetModal" tabIndex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 className="modal-title">Install Personal Tag Manager</h4>
              </div>
              <div className="modal-body">
                <p>Copy the code below and paste it onto every page of your website. Place it immediately after the opening &lt;body&gt; tag.</p>
                <textarea ref="src" id="src" name="src" className="form-control" rows="5" readOnly="readonly" value={this.getSnippet()}></textarea>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-default" data-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>

        <div className="modal fade" id="stagingSnippetModal" tabIndex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 className="modal-title">Install Personal Tag Manager - Staging Snippet</h4>
              </div>
              <div className="modal-body">
                <p>You can use this snippet to test your container. The staging library is updated after any tag update.</p>
                <p>Copy the code below and paste it onto every page of your website. Place it immediately after the opening &lt;body&gt; tag.</p>
                <textarea ref="src" id="src" name="src" className="form-control" rows="5" readOnly="readonly" value={this.getStageSnippet()}></textarea>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-default" data-dismiss="modal">Close</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = VersionOverview;
