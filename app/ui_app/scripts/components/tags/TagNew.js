'use strict';

var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;
var _ = require('lodash');

var TagActions = require('../../actions/tag_actions');
var TagCreateStore = require('../../stores/tag_create_store');

var TagNew = React.createClass({
  mixins: [Reflux.ListenerMixin],

  contextTypes: {
    router: React.PropTypes.func
  },

  getInitialState: function() {
    return {
      type: 'html'
    };
  },

  componentWillMount: function() {
    this.listenTo(TagCreateStore, this.onTagCreate);
  },

  componentDidMount: function() {
    this.formValidator = new Parsley('.container-form form');
  },

  onTagCreate: function(data) {
    if (data.result) {
      this.context.router.replaceWith('tag_details', {
        container_id: data.tag.container_id,
        version_id: data.tag.version_id,
        tag_id: data.tag.id
      });
    } else {
      this.setState({
        error: data.error
      });
    }

    this.enableForm();
  },

  onTypeChange: function(event) {
    this.setState({type: event.target.value});
  },

  handleSubmit: function(event) {
    event.preventDefault();

    if (!this.formValidator.isValid()) {
      return;
    }

    this.disableForm();

    var t = this.state.type;
    var pickNonfalsy = _.partial(_.pick, _, _.identity);

    var data = pickNonfalsy(this['get' + t[0].toUpperCase() + t.slice(1) + 'Data']());
    var props = this.props;

    TagActions.createTag.triggerAsync(props.container_id, props.version_id, data);
  },

  getHtmlData: function() {
    return {
      name: this.refs.name.getDOMNode().value,
      dom_id: this.refs.domid.getDOMNode().value,
      type: this.state.type,
      src: this.refs.src.getDOMNode().value,
      on_load: this.refs.onload.getDOMNode().value
    };
  },

  getScriptData: function() {
    var sync = this.refs.sync.getDOMNode().checked;

    return {
      name: this.refs.name.getDOMNode().value,
      dom_id: this.refs.domid.getDOMNode().value,
      type: sync ? 'block-script' : 'script',
      src: this.refs.url.getDOMNode().value,
      on_load: this.refs.onload.getDOMNode().value
    };
  },

  getJsData: function() {
    return this.getHtmlData();
  },

  disableForm: function() {
    this.refs.name.getDOMNode().disabled = 'disabled';
    this.refs.domid.getDOMNode().disabled = 'disabled';
    this.refs.type.getDOMNode().disabled = 'disabled';
    this.refs.onload.getDOMNode().disabled = 'disabled';
    $(this.refs.create.getDOMNode()).button('loading');

    if (this.refs.src) {
      this.refs.src.getDOMNode().disabled = 'disabled';
    }

    if (this.refs.sync) {
      this.refs.sync.getDOMNode().disabled = 'disabled';
    }

    if (this.refs.url) {
      this.refs.url.getDOMNode().disabled = 'disabled';
    }

  },

  enableForm: function() {
    this.refs.name.getDOMNode().removeAttribute('disabled');
    this.refs.domid.getDOMNode().removeAttribute('disabled');
    this.refs.type.getDOMNode().removeAttribute('disabled');
    this.refs.onload.getDOMNode().removeAttribute('disabled');
    $(this.refs.create.getDOMNode()).button('reset');

    if (this.refs.src) {
      this.refs.src.getDOMNode().removeAttribute('disabled');
    }

    if (this.refs.url) {
      this.refs.url.getDOMNode().removeAttribute('disabled');
    }

    if (this.refs.sync) {
      this.refs.sync.getDOMNode().removeAttribute('disabled');
    }
  },

  render: function() {
    return (
      <div className="container container-form">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">Create new tag</h3>
          </div>
          <div className="panel-body">
            {this.state.error && (
              <div className="alert alert-danger" role="alert">
                <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                <span className="sr-only">Error:</span>
                &nbsp;&nbsp;{this.state.error}
              </div>
            )}
            <form onSubmit={this.handleSubmit}>
              <div className="form-group">
                <label htmlFor="name">Name</label>
                <input ref="name" type="text" className="form-control" id="name" required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="domid">Unique ID</label>
                <input ref="domid" type="text" className="form-control" id="domid" placeholder="Accepted values: numbers, letters, special characters(- _ .). No spaces allowed." data-parsley-pattern="^[A-Za-z0-9_\-\.]+$" required/>
              </div>
              <div className="form-group">
                <label htmlFor="type">Type</label>
                <select className="form-control" name="type" ref="type" value={this.state.type} onChange={this.onTypeChange}>
                  <option value="html">HTML</option>
                  <option value="script">Remote script</option>
                  <option value="js">Inline JavaScript</option>
                </select>
              </div>
              {this.state.type !== 'script' && (
                <div className="form-group">
                  <label htmlFor="src">Source Code</label>
                  <textarea ref="src" id="src" name="src" className="form-control" rows="3" required></textarea>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="form-group">
                  <label htmlFor="url">URL</label>
                  <input ref="url" type="url" className="form-control" id="url" data-parsley-type="url" required/>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="checkbox form-group">
                  <label htmlFor="sync">
                    <input id="sync" ref="sync" name="sync" type="checkbox"/>
                    <strong>Load synchronously</strong>
                  </label>
                </div>
              )}
              <div className="form-group">
                <label htmlFor="onload">Run the following code after tag is loaded</label>
                <textarea ref="onload" id="onload" className="form-control" rows="3"></textarea>
              </div>
              <div className="pull-left">
                <button ref="create" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to="container_overview" params={{container_id: this.props.container_id}}>
                  Cancel
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

module.exports = TagNew;
