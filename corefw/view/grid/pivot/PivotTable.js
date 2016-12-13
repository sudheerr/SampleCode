// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.pivot.PivotTable', {
  extend: 'Ext.grid.Panel',
  alias: 'widget.pivottable',
  requires: ['Corefw.view.grid.pivot.AxisColumn', 'Corefw.view.grid.pivot.ValueColumn', 'Corefw.view.grid.pivot.GroupColumn', 'Corefw.view.grid.pivot.PivotTableToolBar', 'Ext.grid.plugin.BufferedRenderer'],
  plugins: [
    {
      ptype: 'bufferedrenderer',
      trailingBufferZone: 100,
      leadingBufferZone: 100
    }, {
      ptype: 'pivotcelltooltip'
    }
  ],
  mixins: ['Corefw.mixin.UiPathAware'],
  dockedItems: [
    {
      xtype: 'pivottablecfgpanel',
      itemId: 'cfgPanel',
      overflowY: 'auto'
    }, {
      xtype: 'pivottabletoolbar'
    }
  ],
  cls: 'pivotTable',
  columns: [],
  columnLines: true,
  grandTotalRowCls: 'grand-total-row',
  subTotalRowCls: 'sub-total-row',
  headingRowCls: 'heading-row',
  keyDelimeter: '~',
  holderRowLabels: [
    {
      name: '',
      path: 'Grand Total'
    }
  ],
  currentPivotConfig: null,
  valueDevidedBy: 1,
  viewConfig: {
    getRowClass: function(record, index, rowParams, store) {
      if (record.raw._subTotalFor) {
        return this.up('grid').subTotalRowCls;
      }
      if (record.raw._grandTotal) {
        return this.up('grid').grandTotalRowCls;
      }
    }
  },
  listeners: {
    afterrender: function() {
      var cfgPanel;
      this.binduipath();
      cfgPanel = this.down("#cfgPanel");
      return cfgPanel.init(this.uipath);
    },
    reconfigure: function() {
      return this.view.setLoading(false);
    }
  },
  reload: function(configData, globalFilter) {
    this.view.setLoading(true);
    return Ext.Ajax.request({
      url: 'api/pivot/pivotData',
      method: 'POST',
      scope: this,
      jsonData: {
        uipath: this.uipath,
        pivotConfig: configData,
        globalFilter: globalFilter
      },
      success: function(response) {
        var responseJson;
        responseJson = Ext.decode(response.responseText);
        this.currentPivotConfig = configData;
        return this.reloadTable(responseJson);
      }
    });
  },
  reloadTable: function(props) {
    var columns, data, fields, store;
    this.down('[name=rows]').update(props.totalRows);
    columns = this.generateColumns(this.currentPivotConfig, props);
    fields = this.generateFields(columns);
    data = this.generateData(this.currentPivotConfig, props);
    store = Ext.create('Ext.data.Store', {
      fields: fields,
      data: data
    });
    return this.reconfigure(store, columns);
  },
  generateColumns: function(pivotConfig, props) {
    var columnLabelsColumns, columnLabelsResults, me, rootColumn, rowLabelsColumns;
    me = this;
    rowLabelsColumns = (pivotConfig.rowLabels || me.holderRowLabels).map(function(rowLabel, index, rowLabels) {
      return {
        xtype: 'pivotaxiscolumn',
        text: rowLabel.name,
        dataIndex: rowLabel.path,
        cls: index === rowLabels.length - 1 ? 'lastaxis' : void 0,
        mergeCell: index === rowLabels.length - 1 ? false : true
      };
    });
    columnLabelsColumns = [];
    columnLabelsResults = props.pivotColumnHeaders.map(function(colHeader) {
      return colHeader.value.pivotDimensionValues;
    });
    rootColumn = {
      text: '',
      key: '',
      columns: []
    };
    Ext.Array.each(columnLabelsResults, function(result) {
      var parent;
      parent = rootColumn;
      return Ext.Array.each(pivotConfig.columnLabels, function(columnLabel, index) {
        var column;
        column = me.findColumnByText(parent, result[index]);
        return parent = column;
      });
    });
    (function(parent) {
      var selfFn;
      selfFn = arguments.callee;
      if (parent.columns && parent.columns.length) {
        return Ext.Array.each(parent.columns, function(column) {
          return selfFn(column);
        });
      } else {
        return Ext.Array.each(pivotConfig.values, function(value) {
          var column;
          column = me.findColumnByText(parent, value.fullText, "" + value.valueItemId + me.keyDelimeter + value.aggregation);
          return Ext.apply(column, {
            dataIndex: column.key,
            xtype: 'pivotvaluecolumn',
            aggregation: value.aggregation,
            renderer: function(value) {
              if (!Ext.isNumber(value)) {
                return value;
              }
              return Ext.util.Format.number(value / this.valueDevidedBy, '0,000.00');
            }
          });
        });
      }
    })(rootColumn);
    return rowLabelsColumns.concat(rootColumn.columns);
  },
  findColumnByText: function(parent, text, key) {
    var column;
    parent.columns = parent.columns || [];
    column = Ext.Array.findBy(parent.columns, function(item) {
      return item.text === text;
    });
    if (!column) {
      key = key || text;
      key = parent.key ? "" + parent.key + this.keyDelimeter + key : key;
      column = {
        xtype: 'pivotgroupcolumn',
        text: text,
        key: key
      };
      parent.columns.push(column);
    }
    return column;
  },
  generateFields: function(columns) {
    var column, fields, _fn, _i, _len;
    fields = [];
    _fn = function(parent) {
      var selfFn;
      selfFn = arguments.callee;
      if (parent.dataIndex) {
        return fields.push({
          name: parent.dataIndex,
          useNull: true,
          mapping: function(data) {
            return data[parent.dataIndex];
          }
        });
      } else {
        return Ext.Array.map(parent.columns, selfFn);
      }
    };
    for (_i = 0, _len = columns.length; _i < _len; _i++) {
      column = columns[_i];
      _fn(column);
    }
    return fields;
  },
  generateData: function(pivotConfig, props) {
    var data, me, rowKeyIndices;
    me = this;
    data = [];
    rowKeyIndices = {};
    Ext.Array.map(props.pivotRowHeaders, function(pivotRowHeader) {
      var rowData, rowDataKey, rowLabelValues;
      rowData = {};
      rowDataKey = [];
      rowLabelValues = pivotRowHeader.value.pivotDimensionValues;
      if (pivotRowHeader.hasSubTotal) {
        rowData._subTotalFor = rowLabelValues[rowLabelValues.length - 1];
      }
      if (rowLabelValues[0] === 'Grand Total') {
        rowData._grandTotal = true;
      }
      Ext.Array.each(pivotConfig.rowLabels || me.holderRowLabels, function(rowLabel, index) {
        rowData[rowLabel.path] = rowLabelValues[index];
        if (rowLabelValues[index]) {
          return rowDataKey.push(rowLabelValues[index]);
        }
      });
      rowKeyIndices[rowDataKey.join(me.keyDelimeter)] = data.length;
      return data.push(rowData);
    });
    Ext.Array.each(props.pivotCells, function(pivotCell) {
      var rowData, rowDataKey;
      rowDataKey = pivotCell.rowKey.pivotDimensionValues.join(me.keyDelimeter);
      rowData = data[rowKeyIndices[rowDataKey]];
      if (!rowData) {
        return;
      }
      return Ext.Array.each(pivotCell.values.valueMap, function(oneValue) {
        var timeMarkKey, vPath, valuePath, varianceObj, varianceType, varianceValue, _ref;
        valuePath = [oneValue.path, oneValue.aggregationName];
        if (pivotCell.columnKey) {
          valuePath = pivotCell.columnKey.pivotDimensionValues.concat(valuePath);
        }
        rowData[valuePath.join(me.keyDelimeter)] = oneValue.value;
        _ref = oneValue.variances;
        for (timeMarkKey in _ref) {
          varianceObj = _ref[timeMarkKey];
          for (varianceType in varianceObj) {
            varianceValue = varianceObj[varianceType];
            vPath = valuePath.slice(0, -1).concat([varianceType, timeMarkKey]).concat(valuePath.slice(-1));
            rowData[vPath.join(me.keyDelimeter)] = varianceValue;
          }
        }
      });
    });
    return data;
  },
  updateDivisor: function(newValue) {
    this.valueDevidedBy = newValue;
    return this.getView().refresh();
  },
  toggleConfigPanel: function(toOpen) {
    var cfgPanel;
    cfgPanel = this.down("#cfgPanel");
    if (toOpen === false || (toOpen === void 0 && cfgPanel.isVisible())) {
      cfgPanel.hide();
    } else {
      cfgPanel.show();
    }
    return cfgPanel.isVisible();
  }
});