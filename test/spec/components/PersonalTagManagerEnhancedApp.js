'use strict';

describe('PersonalTagManagerEnhancedApp', function () {
  var React = require('react/addons');
  var PersonalTagManagerEnhancedApp, component;

  beforeEach(function () {
    var container = document.createElement('div');
    container.id = 'content';
    document.body.appendChild(container);

    PersonalTagManagerEnhancedApp = require('components/PersonalTagManagerEnhancedApp.js');
    component = React.createElement(PersonalTagManagerEnhancedApp);
  });

  it('should create a new instance of PersonalTagManagerEnhancedApp', function () {
    expect(component).toBeDefined();
  });
});
