// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.tree.TreeMixedGridField', {
  extend: 'Corefw.view.tree.TreeFieldBase',
  xtype: 'coretreemixedgrid',
  initComponent: function() {
    this.initalizeTreeMixedGrid();
    this.callParent(arguments);
    this.addCls('backgroundcolorset');
  },
  initalizeTreeMixedGrid: function() {
    var cache, cm, grid, gridList, props, _i, _len, _ref;
    cm = Corefw.util.Common;
    cache = this.cache;
    props = cache._myProperties;
    this.treeList = {};
    cm.objRenameProperty(props, 'items', 'grid');
    if (props.grid) {
      gridList = {};
      props.gridList = gridList;
      _ref = props.grid;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        grid = _ref[_i];
        gridList[grid.name] = grid;
      }
    }
  },
  onTreeItemExpand: function(record, index, treenodeDom) {
    if (record.ignoreExpandEvent) {
      delete record.ignoreExpandEvent;
      return;
    }
    record.ignoreExpandEvent = true;
    this.onClickTreeMixedGrid(record, treenodeDom, index);
  },
  configureTree: function() {
    this.firstColumnName = 'text';
    this.displayField = this.firstColumnName;
  },
  onClickTreeMixedGrid: function(record, treenodeDom, index, ev) {
    var targetid, _ref;
    if (record.data.root) {
      return;
    }
    targetid = ev != null ? (_ref = ev.target) != null ? _ref.id : void 0 : void 0;
    if (!Ext.String.startsWith(treenodeDom.id, 'treeview')) {
      this.tree.getSelectionModel().deselectAll();
      ev.stopEvent();
      return;
    }
    if (targetid && !Ext.String.startsWith(targetid, 'treeview')) {
      this.tree.getSelectionModel().deselectAll();
      ev.stopEvent();
      return;
    }
    if (!treenodeDom.expanded) {
      this.createTreeNode(record, treenodeDom);
    } else {
      this.deleteTreeNode(record, treenodeDom);
    }
    if (ev) {
      ev.stopEvent();
    }
    this.tree.getSelectionModel().deselectAll();
  },
  createTreeNode: function(record, treenodeDom) {
    var gridConfig, gridDataItems, panel, panelHeight, treepanel, _ref;
    gridDataItems = record != null ? (_ref = record.raw) != null ? _ref.grid : void 0 : void 0;
    if (!gridDataItems) {
      return;
    }
    treenodeDom.expanded = true;
    record.set('expanded', true);
    treepanel = this.tree;
    gridConfig = {
      parentContainer: this,
      treepanel: treepanel,
      mixedgrid: this,
      treenodeDom: treenodeDom,
      treeRecord: record,
      gridDataItems: gridDataItems,
      cache: this.cache
    };
    panel = Ext.create('Corefw.view.grid.Treenode', gridConfig);
    this.treeList[panel.name] = panel;
    console.log('treenode uipath: ', panel.uipath);
    treenodeDom.panel = panel;
    panelHeight = panel.getHeight();
    treepanel.setHeight(treepanel.getHeight() + panelHeight);
  },
  deleteTreeNode: function(record, treenodeDom) {
    var grid;
    record.set('expanded', false);
    record.ignoreExpandEvent = false;
    grid = treenodeDom.panel;
    if (grid != null) {
      if (typeof grid.destroy === "function") {
        grid.destroy();
      }
    }
    delete treenodeDom.panel;
    treenodeDom.newdiv.destroy();
    delete treenodeDom.newdiv;
    delete this.treeList[grid.name];
    treenodeDom.expanded = false;
  },
  replaceChild: function(respCache, ev) {
    var dataItems, i, item, name, newDataItem, parentCache, parentProps, props, record, recordRaw, treenodeComp, treenodeDom, _i, _len, _ref;
    props = respCache._myProperties;
    name = props.name;
    treenodeComp = this.treeList[name];
    if (treenodeComp) {
      record = treenodeComp.treeRecord;
      treenodeDom = treenodeComp.treenodeDom;
      recordRaw = (record != null ? record.raw : void 0) || {};
      recordRaw.grid = {
        items: props.items,
        name: name
      };
      parentCache = this.cache;
      parentProps = parentCache._myProperties;
      parentCache[name] = respCache;
      newDataItem = {
        grid: {
          items: props.items,
          name: name
        },
        value: {
          text: name
        }
      };
      dataItems = parentProps.data;
      for (i = _i = 0, _len = dataItems.length; _i < _len; i = ++_i) {
        item = dataItems[i];
        if ((item != null ? (_ref = item.grid) != null ? _ref.name : void 0 : void 0) === name) {
          dataItems[i] = newDataItem;
          break;
        }
      }
      this.deleteTreeNode(record, treenodeDom);
      this.createTreeNode(record, treenodeDom);
    }
  },
  createStore: function() {
    var cache, dataCache, dataObj, fields, gridInfo, index, infoObj, oldSt, props, st, storeChildrenArray, storeConfig, storeName, text, _i, _len, _ref;
    cache = this.cache;
    props = cache._myProperties;
    dataCache = [];
    props.data = dataCache;
    fields = [
      {
        name: 'text'
      }
    ];
    storeName = props.uipath + '-Store';
    storeChildrenArray = [];
    storeConfig = {
      extend: 'Ext.data.TreeStore',
      autoDestroy: true,
      fields: fields,
      storeId: storeName,
      root: {
        id: 'root',
        text: 'Root',
        expandable: true,
        children: storeChildrenArray
      },
      proxy: {
        type: 'memory'
      }
    };
    index = 0;
    _ref = props.allContents;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      gridInfo = _ref[_i];
      text = gridInfo.title || gridInfo.name;
      dataObj = {
        id: index++,
        text: text,
        expandable: true,
        grid: {
          name: gridInfo.name,
          items: gridInfo.items
        }
      };
      storeChildrenArray.push(dataObj);
      infoObj = {
        grid: {
          name: gridInfo.name,
          items: gridInfo.items
        },
        value: {
          text: gridInfo.name
        }
      };
      dataCache.push(infoObj);
    }
    oldSt = Ext.getStore(storeName);
    if (oldSt) {
      oldSt.destroyStore();
    }
    st = Ext.create('Ext.data.TreeStore', storeConfig);
    return st;
  },
  statics: {
    createDataCache: function(dataFieldItem, fieldCache) {}
  }
});
