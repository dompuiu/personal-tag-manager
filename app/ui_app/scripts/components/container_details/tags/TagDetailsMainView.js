'use strict';

var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var TagActions = require('../../../actions/tag_actions');
var TagStore = require('../../../stores/tag_store');
var Tag = require('../../../models/Tag');

var TagDetailsTriggersView = require('./TagDetailsTriggersView');
var TagDetailsGeneralView = require('./TagDetailsGeneralView');

var TagView = React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  componentWillMount: function() {
    this.listenTo(TagStore, this.onTagChange);

    if (this.props.tag_id) {
      TagActions.loadTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        this.props.tag_id
      );
    } else {
      TagActions.new();
    }
  },

  componentDidMount: function() {
    this.formValidator = new Parsley('.container-form form');
  },

  onTagChange: function(data) {
    if (data.redirect) {
      return this.context.router.transitionTo('tag_details', {
        container_id: data.redirect.container_id,
        version_id: data.redirect.version_id,
        tag_id: data.redirect.tag_id
      },{
        backPath: this.getBackPath()
      });
    }

    if (!data.result) {
      return this.setState({
        error: data.error
      });
    }

    this.setState(data.tag);
  },

  disableForm: function() {
    if (this.refs.submit) {
      $(this.refs.submit.getDOMNode()).button('loading');
    }
  },

  enableForm: function() {
    if (this.refs.submit) {
      $(this.refs.submit.getDOMNode()).button('reset');
    }
  },

  handleSubmit: function(event) {
    event.preventDefault();

    if (!this.formValidator.isValid()) {
      return;
    }

    this.disableForm();
    this.refs.general_view.disableForm();

    if (this.props.tag_id) {
      TagActions.updateTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        this.props.tag_id,
        TagStore.getActionData()
      );
    } else {
      TagActions.createTag.triggerAsync(
        this.props.container_id,
        this.props.version_id,
        TagStore.getActionData()
      );
    }
  },

  getBackPath: function() {
    var { router } = this.context;
    var backPath = router.getCurrentQuery().backPath;
    if (!backPath) {
      backPath = 'tag_list';
    }

    return backPath;
  },

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">
              {this.props.editable && (this.props.tag_id ? 'Update tag' : 'Create tag')}
              {!this.props.editable && 'View tag'}
            </h3>
          </div>
          <div className="panel-body">
            {this.state && this.state.error && (
              <div className="alert alert-danger" role="alert">
                <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                <span className="sr-only">Error:</span>
                &nbsp;&nbsp;{this.state.error}
              </div>
            )}
            <form onSubmit={this.handleSubmit}>
              <div className="panel-group" id="tag-view-accordion" role="tablist" aria-multiselectable="true">
                <div className="panel panel-default">
                  <div className="panel-heading" role="tab" id="tag-view-general-details-heading">
                    <h4 className="panel-title">
                    <a data-toggle="collapse" data-parent="#tag-view-accordion" href="#tag-view-general-details" aria-expanded="true" aria-controls="tag-view-general-details">
                      Tag Details
                    </a>
                    </h4>
                  </div>
                  <div id="tag-view-general-details" className="panel-collapse collapse in" role="tabpanel" aria-labelledby="tag-view-general-details-heading">
                    <TagDetailsGeneralView ref="general_view" {...this.state} editable={this.props.editable} />
                  </div>
                </div>
                <div className="panel panel-default">
                  <div className="panel-heading" role="tab" id="tag-view-trigger-details-heading">
                    <h4 className="panel-title">
                    <a className="collapsed" data-toggle="collapse" data-parent="#tag-view-accordion" href="#tag-view-trigger-details" aria-expanded="false" aria-controls="tag-view-trigger-details">
                      Trigger Conditions
                    </a>
                    </h4>
                  </div>
                  <div id="tag-view-trigger-details" className="panel-collapse collapse" role="tabpanel" aria-labelledby="tag-view-trigger-details-heading">
                    <TagDetailsTriggersView />
                  </div>
                </div>
              </div>

              <div className="pull-left">
                {this.props.editable && this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Updating ..." className="btn btn-primary" type="submit">Update</button>
                )}
                {this.props.editable && !this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
                )}
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to={this.getBackPath()} params={{container_id: this.props.container_id, version_id: this.props.version_id}}>
                  {this.props.tag_id ? 'Back' : 'Cancel'}
                </Link>
              </div>
            </form>
          </div>
        </div>
        {this.formValidator && this.formValidator.reset()}
      </div>
    );
  }
});

module.exports = TagView;
