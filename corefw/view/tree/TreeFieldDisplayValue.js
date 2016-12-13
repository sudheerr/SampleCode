// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.tree.TreeFieldDisplayValue', {
  extend: 'Corefw.view.tree.TreeFieldBase',
  xtype: 'coretreefielddisplayvalue',
  createStore: function() {
    var cache, dataCache, displayColumnName, fields, oldSt, props, rootObj, st, storeConfig, storeName, valueColumnName;
    cache = this.cache;
    props = cache._myProperties;
    dataCache = props.data;
    this.configureTree();
    fields = [];
    storeName = props.uipath + '-Store';
    rootObj = {
      id: 'root'
    };
    storeConfig = {
      extend: 'Ext.data.TreeStore',
      autoDestroy: true,
      fields: fields,
      storeId: storeName,
      root: rootObj,
      proxy: {
        type: 'memory'
      }
    };
    valueColumnName = this.valueColumn.index + '';
    displayColumnName = this.displayColumn.index + '';
    fields.push(valueColumnName, displayColumnName);
    this.treeStoreAddChildren(rootObj, dataCache);
    oldSt = Ext.getStore(storeName);
    if (oldSt) {
      oldSt.destroyStore();
    }
    st = Ext.create('Ext.data.TreeStore', storeConfig);
    return st;
  },
  configureTree: function() {
    var cache, fieldAr, props;
    cache = this.cache;
    props = cache._myProperties;
    fieldAr = props.columnAr;
    if (fieldAr && fieldAr.length) {
      this.valueColumn = fieldAr[0];
      this.displayColumn = fieldAr.length > 1 ? fieldAr[1] : fieldAr[0];
    } else {
      this.displayColumn = {
        pathString: 'text'
      };
    }
    this.valueColumn = this.valueColumn._myProperties;
    this.displayColumn = this.displayColumn._myProperties;
    this.treeConfig.valueField = this.valueColumn.index + '';
    this.treeConfig.displayField = this.displayColumn.index + '';
  },
  treeStoreAddChildren: function(nodeObj, childrenArray) {
    var child, childObj, children, props, _i, _len, _ref, _ref1;
    props = this.cache._myProperties;
    if (childrenArray && childrenArray.length) {
      children = [];
      nodeObj.children = children;
      for (_i = 0, _len = childrenArray.length; _i < _len; _i++) {
        child = childrenArray[_i];
        if (!child) {
          continue;
        }
        childObj = {
          id: child.index,
          disabled: child.disabled,
          matching: child.matching
        };
        Ext.apply(childObj, child.value);
        if (this.configureTreeChildren) {
          this.configureTreeChildren(childObj, child);
        }
        if (child.leaf) {
          childObj.leaf = child.leaf;
        }
        if (!props.lazyLoading) {
          if (!child.children || !child.children.length) {
            childObj.leaf = true;
            childObj.cls = 'noelbow';
          }
        }
        if ((_ref = props.selectType) === 'multiple' || _ref === 'single') {
          childObj.checked = child.isSelected;
        }
        if ((_ref1 = props.selectType) === 'MULTIPLE' || _ref1 === 'SINGLE') {
          childObj.checked = child.selected;
        }
        children.push(childObj);
        if (child.children && child.children.length) {
          this.treeStoreAddChildren(childObj, child.children);
        }
      }
    }
  }
});
