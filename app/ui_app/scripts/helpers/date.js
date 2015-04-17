'use strict';
var _ = require('lodash');

var getDate = function(date_string) {
  var myDate = new Date(date_string),
    data = {
      year: myDate.getFullYear(),
      month: myDate.getMonth() + 1,
      date: myDate.getDate(),
      hours: myDate.getHours(),
      minutes: myDate.getMinutes()
    };

  _.each(['month', 'date', 'hours', 'minutes'], function(key) {
    if (data[key] < 10) {
      data[key] = '0' + data[key];
    }
  });

  return data.year + '-' + data.month + "-" + data.date + ' ' + data.hours + ':' + data.minutes;
};

module.exports = {
  getDate: getDate
};
