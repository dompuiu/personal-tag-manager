'use strict';

var React = require('react');
var Reflux = require('reflux');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;
var _ = require('lodash');

var TagActions = require('../../../actions/tag_actions');
var TagStore = require('../../../stores/tag_store');

var TagUpdate = React.createClass({
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
    this.listenTo(TagStore, this.onTagChange);
  },

  componentDidMount: function() {
    this.formValidator = new Parsley('.container-form form');

    if (this.props.tag_id) {
      TagActions.loadTag.triggerAsync(this.props.container_id, this.props.version_id, this.props.tag_id);
    }
  },

  onTagChange: function(data) {
    if (data.result) {
      if (data.tag.action === 'create') {
        this.onTagCreate(data);
      } else {
        this.onTagLoad(data);
      }
    } else {
      this.setState({
        error: data.error
      });
    }

    this.enableForm();
  },

  onTagCreate: function (data) {
    this.setState({
      id: data.tag.id,
      created_at: data.tag.created_at,
      updated_at: data.tag.updated_at
    });

    this.context.router.replaceWith('tag_details', {
      container_id: data.tag.container_id,
      version_id: data.tag.version_id,
      tag_id: data.tag.id
    },{
      backPath: this.getBackPath()
    });
  },

  onTagLoad: function (data) {
    data.tag.error = null;
    data.tag.initial_type = data.tag.type;
    data.tag.initial_src = data.tag.src;
    if (data.tag.type === 'block-script') {
      data.tag.sync = true;
      data.tag.type = 'script';
    }

    if (data.tag.type === 'block-script' || data.tag.type === 'script') {
      data.tag.url = data.tag.src;
      delete data.tag.src;
    }

    this.setState(data.tag);
  },

  handleChange: function(evt) {
    var state = {};
    if (evt.target.id === 'sync') {
      state[evt.target.id] = evt.target.checked;
    } else {
      state[evt.target.id] = evt.target.value;
    }

    if (evt.target.id === 'type') {
      if (this.state.initial_type !== state.type) {
        state.src = '';
      } else {
        state.src = this.state.initial_src;
      }
    }

    this.setState(state);
  },

  handleSubmit: function(event) {
    event.preventDefault();
    var pickNonfalsy = _.partial(_.pick, _, _.identity);

    if (!this.formValidator.isValid()) {
      return;
    }

    this.disableForm();

    var t = this.state.type;
    var props = this.props;
    var data = pickNonfalsy(this['get' + t[0].toUpperCase() + t.slice(1) + 'Data']());

    if (props.tag_id) {
      TagActions.updateTag.triggerAsync(
        props.container_id,
        props.version_id,
        props.tag_id,
        data
      );
    } else {
      TagActions.createTag.triggerAsync(
        props.container_id,
        props.version_id,
        data
      );
    }
  },

  getHtmlData: function() {
    return {
      name: this.refs.name.getDOMNode().value,
      dom_id: this.refs.dom_id.getDOMNode().value,
      type: this.state.type,
      src: this.refs.src.getDOMNode().value,
      on_load: this.refs.on_load.getDOMNode().value
    };
  },

  getScriptData: function() {
    var sync = this.refs.sync.getDOMNode().checked;

    return {
      name: this.refs.name.getDOMNode().value,
      dom_id: this.refs.dom_id.getDOMNode().value,
      type: sync ? 'block-script' : 'script',
      src: this.refs.url.getDOMNode().value,
      on_load: this.refs.on_load.getDOMNode().value
    };
  },

  getJsData: function() {
    return this.getHtmlData();
  },

  disableForm: function() {
    this.refs.name.getDOMNode().disabled = 'disabled';
    this.refs.dom_id.getDOMNode().disabled = 'disabled';
    this.refs.type.getDOMNode().disabled = 'disabled';
    this.refs.on_load.getDOMNode().disabled = 'disabled';
    $(this.refs.submit.getDOMNode()).button('loading');

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
    this.refs.dom_id.getDOMNode().removeAttribute('disabled');
    this.refs.type.getDOMNode().removeAttribute('disabled');
    this.refs.on_load.getDOMNode().removeAttribute('disabled');
    $(this.refs.submit.getDOMNode()).button('reset');

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
            <h3 className="panel-title">{this.props.tag_id?'Update tag' : 'Create tag'}</h3>
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
              {this.props.tag_id && (
              <div className="form-group">
                <label>Tag Id</label>
                 <p className="form-control-static">{this.state.id}</p>
              </div>
              )}
              <div className="form-group">
                <label htmlFor="name">Name</label>
                <input ref="name" type="text" className="form-control" id="name" onChange={this.handleChange} value={this.state.name} required autoFocus/>
              </div>
              <div className="form-group">
                <label htmlFor="dom_id">Unique ID</label>
                <input ref="dom_id" type="text" className="form-control" id="dom_id" onChange={this.handleChange} value={this.state.dom_id} placeholder="Accepted values: numbers, letters, special characters(- _ .). No spaces allowed." data-parsley-pattern="^[A-Za-z0-9_\-\.]+$" required/>
              </div>
              <div className="form-group">
                <label htmlFor="type">Type</label>
                <select className="form-control" name="type" id="type" ref="type" value={this.state.type} onChange={this.handleChange}>
                  <option value="html">HTML</option>
                  <option value="script">Remote script</option>
                  <option value="js">Inline JavaScript</option>
                </select>
              </div>
              {this.state.type !== 'script' && (
                <div className="form-group">
                  <label htmlFor="src">Source Code</label>
                  <textarea ref="src" id="src" name="src" className="form-control" rows="3" onChange={this.handleChange} required value={this.state.src}></textarea>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="form-group">
                  <label htmlFor="url">URL</label>
                  <input ref="url" type="url" className="form-control" id="url" onChange={this.handleChange} value={this.state.url} data-parsley-type="url" required/>
                </div>
              )}
              {this.state.type === 'script' && (
                <div className="checkbox form-group">
                  <label htmlFor="sync">
                    <input id="sync" ref="sync" checked={this.state.sync} name="sync" type="checkbox" onChange={this.handleChange}/>
                    <strong>Load synchronously</strong>
                  </label>
                </div>
              )}
              <div className="form-group">
                <label htmlFor="on_load">Run the following code after tag is loaded</label>
                <textarea ref="on_load" id="on_load" className="form-control" rows="3" value={this.state.on_load} onChange={this.handleChange}></textarea>
              </div>
              {this.props.tag_id && (
                <div className="form-group">
                  <label>Created At</label>
                   <p className="form-control-static">{this.state.created_at}</p>
                </div>
              )}
              {this.props.tag_id && (
                <div className="form-group">
                  <label>Updated At</label>
                   <p className="form-control-static">{this.state.updated_at}</p>
                </div>
              )}
              <div className="pull-left">
                {this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Updating ..." className="btn btn-primary" type="submit">Update</button>
                )}
                {!this.props.tag_id && (
                  <button ref="submit" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Creating ..." className="btn btn-primary" type="submit">Create</button>
                )}
              </div>
              <div className="pull-right">
                <Link className="btn btn-default" to={this.getBackPath()} params={{container_id: this.props.container_id, version_id: this.props.version_id}}>
                  Back
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

module.exports = TagUpdate;
