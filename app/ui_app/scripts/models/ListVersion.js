'use strict';

var ListVersion = function (data) {
  this.version_id = data.id;
  this.status = data.status;
  this.version_number = data.version_number;
  this.created_at = data.created_at;
  this.published_at = data.published_at;
};

module.exports = ListVersion;
