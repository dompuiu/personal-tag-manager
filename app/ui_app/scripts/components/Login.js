var React = require('react');
var auth = require('auth');

require('../../styles/login.css');

class Login extends React.Component {

  constructor () {
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state = {
      error: false
    };
  }

  disableForm () {
    this.refs.email.getDOMNode().disabled = 'disabled';
    this.refs.pass.getDOMNode().disabled = 'disabled';
    $(this.refs.signin.getDOMNode()).button('loading');
  }

  enableForm () {
    this.refs.email.getDOMNode().removeAttribute('disabled');
    this.refs.pass.getDOMNode().removeAttribute('disabled');
    $(this.refs.signin.getDOMNode()).button('reset');
  }

  handleSubmit (event) {
    if (!this.formValidator.isValid()) {
      return false;
    }

    event.preventDefault();
    this.disableForm();

    var { router } = this.context;
    var nextPath = router.getCurrentQuery().nextPath;

    var email = this.refs.email.getDOMNode().value;
    var pass = this.refs.pass.getDOMNode().value;

    auth.login(email, pass, (loggedIn) => {
      if (!loggedIn) {
        this.enableForm();
        return this.setState({ error: true });
      }
      if (nextPath) {
        router.transitionTo(nextPath);
      } else {
        router.transitionTo('/');
      }
    });
  }

  componentDidMount () {
    this.formValidator = new Parsley('.form-signin');
  }

  render () {
    return (
      <div className="container form-signin-container">
        <div className="mainbox col-md-6 col-md-offset-3 col-sm-8 col-sm-offset-2">
          <div className="panel panel-info">
            <div className="panel-heading">
              <div className="panel-title">Sign In</div>
            </div>
            <div className="panel-body">
              {this.state.error && (
              <p>Bad login information</p>
              )}
              <form className="form-signin" onSubmit={this.handleSubmit}>
                <label for="inputEmail" className="sr-only">Email address</label>
                <input ref="email" type="email" id="inputEmail" className="form-control" defaultValue="admin@somedomain.com" placeholder="Email address" required autofocus />
                <label for="inputPassword" className="sr-only">Password</label>
                <input ref="pass" type="password" id="inputPassword" className="form-control" placeholder="Password" required />
                <button ref="signin" data-loading-text="<span class='glyphicon glyphicon-refresh spinning'></span> Signing in..." className="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

Login.contextTypes = {
  router: React.PropTypes.func
};

module.exports = Login;
