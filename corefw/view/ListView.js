// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.ListView', {
  extend: 'Ext.grid.Panel',
  alias: 'widget.listview',
  displayField: "displayField",
  valueField: "valueField",
  sortableColumns: false,
  scrollToMore: true,
  scrollToMoreName: "viewMoreBtn",
  firstSeeItems: 5,
  dataPrefix: false,
  dataSuffix: false,
  border: false,
  viewListeners: {
    afterrender: function() {
      this.panel.createTooltip();
    },
    itemdblclick: function(view, record, item, index, e) {
      this.panel.fireEvent("itemdblclick", this.panel, record, item, index);
    },
    itemclick: function(view, record, item, index, e) {
      var ele, id, ids, _i, _len, _ref;
      ids = [].concat(record.prefixId).concat(record.suffixId);
      for (_i = 0, _len = ids.length; _i < _len; _i++) {
        id = ids[_i];
        ele = Ext.get(id);
        if (e.target === ele.dom) {
          if ((_ref = record.handler[id]) != null) {
            _ref.onclick();
          }
        }
      }
      this.panel.fireEvent("itemclick", this.panel, record, item, index);
    },
    refresh: function() {
      this.panel.handleSeeMoreBtn();
      this.panel.fireEvent("refresh", this.panel);
    }
  },
  dataDecorators: {
    checkbox: {
      getHtml: function(id) {
        return "<input type='checkbox' style='margin:0px;' id=" + id + ">";
      },
      onselectionchange: function(element, selected, listview, record) {
        var fn;
        if (selected) {
          fn = function() {
            element.dom.checked = true;
          };
        } else {
          fn = function() {
            element.dom.checked = false;
          };
        }
        setTimeout(fn, 100);
      },
      onclick: function() {}
    },
    radio: {
      getHtml: function(id, name) {
        return "<input type='radio' style='margin:0px;' name=" + name + " id=" + id + ">";
      },
      onselectionchange: function(element, selected, listview, record) {
        var fn;
        if (selected) {
          fn = function() {
            element.dom.checked = true;
          };
        } else {
          fn = function() {
            element.dom.checked = false;
          };
        }
        setTimeout(fn, 100);
      },
      onclick: function() {}
    },
    icon: {
      getHtml: function(id) {},
      onselectionchange: function(element, selected, listview, record) {},
      onclick: function() {}
    }
  },
  getNode: function(record) {
    this.view.getNode(record);
  },
  onItemSelect: function(node) {
    this.view.onItemSelect(node);
  },
  focusNode: function(node) {
    this.view.focusNode(node);
  },
  getTooltip: function(record) {
    return record.get(this.displayField);
  },
  generateDataDecorator: function(cfg) {
    var decorator, html, id;
    if (!cfg) {
      return {
        html: ""
      };
    }
    id = Ext.id();
    if (Ext.isString(cfg)) {
      decorator = this.dataDecorators[cfg];
      if (decorator) {
        id = cfg + "-" + id;
        html = decorator.getHtml(id, "displayField");
        return {
          html: html,
          id: id,
          onselectionchange: decorator.onselectionchange,
          onclick: decorator.onclick
        };
      }
    }
    return {
      html: ""
    };
  },
  generateDataPrefix: function(record) {
    var cfg, cfgs, handler, html, prefix, _i, _len;
    if (Ext.isArray(this.dataPrefix)) {
      cfgs = this.dataPrefix;
    } else {
      cfgs = [this.dataPrefix];
    }
    record.prefixId = [];
    handler = {};
    html = [];
    for (_i = 0, _len = cfgs.length; _i < _len; _i++) {
      cfg = cfgs[_i];
      prefix = this.generateDataDecorator(cfg);
      if (prefix.id) {
        record.prefixId.push(prefix.id);
        handler[prefix.id] = {
          onselectionchange: prefix.onselectionchange,
          onclick: prefix.onclick
        };
        html.push(prefix.html);
      }
    }
    record.handler = Ext.apply(record.handler || {}, handler);
    return html.join("");
  },
  generateDataSuffix: function(record) {
    var cfg, cfgs, handler, html, suffix, _i, _len;
    if (Ext.isArray(this.dataSuffix)) {
      cfgs = this.dataSuffix;
    } else {
      cfgs = [this.dataSuffix];
    }
    record.suffixId = [];
    handler = {};
    html = [];
    for (_i = 0, _len = cfgs.length; _i < _len; _i++) {
      cfg = cfgs[_i];
      suffix = this.generateDataDecorator(cfg);
      if (suffix.id) {
        record.suffixId.push(suffix.id);
        handler[suffix.id] = {
          onselectionchange: suffix.onselectionchange,
          onclick: suffix.onclick
        };
        html.push(suffix.html);
      }
    }
    record.handler = Ext.apply(record.handler || {}, handler);
    return html.join("");
  },
  columnRenderer: function(value, metaData, record, rowIndex, colIndex, store, view) {
    var data, prefix, suffix;
    prefix = "<div style='display:inline-block;height:100%;'>" + this.generateDataPrefix(record) + "</div>";
    data = "<div style='display:inline-block;height:100%;padding-left:5px;'>" + this.dataRenderer(value, metaData, record, rowIndex, colIndex, store, view) + "</div>";
    suffix = "<div style='display:inline-block;height:100%;float:right;'>" + this.generateDataSuffix(record) + "</div>";
    return prefix + data + suffix;
  },
  dataRenderer: function(value, metaData, record, rowIndex, colIndex, store, view) {
    return value;
  },
  seeMore: function() {
    this.store.loadRecords(this.allDataStore.data.items);
  },
  initComponent: function() {
    var gridView, me;
    me = this;
    if (!this.store) {
      this.store = Ext.create('Ext.data.Store', {
        fields: [this.displayField, this.valueField],
        data: this.getStoreData(this.listData) || []
      });
    }
    if (this.scrollToMore) {
      this.fbar = this.createViewMoreBar();
      if (this.addListeners) {
        me.on(this.addListeners);
      }
    }
    this.columns = {
      style: "display:none",
      items: [
        {
          dataIndex: this.displayField,
          renderer: this.columnRenderer,
          flex: 1
        }
      ]
    };
    this.callParent(arguments);
    gridView = this.getView();
    gridView.on(this.viewListeners);
    gridView.getSelectionModel().on("selectionchange", function(selectionModel, selected) {
      var allRecords, rec, _i, _len;
      allRecords = selectionModel.store.data.items;
      for (_i = 0, _len = allRecords.length; _i < _len; _i++) {
        rec = allRecords[_i];
        if (Ext.Array.contains(selected, rec)) {
          me.callDecoratorHandler(rec, true, "selectionchange");
        } else {
          me.callDecoratorHandler(rec, false, "selectionchange");
        }
      }
    });
    delete this.listData;
  },
  handleSeeMoreBtn: function() {
    var btn, _ref;
    btn = this.down('[name=' + this.scrollToMoreName + ']');
    if (((_ref = this.allDataStore) != null ? _ref.getCount() : void 0) > this.firstSeeItems) {
      btn.up("toolbar").show();
    } else {
      btn.up("toolbar").hide();
    }
  },
  createViewMoreBar: function() {
    var me, ret;
    me = this;
    this.on("show", function() {
      me.handleSeeMoreBtn();
    });
    ret = [
      {
        type: 'button',
        text: 'click to see more',
        name: this.scrollToMoreName,
        handler: function() {
          me.seeMore();
          this.up("toolbar").hide();
        }
      }
    ];
    return ret;
  },
  createTooltip: function() {
    var gridView, me;
    gridView = this.getView();
    me = this;
    Ext.create('Ext.tip.ToolTip', {
      target: gridView.el,
      delegate: gridView.itemSelector,
      trackMouse: true,
      renderTo: Ext.getBody(),
      listeners: {
        beforeshow: function(tip) {
          tip.update(me.getTooltip(gridView.getRecord(tip.triggerElement)));
        }
      }
    });
  },
  callDecoratorHandler: function(record, selected, type) {
    var ele, id, ids, _i, _len;
    ids = [].concat(record.prefixId).concat(record.suffixId);
    for (_i = 0, _len = ids.length; _i < _len; _i++) {
      id = ids[_i];
      ele = Ext.get(id);
      if (ele) {
        record.handler[id]["on" + type](ele, selected, this, record);
      }
    }
  },
  getStoreData: function(records, displayField, valueField) {
    var data, red, tmp, _i, _j, _len, _len1;
    if (!records) {
      return null;
    }
    if (!displayField) {
      displayField = this.displayField;
    }
    if (!valueField) {
      valueField = displayField;
    }
    if (!(records instanceof Array)) {
      records = [records];
    }
    data = [];
    if (records[0] instanceof Ext.data.Model) {
      for (_i = 0, _len = records.length; _i < _len; _i++) {
        red = records[_i];
        tmp = {};
        tmp[displayField] = red.get(displayField);
        tmp[valueField] = red.get(valueField);
        data.push(tmp);
      }
    } else {
      for (_j = 0, _len1 = records.length; _j < _len1; _j++) {
        red = records[_j];
        tmp = {};
        tmp[displayField] = red[dataField];
        tmp[valueField] = red[valueField];
        data.push(tmp);
      }
    }
    return data;
  },
  bindStore: function(store) {
    var index, item, newStore, recs, _i, _len, _ref;
    if (this.scrollToMore) {
      this.allDataStore = store;
      recs = [];
      _ref = this.allDataStore.data.items;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        item = _ref[index];
        if (index === this.firstSeeItems) {
          break;
        }
        recs.push(item);
      }
      newStore = Ext.create('Ext.data.Store', {
        model: store.model
      });
      newStore.loadRecords(recs);
      this.callParent([newStore]);
    } else {
      this.callParent(arguments);
    }
  },
  createPagingToolbar: function() {}
});