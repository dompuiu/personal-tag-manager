'use strict';

var ListTag = function (data) {
  this.id = data.id;
  this.name = data.name;
  this.type = data.type;
  this.updated_at = data.updated_at;
};

module.exports = ListTag;
