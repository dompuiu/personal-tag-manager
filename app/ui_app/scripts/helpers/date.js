'use strict';

var getDate = function(date_string) {
  var myDate = new Date(date_string),
    year = myDate.getFullYear(),
    month = myDate.getMonth() + 1,
    date = myDate.getDate(),
    hours = myDate.getHours(),
    minutes = myDate.getMinutes();

  if (month < 10) {
    month = '0' + month;
  }

  return year + '-' + month + "-" + date + ' ' + hours + ':' + minutes;
};

module.exports = {
  getDate: getDate
};
