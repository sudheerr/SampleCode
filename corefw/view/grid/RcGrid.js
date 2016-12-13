// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.RcGrid', {
  extend: 'Corefw.view.grid.ObjectGrid',
  xtype: 'corercgrid',
  statics: {
    createDataCache: function(dataFieldItem, fieldCache) {
      var cell, cellPropObj, cells, cm, copyProperties, displayValue, fieldDataCache, key, miscRowObj, newObj, props, row, style, tooltipTest, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      cm = Corefw.util.Common;
      fieldDataCache = [];
      fieldCache._myProperties.data = {};
      fieldCache._myProperties.data.items = fieldDataCache;
      if (!dataFieldItem) {
        copyProperties = ['changed', 'removed', 'new', 'selected', 'cells'];
        props = fieldCache._myProperties;
        if (props.rows) {
          tooltipTest = props.tooltipValue;
          _ref = props.rows;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            row = _ref[_i];
            miscRowObj = {};
            miscRowObj._myProperties = {};
            cells = tooltipTest ? tooltipTest[_i] : void 0;
            if (cells) {
              cells = cells.cells;
            }
            cm.copyObjProperties(miscRowObj._myProperties, row, copyProperties);
            newObj = {
              __index: row.rowKey,
              __misc: miscRowObj
            };
            _ref1 = row.cells;
            for (key in _ref1) {
              cell = _ref1[key];
              newObj[key] = cell.value;
              style = cells ? cells[cell.columnKey] : void 0;
              displayValue = cell.displayValue;
              cellPropObj = {
                columnKey: cell.columnKey
              };
              if (style) {
                cellPropObj.tooltip = style.tooltip;
                cellPropObj.rowStyle = style.rowStyle;
                cellPropObj.cellStyle = style.cellStyle;
              }
              if (displayValue) {
                cellPropObj.displayValue = displayValue;
              }
              miscRowObj[key] = cellPropObj;
              cm.copyObjProperties(cellPropObj, cell, copyProperties);
            }
            fieldDataCache.push(newObj);
          }
        }
      } else {
        copyProperties = ['hasBeenChanged', 'hasBeenRemoved', 'isNew', 'isSelected'];
        if (dataFieldItem.rows) {
          _ref2 = dataFieldItem.rows;
          for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
            row = _ref2[_j];
            miscRowObj = {};
            miscRowObj._myProperties = {};
            cm.copyObjProperties(miscRowObj._myProperties, row, copyProperties);
            newObj = {
              __index: row.index,
              __misc: miscRowObj
            };
            _ref3 = row.cells;
            for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
              cell = _ref3[_k];
              newObj[cell.path] = cell.value;
              cellPropObj = {};
              miscRowObj[cell.path] = cellPropObj;
              cm.copyObjProperties(cellPropObj, cell, copyProperties);
            }
            fieldDataCache.push(newObj);
          }
        }
      }
    }
  },
  afterRender: function() {
    var gridConfig;
    this.callParent(arguments);
    gridConfig = {
      setSelection: this.setSelection,
      corefieldtype: 'rcgrid'
    };
    Ext.apply(this.grid, gridConfig);
  },
  setSelection: function() {
    var i, len, misc, record, selectArray, st, _i, _ref;
    st = this.store;
    selectArray = [];
    len = st.getCount();
    for (i = _i = 0; 0 <= len ? _i < len : _i > len; i = 0 <= len ? ++_i : --_i) {
      record = st.getAt(i);
      misc = record.get('__misc');
      if (misc != null ? (_ref = misc._myProperties) != null ? _ref.selected : void 0 : void 0) {
        selectArray.push(record);
      }
    }
    if (selectArray.length) {
      this.getSelectionModel().select(selectArray, false, true);
    }
  },
  generatePostData: function() {
    var cellObj, cellValues, cellval, cm, copyObj, copyProperties, item, items, key, postData, rowMisc, rowObj, rowsArray, topCellObj, _i, _len;
    cm = Corefw.util.Common;
    postData = this.callParent(arguments);
    copyObj = cm.objectClone(postData);
    copyProperties = ['changed', 'removed', 'index', 'new', 'selected'];
    rowsArray = [];
    postData.rows = rowsArray;
    items = postData.items;
    if (items && items.length) {
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        rowObj = {};
        cm.copyObjProperties(rowObj, item, copyProperties);
        rowsArray.push(rowObj);
        cm.objRenameProperty(rowObj, 'index', 'rowKey');
        cellValues = item.value;
        rowMisc = cellValues.__misc;
        if (cellValues) {
          topCellObj = {};
          rowObj.cells = topCellObj;
          for (key in cellValues) {
            cellval = cellValues[key];
            if (key !== '__misc' && key !== 'id') {
              cellObj = {
                value: cellval,
                columnKey: key,
                rowKey: rowObj.rowKey
              };
              if (rowMisc) {
                cm.copyObjProperties(cellObj, rowMisc[key], copyProperties);
              }
              cellObj.selected = rowObj.selected;
              topCellObj[key] = cellObj;
            }
          }
        }
      }
    }
    delete postData.items;
    return postData;
  }
});