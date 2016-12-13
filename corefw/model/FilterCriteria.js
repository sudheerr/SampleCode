// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.model.FilterCriteria', {
  extend: 'Ext.data.Model',
  alternateClassName: "CorefwFilterModel",
  requires: ['Corefw.util.Formatter'],
  fields: [
    {
      name: 'pathString',
      type: 'string'
    }, {
      name: 'operator',
      type: 'string'
    }, {
      name: 'dataTypeString',
      type: 'string'
    }, {
      name: 'operandsString',
      type: 'auto'
    }, {
      name: 'measure',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'isForHistoricalColumn',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'isForAggregatedColumn',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'aggregationMeasure',
      type: 'string',
      useNull: true
    }, {
      name: 'histColumnHeaderName',
      type: 'string',
      useNull: true
    }, {
      name: 'compareTimeoffset',
      type: 'string',
      useNull: true
    }, {
      name: 'compareMeasureName',
      type: 'string',
      useNull: true
    }, {
      name: 'disabled',
      type: 'boolean',
      defaultValue: true
    }, {
      name: 'isNegated',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'elementAggregationColumnNotExisted',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'elementComparisonColumnNotExisted',
      type: 'boolean',
      defaultValue: false
    }, {
      name: 'repetitiveRatio',
      type: 'int',
      defaultValue: -1
    }, {
      name: 'relativeCompareTimeOffset',
      type: 'string',
      defaultValue: ''
    }, {
      name: 'itemName',
      type: 'string',
      defaultValue: ''
    }, {
      name: 'compareMeasureString',
      type: 'string',
      defaultValue: ''
    }
  ],
  idProperty: 'pathString',
  copyFrom: function(record, keyMapping, keys) {
    if (keyMapping == null) {
      keyMapping = {};
    }
    if (keys == null) {
      keys = null;
    }
    return this.fields.each(function(field) {
      var key, targetKey;
      key = field.name;
      if (keys && !Ext.Array.contains(keys, key)) {
        return;
      }
      targetKey = keyMapping[key] ? keyMapping[key] : key;
      if (record.get(targetKey)) {
        return this.set(key, record.get(targetKey));
      }
    }, this);
  },
  setChildren: function(recds) {
    this.children = [].concat(recds);
  },
  getChildren: function(recds) {
    return this.children;
  },
  removeChildrenByCondition: function(fn) {
    var children, flag, i, l, left;
    left = [];
    children = this.children;
    i = 0;
    l = children.length;
    while (i < l) {
      flag = fn(children[i]);
      if (!flag) {
        left.push(children[i]);
      }
      i++;
    }
    this.children = left;
  },
  removeChildren: function(recds) {
    var children, i, l, left;
    left = [];
    children = this.children;
    i = 0;
    l = children.length;
    while (i < l) {
      if (recds.indexOf(children[i]) === -1) {
        left.push(children[i]);
      }
      i++;
    }
    this.children = left;
  },
  equals: function(record) {
    var i;
    if (this === record) {
      return true;
    }
    if (!record) {
      return false;
    }
    if (!(record instanceof Corefw.model.FilterCriteria)) {
      return false;
    }
    if (!this.get('pathString')) {
      if (record.get('pathString')) {
        return false;
      }
    } else if (this.get('pathString') !== record.get('pathString')) {
      return false;
    }
    if (!this.get('operator')) {
      if (record.get('operator')) {
        return false;
      }
    } else if (this.get('operator') !== record.get('operator')) {
      return false;
    }
    if (!this.get('operandsString')) {
      if (record.get('operandsString')) {
        return false;
      }
    } else if (!record.get('operandsString')) {
      return false;
    } else if (this.get('operandsString').length !== record.get('operandsString').length) {
      return false;
    } else {
      i = 0;
      while (i < this.get('operandsString').length) {
        if (this.get('operandsString')[i] !== record.get('operandsString')[i]) {
          return false;
        }
        i++;
      }
    }
    return true;
  },
  statics: {
    HISTORICAL_COLUMN_IDENTIFICATION_STRING: "compareWith",
    COMPARE_MEASURE_NAME_IDENTIFICATION_STRING: "by",
    OPERATOR_MAP: {
      'eq': '=',
      'ne': 'isnt',
      'lt': '<',
      'le': '<=',
      'gt': '>',
      'ge': '>=',
      'like': 'Like',
      'notLike': 'Not Like',
      'likeObjectString': 'Like',
      'between': 'Between',
      'in': 'In',
      'notIn': 'Not In',
      'existsAny': 'Exists Any',
      'existsAll': 'Exists All',
      'isNull': 'Is Null',
      'isNotNull': 'Is Not Null',
      'isNullOrEmpty': 'Is Null or Empty',
      'isNotNullOrEmpty': 'Is Not Null or Empty'
    },
    operandNumber: function(operator) {
      if (Ext.Array.contains(["isNull", "isNotNull", "isNullOrEmpty", "isNotNullOrEmpty"], operator)) {
        return 0;
      }
      return -1;
    },
    fiscalRegex: new RegExp("D:TimeMark-I:", ""),
    setAggregationOrCompareInfo: function(newOrUpdatedCriterion, triggerOwner) {
      if (triggerOwner) {
        if (triggerOwner instanceof Ext.grid.column.Column) {
          this.setAggregationOrCompareInfoByColumn(newOrUpdatedCriterion, triggerOwner);
        } else if (triggerOwner instanceof Corefw.model.FilterCriteria) {
          this.setAggregationOrCompareInfoByModelInstance(newOrUpdatedCriterion, triggerOwner.data);
        }
      }
    },
    setAggregationOrCompareInfoByColumn: function(newOrUpdatedCriterion, columnInfo) {
      var headerName;
      if (!columnInfo) {
        return;
      }
      headerName = columnInfo.T;
      if (this.isHistoricalColumn(columnInfo)) {
        newOrUpdatedCriterion.isForHistoricalColumn = true;
        newOrUpdatedCriterion.histColumnHeaderName = headerName;
        newOrUpdatedCriterion.compareTimeoffset = this.getCompareTimeoffset(columnInfo.dataIndex);
        newOrUpdatedCriterion.compareMeasureName = this.getCompareMesureName(columnInfo.dataIndex);
        newOrUpdatedCriterion.compareMeasureString = columnInfo.compareMeasureString;
      } else {
        newOrUpdatedCriterion.isForHistoricalColumn = false;
        newOrUpdatedCriterion.histColumnHeaderName = null;
        newOrUpdatedCriterion.compareTimeoffset = null;
        newOrUpdatedCriterion.compareMeasureName = null;
        newOrUpdatedCriterion.compareMeasureString = null;
      }
      if (this.isAggregatedColumn(columnInfo)) {
        newOrUpdatedCriterion.isForAggregatedColumn = true;
        newOrUpdatedCriterion.aggregationMeasure = columnInfo.aggregateMeasureString;
      } else {
        newOrUpdatedCriterion.isForAggregatedColumn = false;
        newOrUpdatedCriterion.aggregationMeasure = '';
      }
    },
    setAggregationOrCompareInfoByModelInstance: function(newOrUpdatedCriterion, data) {
      if (!newOrUpdatedCriterion || !data) {
        return;
      }
      Ext.applyIf(newOrUpdatedCriterion, data);
    },
    getCompareMesureName: function(dataIndex) {
      var compareMeasureName, self, splits;
      self = Corefw.model.FilterCriteria;
      if (!dataIndex || dataIndex.length === 0) {
        return null;
      }
      compareMeasureName = null;
      if (dataIndex.indexOf(self.HISTORICAL_COLUMN_IDENTIFICATION_STRING) > -1) {
        splits = dataIndex.split(self.COMPARE_MEASURE_NAME_IDENTIFICATION_STRING);
        if (splits[1]) {
          compareMeasureName = Ext.String.trim(splits[1]);
        }
      }
      if (!compareMeasureName) {
        return null;
      }
      return compareMeasureName;
    },
    getCompareTimeoffsetByTimeLabel: function(headerName) {
      var end, start;
      if (headerName) {
        start = headerName.indexOf('(');
        end = headerName.indexOf(')');
        return headerName.substring(start + 1, end).replace('-', '_');
      }
      return '';
    },
    getCompareTimeoffset: function(pathString) {
      var parts, regex, tmp;
      if (!pathString || pathString.length === 0) {
        return null;
      }
      regex = new RegExp('compareWith\\s([\\w~]+)*\\sby', 'i');
      tmp = regex.exec(pathString);
      parts = [];
      if (tmp) {
        return tmp[1];
      }
      return null;
    },
    isHistoricalColumn: function(columnInfo) {
      var dataIndex, self;
      self = Corefw.model.FilterCriteria;
      if (!columnInfo) {
        return false;
      }
      dataIndex = columnInfo.dataIndex;
      if (!dataIndex || dataIndex.length === 0) {
        return false;
      }
      if (dataIndex.indexOf(self.HISTORICAL_COLUMN_IDENTIFICATION_STRING) !== -1) {
        return true;
      }
      return false;
    },
    isAggregatedColumn: function(columnInfo) {
      var aggregateMeasureString;
      if (!columnInfo) {
        return false;
      }
      aggregateMeasureString = columnInfo.aggregateMeasureString;
      if (!aggregateMeasureString || aggregateMeasureString.length === 0) {
        return false;
      } else {
        return true;
      }
      return false;
    },
    isTwoCriteriaFilterFieldSame: function(criterion1, criterion2) {
      var equals, transformStrVal;
      transformStrVal = function(val) {
        if (val === 'null') {
          return null;
        } else {
          return val;
        }
      };
      equals = function(val1, val2) {
        val1 = transformStrVal(val1);
        val2 = transformStrVal(val2);
        return (!val1 && !val2) || val1 !== val2;
      };
      if (criterion1.pathString === criterion2.pathString) {
        return equals(criterion1.aggregationMeasure, criterion2.aggregationMeasure) && equals(criterion1.compareMeasureName, criterion2.compareMeasureName);
      }
      return false;
    },
    addOperands: function(operands, isTimeMark, columnDate, criObj) {
      var ops, p;
      p = new RegExp('~M');
      ops = '';
      Ext.each(operands, function(operand) {
        var dataList, dateString;
        if (columnDate) {
          dataList = operand.split('-');
          dateString = dataList[0] + '-' + dataList[1] + (dataList[2] === 0 ? '' : '-' + dataList[2]);
          operand = CorefwFormatter.formatDate(dateString, dataList[2] === 0 ? 'ForDisplayM' : 'ForDisplayD');
        } else if (criObj.dataTypeString === 'float') {
          operand = CorefwFormatter.formatDouble(operand);
        } else if (criObj.dataTypeString === 'int') {
          operand = CorefwFormatter.formatInt(operand);
        }
        if (operand === '') {
          operand = '""';
        }
        if (ops === '') {
          ops = operand;
        } else {
          ops = ops + ' ; ' + operand;
        }
      });
      return ops;
    },
    getCriteriaLabel: function(criObj, isInlineFilter) {
      var aggreMeasureName, columnDate, descMap, displayName, displayNameList, dt, innerCriObj, innerDisplayName, innerOperands, innerOperator, innerOps, innera, isTimeMark, name, operands, operator, ops, retValue, self;
      self = Corefw.model.FilterCriteria;
      displayName = criObj.itemName ? criObj.itemName : criObj.pathString.split(':').pop();
      displayNameList = displayName.split(' ');
      descMap = self.OPERATOR_MAP;
      if (displayNameList.length > 1 && displayNameList[displayNameList.length - 1].substr(displayNameList[displayNameList.length - 1].length - 1, 1) === ']') {
        return displayName;
      }
      ops = '';
      operands = criObj.operandsString;
      operator = criObj.operator;
      retValue = void 0;
      isTimeMark = false;
      columnDate = false;
      dt = false;
      innerCriObj = void 0;
      innera = [];
      innerDisplayName = void 0;
      innerOperator = void 0;
      innerOperands = [];
      innerOps = '';
      if (operator !== 'existsAny' && operator !== 'existsAll') {
        if (self.fiscalRegex.test(criObj.pathString)) {
          isTimeMark = true;
        } else if (criObj.dataTypeString === 'date') {
          columnDate = true;
        }
        if (criObj.isForHistoricalColumn) {
          displayName = criObj.histColumnHeaderName;
        }
        aggreMeasureName = criObj.aggregationMeasure;
        if (criObj.isForAggregatedColumn && aggreMeasureName) {
          name = aggreMeasureName.split('-')[0];
          if (name) {
            name = name[0].toLowerCase() + name.substr(1, name.length - 1);
            displayName = displayName + name.sub();
          }
        }
        ops = self.addOperands(operands, isTimeMark, columnDate, criObj);
      } else {
        innerCriObj = operands[0];
        innerOperands = innerCriObj.operandsString;
        innera = innerCriObj.pathString.split(':');
        innerDisplayName = innera[innera.length - 1];
        innerOperator = innerCriObj.operator;
        ops = innerDisplayName + ' ' + descMap[innerOperator];
        innerOps = self.addOperands(innerOperands, isTimeMark, columnDate, innerCriObj);
        ops = ops + ' [' + innerOps + ']';
      }
      if (isInlineFilter) {
        retValue = descMap[operator];
      } else {
        retValue = displayName + ' ' + descMap[operator];
      }
      if (self.operandNumber(criObj.operator) !== 0) {
        retValue = retValue + ' [' + ops + ']';
      }
      return [retValue, ops];
    },
    validateCriteritionOperand: function(inputValue, operator) {
      var separator;
      separator = "\u2502";
      if (inputValue !== void 0 && inputValue !== null && inputValue !== '') {
        if (inputValue.indexOf(';') > -1 || inputValue.indexOf('~') > -1) {
          Corefw.Msg.alert('Alert', "Please enter a valid value except ';~'!");
          return false;
        }
        if (inputValue.indexOf(separator) > -1) {
          Corefw.Msg.alert('Alert', "Please enter a valid value except '" + separator + ";~'!");
          return false;
        }
        if ((operator === 'like' || operator === 'notLike') && /[*]{2,}/.test(inputValue)) {
          Corefw.Msg.alert('Invalid Filter Value', "Consecutive * is unnecessary and not allowed!");
          return false;
        }
      } else {
        Corefw.Msg.alert('Alert', 'Please enter a valid value.');
        return false;
      }
      return true;
    }
  }
});
