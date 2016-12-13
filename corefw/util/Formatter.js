// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.util.Formatter', {
  alternateClassName: 'CorefwFormatter',
  singleton: true,
  constructor: function() {
    var NEGATIVE_VALUE_SIGN, NUMBER_FONTSTYLE;
    NUMBER_FONTSTYLE = '';
    NEGATIVE_VALUE_SIGN = '- ';
    this.varianceMap = {
      'DifferencePercentage': 'DifferencePercentage',
      'DifferenceValue': 'DifferenceValue',
      'ActualValue': 'NonControlValue',
      'AbsoluteDiffValue': 'AbsoluteDiffValue'
    };
    this.varianceNameMap = {
      'DifferencePercentage': 'DifferencePercentage',
      'DifferenceValue': 'DifferenceValue',
      'NonControlValue': 'ActualValue',
      'AbsoluteDiffValue': 'AbsoluteDiffValue'
    };
    this.formatBDMonthlyTimeMark = function(value) {
      var formattedString, p, testStringList;
      p = new RegExp('~M');
      formattedString = CorefwFormatter.formatDate(value.split('-D')[0].split('-M')[0], p.test(value) ? 'ForDisplayM' : 'ForDisplayD');
      testStringList = value.split('~');
      if (testStringList[5] === 'Daily') {
        return formattedString;
      }
      return formattedString + ' BD' + testStringList[4];
    };
    this.formatRelativeDate = function(value, type) {
      var displayParts, relativeTimeDisplayString, timeMarkKey, timeMarkKeyDisplay;
      relativeTimeDisplayString = '';
      if (value.indexOf(' (') > 1) {
        displayParts = value.split(' (');
        relativeTimeDisplayString = displayParts[0];
        timeMarkKey = displayParts[1].split(')')[0];
      } else {
        timeMarkKey = value;
      }
      timeMarkKeyDisplay = void 0;
      if (timeMarkKey.split('~M').length > 1) {
        timeMarkKeyDisplay = CorefwFormatter.formatBDMonthlyTimeMark(timeMarkKey);
      } else {
        timeMarkKeyDisplay = CorefwFormatter.formatDate(timeMarkKey.split('~D')[0], 'ForDisplayD');
      }
      return relativeTimeDisplayString + ' (' + timeMarkKeyDisplay + ')';
    };
    this.formatDate = function(value, type) {
      var bd, dateValue, day, formattedDate, formattedDateList, isSubtotal, month, returnDate, returnDateArray, seperator, subtotalSuffix, temps, valueList, year;
      dateValue = this.parseDateValue(value);
      subtotalSuffix = ' - Sub Total';
      isSubtotal = Ext.String.endsWith(value, subtotalSuffix);
      temps = null;
      if (dateValue === null || dateValue === void 0 || dateValue.toString() === 'NaN' || dateValue.toString() === 'Invalid Date') {
        return value;
      } else if (type === 'ForJavaMM') {
        formattedDate = Ext.Date.format(dateValue, 'Y-n-j-H-i-s');
        formattedDateList = formattedDate.split('-');
        seperator = '~';
        return formattedDateList[0] + seperator + formattedDateList[1] + seperator + '0' + seperator + formattedDateList[2] + seperator + '0';
      } else if (type === 'ForDisplayD') {
        returnDate = Ext.Date.format(dateValue, 'M j Y');
        returnDateArray = returnDate.split(' ');
        if (returnDateArray[1].length === 1) {
          returnDate = returnDate.replace(returnDateArray[1], '0' + returnDateArray[1]);
        }
        if (isSubtotal) {
          return returnDate + subtotalSuffix;
        } else {
          return returnDate;
        }
      } else if (type === 'ForDisplayM') {
        return Ext.Date.format(dateValue, 'M Y');
      } else if (type === 'ForDisplayMBD') {
        temps = Ext.Date.format(dateValue, 'M-j-Y').split('-');
        return temps[0] + ' ' + temps[2] + ' BD' + temps[1];
      } else if (type === 'ForDisplayTimeMark') {
        valueList = value.split('~');
        temps = Ext.Date.format(dateValue, 'M-j-Y').split('-');
        month = temps[0];
        day = temps[1];
        bd = valueList[4];
        year = temps[2];
        if (value.indexOf('Monthly') > 0) {
          return month + ' ' + year + ' BD' + bd;
        } else if (value.indexOf('Daily') > 0) {
          return month + ' ' + year + ' ' + day;
        }
        return month + ' ' + year + ' BD' + bd;
      }
    };
    this.parseDateValue = function(value) {
      var data, dataString, dateValue, pad, str, tmp;
      dateValue = null;
      tmp = [];
      str = void 0;
      pad = function(n) {
        if (n < 10 && n.toString().length === 1) {
          return '0' + n;
        } else {
          return n;
        }
      };
      dateValue = Ext.Date.parse(value, 'Y-m-d');

      /**
      			 * IE Date parser needs '01' instead of '1' as month parameter, same logic to day parameter.
       */
      if (!dateValue && value && typeof value === 'string') {
        tmp = value.split('-');
        if (tmp && tmp.length >= 3) {
          if (tmp[2] <= 31 && tmp[2] >= 1) {
            str = tmp[0] + '-' + pad(parseInt(tmp[1])) + '-' + pad(parseInt(tmp[2]));
            dateValue = Ext.Date.parse(str, 'Y-m-d');
          } else {
            str = tmp[0] + '-' + pad(parseInt(tmp[1]) + '-' + 1);
            dateValue = Ext.Date.parse(str, 'Y-m');
          }
        }
      }
      if (dateValue === null || dateValue === 'NaN' || dateValue === void 0) {
        dateValue = Ext.Date.parse(value, 'Y-n-j-H-i-s');
      }
      if (dateValue === null || dateValue === 'NaN' || dateValue === void 0) {
        dateValue = new Date(value);
      }
      if (dateValue === null || dateValue === void 0 || dateValue.toString() === 'NaN' || dateValue.toString() === 'Invalid Date') {
        data = value.split('~');
        dataString = data[0] + '-' + pad(data[1]);
        if (pad(data[3]) !== '00') {
          dateValue = Ext.Date.parse(dataString + '-' + pad(data[3]), 'Y-m-d');
        } else {
          dateValue = Ext.Date.parse(dataString, 'Y-m');
        }
      }
      return dateValue;
    };
    this.getSpecailNum = function(value) {
      var specailNum, _value;
      _value = (value + '').toUpperCase();
      specailNum = {
        'NAN': 'N/A',
        '+INFINITY': '+Infinity',
        'INFINITY': '+Infinity',
        '-INFINITY': '-Infinity'
      };
      return specailNum[_value];
    };
    this.formatDouble = function(value) {
      var specailNum;
      specailNum = this.getSpecailNum(value);
      if (specailNum) {
        return specailNum;
      }
      if (value < 0) {
        return '-' + Ext.util.Format.number(Math.abs(value), '0,000.00');
      } else {
        return Ext.util.Format.number(value, '0,000.00');
      }
    };
    return this;
  }
});
