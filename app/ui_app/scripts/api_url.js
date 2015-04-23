var pkgConfig = require('../../../package.json');
module.exports = window.location.protocol + '//' + window.location.hostname + ':' + pkgConfig.api_app_port;
