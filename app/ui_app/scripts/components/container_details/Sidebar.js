'use strict';

var React = require('react');
var Router = require('react-router');
var { Route, RouteHandler, Link } = Router;

var Index = React.createClass({
  render: function() {
    return (
      <div className="panel-group" id="sidebar">
        <div className="panel panel-default">
          <div className="panel-heading">
            <h4 className="panel-title">
            <a data-toggle="collapse" data-parent="#sidebar" href="#collapseOne">
              <span className="glyphicon glyphicon-menu-hamburger">
              </span>Options
            </a>
            </h4>
          </div>
          <div id="collapseOne" className="panel-collapse collapse in">
            <div className="panel-body">
              <table className="table">
                <tr>
                  <td>
                    <Link to="container_overview" params={{container_id: this.props.container_id}}>
                      <span className="glyphicon glyphicon-inbox text-primary"></span>
                      Overview
                    </Link>
                  </td>
                </tr>
                <tr>
                  <td>
                    {this.props.editing_version ? (
                      <Link to="tag_list" params={{container_id: this.props.container_id, version_id: this.props.editing_version.version_id}}>
                        <span className="glyphicon glyphicon-tag text-primary"></span>
                        Tags
                      </Link>
                    ):(
                      <a href="#">
                        <span className="glyphicon glyphicon-tag text-primary"></span>
                        Tags
                      </a>
                    )}
                  </td>
                </tr>
                <tr>
                  <td>
                    <Link to="version_list" params={{container_id: this.props.container_id}}>
                      <span className="glyphicon glyphicon-file text-primary"></span>
                      Versions
                    </Link>
                  </td>
                </tr>
                <tr>
                  <td>
                    <Link to="containers">
                      <span className="glyphicon glyphicon-th text-primary"></span>
                      Back to containers list
                    </Link>
                  </td>
                </tr>
              </table>
            </div>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = Index;



