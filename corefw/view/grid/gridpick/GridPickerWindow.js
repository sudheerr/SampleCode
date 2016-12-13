// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.gridpick.GridPickerWindow', {
  extend: 'Ext.window.Window',
  xtype: 'coregridpickerwindow',
  header: false,
  autoShow: false,
  resizable: false,
  draggable: false,
  focusOnToFront: false,
  layout: 'fit',
  overflowX: 'auto',
  overflowY: 'auto',
  minHeight: 21 * 1 + 21,
  maxHeight: 21 * 10 + 21,
  initComponent: function() {
    var addListeners, pickerwindow;
    this.validValues = [];
    this.callParent(arguments);
    addListeners = {
      show: function(me) {
        var borderWidth, combo, gridWrapperWidth, innerGridWidth, mask, outerFieldWidth, val;
        combo = me.parentField;
        val = combo.getPostValue ? combo.getPostValue() : combo.getValue();
        me.setSelectedValue(val);
        borderWidth = 4;
        if (me.grid) {
          me.grid.setEachColumnSize();
          innerGridWidth = me.grid.getWidthNeeded() + borderWidth;
          outerFieldWidth = combo.getWidth();
          gridWrapperWidth = innerGridWidth > outerFieldWidth ? innerGridWidth : outerFieldWidth;
          me.setWidth(gridWrapperWidth);
          me.grid.updatePaginationHeight();
        }
        this.initLazyLoadingOnScroll();
        this.ajustPosition();
        mask = Ext.DomQuery.select('.x-mask[id!=global]')[0];
        mask && (mask.style.display = 'none');
      }
    };
    this.on(addListeners);
    pickerwindow = this;
    this.grid = this.add({
      xtype: 'grid',
      autoRender: true,
      sortableColumns: false,
      columns: [],
      updatePaginationHeight: function() {
        var grid, pageSize, props, recordCount, _ref, _ref1;
        grid = this;
        props = (_ref = pickerwindow.parentField) != null ? (_ref1 = _ref.cache) != null ? _ref1._myProperties : void 0 : void 0;
        pageSize = props.pageSize;
        if (!pageSize) {
          return;
        }
        recordCount = grid.store.totalCount;
        if (recordCount < pageSize) {
          delete grid.height;
          grid.updateLayout();
        } else if (!grid.height && recordCount === pageSize) {
          grid.setHeight(grid.getHeight() - 5);
        }
      },
      updatePickerValue: function() {
        var grid, indexOfSelected, picker, recordIndex, sel, selModel, selected, store, _i, _len;
        grid = this;
        indexOfSelected = [];
        picker = pickerwindow.parentField;
        picker.selChanging = true;
        picker.valueChanged = true;
        selModel = grid.getSelectionModel();
        selected = selModel.getSelection();
        store = selModel.store;
        for (_i = 0, _len = selected.length; _i < _len; _i++) {
          sel = selected[_i];
          recordIndex = store.indexOf(sel);
          if (recordIndex > -1) {
            indexOfSelected.push(recordIndex);
          }
        }
        if (pickerwindow.multiSelect) {
          indexOfSelected.sort();
          picker.setPickValue(pickerwindow.getValueByIndex(indexOfSelected));
        } else {
          picker.setPickValue(pickerwindow.getValueByIndex(indexOfSelected[0]));
          picker.hideGridWindow();
        }
        return picker.fireEvent('select', picker);
      },
      listeners: {
        afterrender: function() {
          this.setEachColumnSize();
        }
      },
      getWidthNeeded: function() {
        var borderWidth, col, cols, sum, _i, _len;
        sum = 0;
        cols = this.headerCt.columnManager.getColumns();
        borderWidth = 1;
        for (_i = 0, _len = cols.length; _i < _len; _i++) {
          col = cols[_i];
          sum += col.getWidthNeeded() + borderWidth;
        }
        return sum;
      },
      setEachColumnSize: function() {
        var delaySet, me;
        me = this;
        delaySet = Ext.Function.createDelayed(function() {
          var col, cols, _i, _len;
          cols = me.headerCt.columnManager.getColumns();
          for (_i = 0, _len = cols.length; _i < _len; _i++) {
            col = cols[_i];
            if (col.setColumnMinWidth) {
              col.setColumnMinWidth();
            }
          }
        }, 1);
        delaySet();
      },
      selModel: {
        mode: pickerwindow.multiSelect ? "SIMPLE" : "SINGLE"
      }
    });
    if (pickerwindow.multiSelect) {
      addListeners = {
        selectionchange: function() {
          this.updatePickerValue();
        }
      };
    } else {
      addListeners = {
        itemclick: function() {
          this.updatePickerValue();
        }
      };
    }
    this.grid.on(addListeners);
  },
  initLazyLoadingOnScroll: function() {
    var appendOnScrollData, grid, gridViewEl, lazyLoadingOnScrollEvent, me, onScrollEvent, orignOnScrollEventURL, pageSize, parentField, props, rq, _ref, _ref1, _ref2;
    if (this.lazyLoadingOnScrollEventConfigued) {
      return;
    }
    rq = Corefw.util.Request;
    parentField = this.parentField;
    props = parentField != null ? (_ref = parentField.cache) != null ? _ref._myProperties : void 0 : void 0;
    onScrollEvent = (_ref1 = parentField.eventURLs) != null ? _ref1["ONSCROLL"] : void 0;
    if (!onScrollEvent) {
      return;
    }
    me = this;
    pageSize = props.pageSize;
    grid = this.grid;
    grid.pageIndex = 1;
    if (!pageSize) {
      return;
    }
    orignOnScrollEventURL = rq.objsToUrl3(onScrollEvent);
    grid.setOverflowXY("hidden", "auto");
    gridViewEl = (_ref2 = grid.down("gridview")) != null ? _ref2.el : void 0;
    appendOnScrollData = function(resObj) {
      var newItems, records, validValues, _ref3;
      grid.pageIndex++;
      newItems = (resObj != null ? (_ref3 = resObj.gridPicker) != null ? _ref3.items : void 0 : void 0) || [];
      records = newItems && Ext.Array.map(newItems, function(newItem) {
        return newItem.value;
      });
      validValues = (resObj != null ? resObj.validValues : void 0) || [];
      me.validValues = (me.validValues || []).concat(validValues);
      if (records.length < pageSize) {
        grid.enableScrollEvent = false;
      }
      if (records) {
        grid.getStore().add(records);
      }
    };
    lazyLoadingOnScrollEvent = function() {
      var fieldVal, onScrollEventURL, pageIndex;
      pageIndex = grid.pageIndex;
      pageIndex++;
      fieldVal = parentField.getRawValue();
      onScrollEventURL = "" + orignOnScrollEventURL + "&pageIndex=" + pageIndex;
      if (fieldVal) {
        onScrollEventURL += "&lookupString=" + fieldVal;
      }
      rq.sendRequest5(onScrollEventURL, appendOnScrollData, '', '', '', '', '', '', {
        loadMaskTarget: grid
      });
    };
    gridViewEl.on("scroll", function(event, element) {
      var scrollHeight, scrollTop, viewContentHeight;
      scrollTop = element.scrollTop;
      scrollHeight = element.scrollHeight;
      viewContentHeight = this.getHeight(true);
      if (!grid.enableScrollEvent) {
        return;
      }
      if (scrollTop + viewContentHeight === scrollHeight) {
        lazyLoadingOnScrollEvent();
      }
    });
    this.lazyLoadingOnScrollEventConfigued = true;
  },
  ajustPosition: function() {
    var bottomY, combo, maxRightX, x, y;
    if (!this.el || this.isHidden()) {
      return;
    }
    combo = this.parentField;
    bottomY = combo.getY() + this.getHeight() + combo.getHeight();
    maxRightX = this.getWidth() + combo.getX();
    if (maxRightX > Ext.getBody().getWidth()) {
      x = combo.getX() - (this.getWidth() - combo.getWidth());
    } else {
      x = combo.getX();
    }
    if (bottomY > Ext.getBody().getHeight()) {
      y = combo.inputEl.getY() - this.getHeight();
    } else {
      y = combo.getY() + combo.getHeight();
    }
    this.showAt(x, y);
  },
  getValueByIndex: function(index) {
    var ind, result, _i, _len;
    if (Ext.isArray(index)) {
      result = [];
      for (_i = 0, _len = index.length; _i < _len; _i++) {
        ind = index[_i];
        result.push(this.validValues[ind]);
      }
      return result;
    } else {
      return this.validValues[index];
    }
  },
  showData: function(data) {
    var columnValues, columns, field, fields, grid, gridPickerProperties, newStrore, obj, p, pageSize, view, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4;
    this.validValues = data.validValues;
    grid = this.grid;
    gridPickerProperties = data.gridPicker;
    if (!gridPickerProperties) {
      return;
    }
    if (!this.grid) {
      this.grid = this.down('grid');
    }
    fields = [];
    columnValues = [];
    _ref = gridPickerProperties.items || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      p = _ref[_i];
      for (field in p.value) {
        if (!Ext.Array.contains(fields, field)) {
          fields.push(field);
        }
      }
      columnValues.push(p.value);
    }
    grid.pageIndex = 1;
    pageSize = (_ref1 = this.parentField) != null ? (_ref2 = _ref1.cache) != null ? (_ref3 = _ref2._myProperties) != null ? _ref3.pageSize : void 0 : void 0 : void 0;
    if (pageSize) {
      if (columnValues.length < pageSize) {
        grid.enableScrollEvent = false;
      } else {
        grid.enableScrollEvent = true;
      }
    }
    columns = [];
    view = grid.view;
    _ref4 = gridPickerProperties.allContents || [];
    for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
      field = _ref4[_j];
      obj = {
        text: field.title,
        tooltip: field.title,
        dataIndex: field.index + '',
        menuDisabled: true,
        widthSetted: field.width,
        setColumnMinWidth: function() {
          var minWidth;
          if (!this.el) {
            return;
          }
          minWidth = this.getWidthNeeded();
          this.setWidth(minWidth);
        },
        getWidthNeeded: function() {
          var cell, headerWidthNeed, maxWidth, paddingValue, position, width;
          if (this.widthSetted) {
            return this.widthSetted;
          }
          maxWidth = Number.NEGATIVE_INFINITY;
          paddingValue = 12;
          position = {
            column: this.getIndex(),
            row: 0
          };
          cell = view.getCellByPosition(position);
          while (cell) {
            width = Ext.util.TextMetrics.measure(cell, cell.dom.innerText).width + paddingValue;
            if (width > maxWidth) {
              maxWidth = width;
            }
            position.row++;
            cell = view.getCellByPosition(position);
          }
          headerWidthNeed = Ext.util.TextMetrics.measure(this.titleEl, this.titleEl.dom.innerText).width;
          if (this.text && this.text !== '') {
            headerWidthNeed = headerWidthNeed + this.titleEl.getPadding("lr") + this.el.getBorderWidth("lr");
          }
          maxWidth = Math.max(maxWidth, headerWidthNeed);
          return maxWidth;
        }
      };
      if (field.width) {
        obj.width = field.width;
      }
      switch (field.type) {
        case 'CHECKBOX':
          obj.xtype = 'checkcolumn';
          break;
        case 'ICON':
          obj.iconMap = field.iconMap;
          obj.renderer = function(value, metaData, record, rowIndex, colIndex, store) {
            var column, recordIndex;
            if (value == null) {
              value = '';
            }
            column = metaData.column;
            recordIndex = metaData.recordIndex;
            if (column && column.iconMap) {
              metaData.tdCls = column.iconMap[recordIndex];
            }
            if (typeof value === 'string') {
              return value.split('<br>').join(' ');
            } else {
              return value;
            }
          };
          break;
        case 'DATESTRING':
          obj.xtype = 'datecolumn';
          obj.format = field.format || 'Y-m-d H:i:s';
          obj.renderer = function(value, metaData) {
            var column, dateFormat, valueFormat;
            column = metaData.column;
            dateFormat = "Y-m-d H:i:s";
            valueFormat = 'Y-m-d H:i:s';
            if (column && column.format) {
              valueFormat = column.format;
            }
            if (!Ext.isDate(value)) {
              try {
                value = Ext.Date.parse(value, dateFormat);
              } catch (_error) {
                return value;
              }
            }
            return Ext.util.Format.date(value, valueFormat);
          };
          break;
        case 'DATE':
          obj.xtype = 'datecolumn';
          obj.format = field.format || 'd M Y';
      }
      columns.push(obj);
    }
    if (columns.length) {
      columns[columns.length - 1].flex = 1;
      columns[columns.length - 1].resizable = false;
    }
    grid.suspendEvents();
    grid.getStore().destroy();
    newStrore = Ext.create('Ext.data.Store', {
      fields: fields,
      data: columnValues
    });
    grid.reconfigure(newStrore, columns);
    grid.resumeEvents();
    if (this.isVisible() && pageSize) {
      grid.updatePaginationHeight();
    }
    this.ajustPosition();
  },
  hasHScrollbar: function(grid) {
    var gridViewEl, viewSize, viewSizeWithoutScollbar;
    gridViewEl = grid.view.el;
    viewSize = gridViewEl.getSize(true);
    viewSizeWithoutScollbar = gridViewEl.getViewSize();
    if (viewSize.height > viewSizeWithoutScollbar.height) {
      return true;
    } else if (viewSize.height === viewSizeWithoutScollbar.height) {
      return false;
    }
    return false;
  },
  setSelectedValue: function(value) {
    var cm, grid, me, selModel, selected, val;
    grid = this.grid;
    me = this;
    if (!grid) {
      return [];
    }
    selModel = grid.getSelectionModel();
    if (!selModel.views.length) {
      return [];
    }
    cm = Corefw.util.Common;
    if (!Ext.isArray(value)) {
      val = [value];
    } else {
      val = value;
    }
    selected = [];
    grid.getStore().each(function(record) {
      var recordVal;
      recordVal = me.getValueByIndex(record.index);
      if (Ext.Array.contains(cm.getValue(val), cm.getValue(recordVal))) {
        selected.push(record);
      }
    });
    selModel.suspendEvents();
    selModel.select(selected);
    selModel.resumeEvents();
    return selected;
  },
  afterRender: function() {
    var ownerGrid, ownerView, _ref, _ref1, _ref2, _ref3, _ref4;
    this.callParent(arguments);
    document.addEventListener("click", this);
    document.addEventListener("mousewheel", this);
    if ((_ref = this.parentField) != null) {
      if ((_ref1 = _ref.ownerCt.el) != null) {
        _ref1.dom.addEventListener("click", this);
      }
    }
    ownerGrid = (_ref2 = this.parentField) != null ? _ref2.up("grid") : void 0;
    ownerView = ownerGrid != null ? ownerGrid.view : void 0;
    if (!ownerView) {
      return;
    }
    if (ownerView.isLockingView) {
      ownerView = ownerView.normalView;
    }
    if ((_ref3 = ownerView.el) != null) {
      if ((_ref4 = _ref3.dom) != null) {
        _ref4.addEventListener("scroll", this);
      }
    }
  },
  handleEvent: function(ev) {
    var loadMask, target;
    if (!this.el) {
      return;
    }
    target = ev.target;
    if (this.el.dom.contains(target) || (this.parentField.el && this.parentField.el.dom.contains(target))) {
      return;
    }
    loadMask = this.grid.loadMask;
    if (!loadMask || loadMask.isHidden()) {
      this.parentField.hideGridWindow();
    }
  },
  onDestroy: function() {
    this.callParent(arguments);
    document.removeEventListener("click", this);
    document.removeEventListener("mousewheel", this);
  }
});
