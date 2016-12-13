// Generated by CoffeeScript 1.8.0

/*
	Base class for a tree in a form element
	The class is actually a form container which has a tree as its only child
	All properties are held at the class (ie, form container) level, not at the tree level
 */
Ext.define('Corefw.view.tree.TreeFieldBase', {
  extend: 'Ext.form.FieldContainer',
  xtype: 'coretreefieldbase',
  frame: false,
  layout: 'fit',
  flex: 1,
  margin: 0,
  padding: 0,
  statics: {
    createDataCache: function(dataFieldItem, fieldCache) {
      var cm, dataObj, _ref;
      cm = Corefw.util.Common;
      if (dataFieldItem) {
        dataObj = cm.objectClone(dataFieldItem.children);
        fieldCache._myProperties.data = dataObj;
      } else if (fieldCache != null ? (_ref = fieldCache._myProperties) != null ? _ref.allTopLevelNodes : void 0 : void 0) {
        fieldCache._myProperties.data = fieldCache._myProperties.allTopLevelNodes;
      }
    }
  },
  initComponent: function() {
    var cache, cm, comp, props, treeConfig;
    cm = Corefw.util.Common;
    cache = this.cache;
    props = cache._myProperties;
    this.coretype = props.coretype;
    treeConfig = this.createTreeConfig();
    treeConfig.store = this.createStore();
    if (!props.pageSize && props.showTitleBar === false) {
      delete treeConfig.title;
      delete treeConfig.tools;
      delete treeConfig.header;
    }
    comp = this.createTree(treeConfig);
    this.items = [];
    this.items.push(comp);
    this.tree = comp;
    this.callParent(arguments);
    delete this.treeConfig;
  },
  generateTreeTool: function(navArray) {
    var cache, evt, fieldLabel, fieldLabelTool, navTools, props, _ref;
    fieldLabel = this.fieldLabel;
    this.fieldLabel = '';
    evt = Corefw.util.Event;
    cache = this.cache;
    props = cache._myProperties;
    navArray = (props != null ? (_ref = props.navs) != null ? _ref._ar : void 0 : void 0) || [];
    if (!Ext.isArray(navArray)) {
      navArray = [];
    }
    this.configureFilterButtons(props, navArray);
    fieldLabelTool = {
      xtype: 'text',
      text: (fieldLabel === '&nbsp;' ? '' : fieldLabel),
      margin: '0 10 0 0 ',
      cls: 'custom-header'
    };
    navTools = Ext.Array.map(navArray, function(nav) {
      var toolConfig;
      toolConfig = {
        xtype: 'button',
        ui: 'toolbutton',
        scale: 'small',
        tooltip: nav.toolTip,
        iconCls: nav.style,
        uipath: nav.uipath,
        hidden: !nav.visible,
        disabled: !nav.enabled
      };
      if (Corefw.util.Startup.getThemeVersion() === 2) {
        toolConfig.iconCls = 'icon icon-' + Corefw.util.Cache.cssclassToIcon[nav.style];
      }
      evt.addEvents(nav, 'nav', toolConfig);
      return toolConfig;
    });
    return [fieldLabelTool].concat(navTools);
  },
  configureFilterButtons: function(props, tools) {
    var InlineFilterIconCls, fieldItemstype, filterVisibility, getButtonTpl, me, showhidefilter, showhidefiltr, themeVersion;
    getButtonTpl = function() {
      return {
        align: 'LEFT',
        cssClass: '',
        cssClassList: [],
        enabled: true,
        events: {},
        group: {},
        navigationType: 'DEFAULT',
        readOnly: false,
        visible: true,
        widgetType: 'NAVIGATION'
      };
    };
    themeVersion = Corefw.util.Startup.getThemeVersion();
    fieldItemstype = props.columnAr;
    showhidefiltr = this.isFilterEnabledForAnyColumn(fieldItemstype);
    if (showhidefiltr) {
      me = this;
      if (themeVersion === 2) {
        showhidefilter = props.hideGridHeaderFilters;
        filterVisibility = me.inlineFilterVisibility;
        InlineFilterIconCls = showhidefilter === true ? 'icon icon-filterswitch-1' : filterVisibility === false ? 'icon icon-filterswitch-1' : 'icon icon-filterswitch-2';
      } else {
        InlineFilterIconCls = me.inlineFilterVisibility === void 0 ? 'I_SHOWFILTER' : me.inlineFilterVisibility === false ? 'I_HIDEFILTER' : 'I_SHOWFILTER';
      }
      tools.push(Ext.apply(getButtonTpl(), {
        name: 'Hide/show',
        title: 'Hide/show',
        toolTip: 'Hide/Show Filters',
        style: InlineFilterIconCls,
        localEvent: true,
        handler: function() {
          var grid, thePlugin;
          grid = me.grid || me.tree;
          thePlugin = grid.findPlugin('inlinefilter');
          if (thePlugin.visibility) {
            thePlugin.visibility = false;
            if (themeVersion === 2) {
              this.setIconCls('icon icon-filterswitch-1');
            } else {
              this.setIconCls('I_HIDEFILTER');
            }
            thePlugin.resetup(grid);
          } else {
            thePlugin.visibility = true;
            if (themeVersion === 2) {
              this.setIconCls('icon icon-filterswitch-2');
            } else {
              this.setIconCls('I_SHOWFILTER');
            }
            thePlugin.setup(grid);
          }
          grid.getView().refresh();
          me.inlineFilterVisibility = thePlugin.visibility;
        }
      }));
      tools.push(Ext.apply(getButtonTpl(), {
        name: 'Clear',
        title: 'Clear',
        toolTip: 'Clear All Filters',
        style: themeVersion === 2 ? 'icon icon-filter-delete' : 'I_CLEARFILTER',
        localEvent: true,
        handler: function() {
          var grid, thePlugin;
          grid = me.grid || me.tree;
          thePlugin = grid.findPlugin('inlinefilter');
          thePlugin.resetFilters(grid);
        }
      }));
    }
  },
  isFilterEnabledForAnyColumn: function(fieldItems) {
    var enabledforcolumn;
    enabledforcolumn = false;
    Ext.each(fieldItems, function(item) {
      if (typeof item._myProperties.filterType !== 'undefined') {
        enabledforcolumn = true;
      }
    });
    return enabledforcolumn;
  },
  onRender: function() {
    this.callParent(arguments);
    if (this.maxHeight) {
      this.tree.maxHeight = this.maxHeight;
      this.tree.setHeight(this.maxHeight);
    }
  },
  createTreeConfig: function() {
    var cache, props, su, treeConfig, treeTools;
    su = Corefw.util.Startup;
    cache = this.cache;
    props = cache._myProperties;
    treeConfig = {
      cache: cache,
      selectType: props.selectType
    };
    if (props.noLines) {
      treeConfig.lines = false;
    }
    if (props.widgetType && props.widgetType === 'TREE_NAVIGATION') {
      if (su.getThemeVersion() === 2) {
        treeConfig.cls = 'treedarkstyle';
        treeConfig.bodyStyle = {
          background: '#53565A'
        };
      }
    }
    treeTools = this.generateTreeTool();
    treeConfig.tools = treeTools;
    treeConfig.header = {
      titlePosition: treeTools.length
    };
    this.treeConfig = treeConfig;
    return treeConfig;
  },
  configureTree: function() {
    var cache, fieldAr, firstColumnName, firstField, props;
    cache = this.cache;
    props = cache._myProperties;
    if (props.columnAr) {
      fieldAr = props.columnAr;
      if (fieldAr && fieldAr.length) {
        firstField = fieldAr[0]._myProperties;
        firstColumnName = firstField.index + '';
        this.firstColumnName = firstColumnName;
      } else {
        this.firstColumnName = 'text';
      }
      this.displayField = this.firstColumnName;
    }
  },
  createTree: function(treeConfig) {
    var tree;
    tree = Ext.create('Corefw.view.tree.TreeBase', treeConfig);
    return tree;
  },
  createStoreFields: function() {
    var fields, firstColumnName, newFieldObj;
    fields = [];
    firstColumnName = this.firstColumnName;
    newFieldObj = {
      name: firstColumnName
    };
    fields.push(newFieldObj);
    return fields;
  },
  createStore: function() {
    var cache, dataCache, fields, firstnode, oldSt, props, rootObj, selectallnode, st, storeConfig, storeName;
    cache = this.cache;
    props = cache._myProperties;
    dataCache = props.data;
    if (props.enableClientSideSelectAll) {
      selectallnode = {
        children: [],
        leaf: false,
        expanded: false,
        selectable: true,
        selected: false,
        value: {
          0: 'Select All'
        }
      };
      firstnode = dataCache[0];
      if (firstnode && firstnode.value[0] !== 'Select All') {
        if (firstnode.value[0] !== '(Select All)') {
          dataCache.unshift(selectallnode);
          props.selectallnode = true;
        }
      }
    }
    this.configureTree();
    fields = this.createStoreFields();
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
    rootObj[this.firstColumnName] = 'Root';
    this.treeStoreAddChildren(rootObj, dataCache);
    oldSt = Ext.getStore(storeName);
    if (oldSt) {
      oldSt.destroyStore();
    }
    st = Ext.create('Ext.data.TreeStore', storeConfig);
    return st;
  },
  isChildNodeChecked: function(nodeObj) {
    var child, children, _i, _len;
    children = nodeObj.children;
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      child = children[_i];
      if (child.selected) {
        return true;
      }
    }
    return false;
  },
  configParentNode: function(parentNode, shouldExpand, isSemiSelected, isAllSelected) {
    var props;
    if (parentNode.id === 'root') {
      return;
    }
    props = this.cache._myProperties;
    shouldExpand && props.expandSelectedNode && (parentNode.expanded = true);
    isSemiSelected && (parentNode.semiSelected = true);
    isAllSelected && (parentNode.selected = true);
  },
  treeStoreAddChildren: function(node, childrenNodes) {
    var child, childObj, children, firstColName, isAllSelected, isSemiSelected, props, selectType, semiSelectedNodesCount, shouldExpand, _i, _len, _ref;
    if (childrenNodes == null) {
      childrenNodes = [];
    }
    if (!(childrenNodes && childrenNodes.length > 0)) {
      return;
    }
    children = [];
    node.children = children;
    firstColName = this.firstColumnName;
    props = this.cache._myProperties;
    selectType = (_ref = props.selectType) === 'MULTIPLE' || _ref === 'SINGLE' ? true : false;
    isSemiSelected = false;
    semiSelectedNodesCount = 0;
    shouldExpand = false;
    for (_i = 0, _len = childrenNodes.length; _i < _len; _i++) {
      child = childrenNodes[_i];
      childObj = {
        id: child.index,
        firstColumnName: firstColName,
        leaf: child.leaf,
        disabled: child.disabled,
        expanded: child.expanded,
        semiSelected: false,
        selected: child.selected,
        origSelected: child.selected
      };
      if (node.id === 'root') {
        if (child.cls) {
          childObj.cls = 'topnodecls';
        }
      } else if (!props.lazyLoading && (!child.children || !child.children.length)) {
        childObj.leaf = true;
        childObj.cls = 'noelbow';
      } else if (child.cls) {
        childObj.cls = child.cls;
      }
      childObj[firstColName] = child.value[firstColName];
      children.push(childObj);
      if (child.children && child.children.length) {
        this.treeStoreAddChildren(childObj, child.children);
      }
      childObj.selected && semiSelectedNodesCount++;
      if (selectType) {
        childObj.checked = childObj.selected || childObj.semiSelected;
      }
      isSemiSelected = isSemiSelected || childObj.semiSelected;
      shouldExpand = shouldExpand || childObj.selected || childObj.semiSelected;
    }
    isAllSelected = semiSelectedNodesCount === childrenNodes.length;
    if (!isSemiSelected) {
      isSemiSelected = semiSelectedNodesCount > 0 && !isAllSelected;
    }
    this.configParentNode(node, shouldExpand, isSemiSelected, isAllSelected);
  }
});