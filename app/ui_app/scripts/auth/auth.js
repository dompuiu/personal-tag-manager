'use strict';

var API_URL = require('api_url');
var request = require('superagent');

function makeLoginRequest(email, pass, cb) {
  request.post(API_URL + '/users/login/')
    .set('Content-Type', 'application/json')
    .send('{"email":"' + email + '","password":"' + pass + '"}')
    .end(function(err, res){
     if (res.ok) {
       cb({authenticated: true, token: btoa(email + ':' + pass)});
     } else {
       cb({authenticated: false});
     }
   });
}

var auth = {
  login (email, pass, cb) {
    cb = arguments[arguments.length - 1];

    makeLoginRequest(email, pass, (res) => {
      if (res.authenticated) {
        localStorage.token = res.token;
        if (cb) {
          cb(true);
        }
        this.onChange(true);
      } else {
        if (cb) {
          cb(false);
        }
        this.onChange(false);
      }
    });
  },

  getToken: function () {
    return localStorage.token;
  },

  logout: function (cb) {
    delete localStorage.token;
    if (cb) {
      cb();
    }
    this.onChange(false);
  },

  loggedIn: function () {
    return !!localStorage.token;
  },

  onChange: function () {}
};

module.exports = auth;
