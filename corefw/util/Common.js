// Generated by CoffeeScript 1.8.0
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Ext.define('Corefw.util.Common', {
  singleton: true,
  styleHandlers: {
    view: {
      panel: function(cfg, styleSetting) {
        return Ext.apply(cfg, styleSetting);
      }
    },
    perspective: {
      tab: function(cfg, styleSetting) {
        var defaults, key, tabStyle, value;
        defaults = {};
        tabStyle = {
          tabBar: {
            defaults: defaults
          }
        };
        for (key in styleSetting) {
          value = styleSetting[key];
          defaults[key] = value;
        }
        return Ext.apply(cfg, tabStyle);
      },
      toolbar: function(cfg, styleSetting) {
        var toolbarStyle;
        toolbarStyle = {
          toolbarConfig: styleSetting
        };
        return Ext.apply(cfg, toolbarStyle);
      }
    },
    application: {
      tab: function(cfg, styleSetting) {
        var defaults, key, tabStyle, value;
        defaults = {};
        tabStyle = {
          tabBar: {
            defaults: defaults
          }
        };
        for (key in styleSetting) {
          value = styleSetting[key];
          defaults[key] = value;
        }
        return Ext.apply(cfg, tabStyle);
      },
      panel: function(cfg, styleSetting) {
        return Ext.apply(cfg, styleSetting);
      }
    }
  },
  objectClone: function(obj) {
    return Ext.clone(obj);
  },
  copyObjProperties: function(destObj, srcObj, propArray, moveFlag) {
    var prop, val, _i, _len;
    for (_i = 0, _len = propArray.length; _i < _len; _i++) {
      prop = propArray[_i];
      val = srcObj[prop];
      if (typeof val === 'undefined' || val === null) {
        continue;
      }
      if (Ext.isArray(val) || Ext.isObject(val)) {
        destObj[prop] = Ext.clone(val);
      } else {
        destObj[prop] = val;
      }
      if (moveFlag) {
        delete srcObj[prop];
      }
    }
  },
  mergeArrayOfObj: function(destArr, srcArr) {
    var destObj, match, srcObj, _i, _j, _len, _len1;
    destArr = destArr || [];
    srcArr = srcArr || [];
    for (_i = 0, _len = srcArr.length; _i < _len; _i++) {
      srcObj = srcArr[_i];
      match = false;
      for (_j = 0, _len1 = destArr.length; _j < _len1; _j++) {
        destObj = destArr[_j];
        if (srcObj.uipath === destObj.uipath) {
          Ext.apply(destObj, srcObj);
          match = true;
          break;
        }
      }
      if (!destArr.length || match === false) {
        destArr.push(srcObj);
      }
    }
    return destArr;
  },
  objRenameProperty: function(obj, oldPropertyName, newPropertyName) {
    obj[newPropertyName] = obj[oldPropertyName];
    delete obj[oldPropertyName];
  },
  objCopyProperty: function(obj, oldPropertyName, newPropertyName) {
    obj[newPropertyName] = this.objectClone(obj[oldPropertyName]);
  },
  getAppName: function() {
    var className, sp;
    className = this.$className;
    sp = className.split('.');
    return sp[0];
  },
  valueToFieldType: function(value) {
    if (Ext.isString(value)) {
      return 'string';
    }
    if (Ext.isNumber(value)) {
      return Ext.data.Types.NUMBER;
    }
    if (Ext.isDate(value)) {
      return 'date';
    }
  },
  createTooltip: function(targetEl, msg) {
    return Ext.create('Ext.tip.ToolTip', {
      target: targetEl,
      html: msg
    });
  },
  getTreeNodesCount: function(root) {
    var childNode, count, _i, _len, _ref;
    count = 1;
    if (root.childNodes.length === 0) {
      return count;
    }
    _ref = root.childNodes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      childNode = _ref[_i];
      count++;
      count += this.getTreeNodesCount(childNode);
    }
    return count;
  },
  getExpandedTreeNodesCountFromData: function(root) {
    var childNode, count, _i, _len, _ref;
    count = 1;
    if (root.children.length === 0 || !root.expanded) {
      return count;
    }
    _ref = root.children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      childNode = _ref[_i];
      count += this.getExpandedTreeNodesCountFromData(childNode);
    }
    return count;
  },
  traverseTreeStore: function(record, handler) {
    var r, _i, _len, _ref;
    if (typeof handler === "function") {
      handler(record);
    }
    if (record.childNodes.length === 0) {
      return;
    }
    _ref = record.childNodes;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      r = _ref[_i];
      this.traverseTreeStore(r, handler);
    }
  },
  converTreeGridDataToDataList: function(treeGridNodeList) {
    var gridData, node, _i, _len;
    gridData = {};
    for (_i = 0, _len = treeGridNodeList.length; _i < _len; _i++) {
      node = treeGridNodeList[_i];
      this.traverseTreeNodeToGridData(gridData, node, false);
    }
    return gridData;
  },
  traverseTreeNodeToGridData: function(gridData, treeNode) {
    var childrenNode, childrenNodes, _i, _len;
    gridData[treeNode.index] = treeNode;
    childrenNodes = treeNode.children;
    if (childrenNodes === 0) {
      return;
    }
    for (_i = 0, _len = childrenNodes.length; _i < _len; _i++) {
      childrenNode = childrenNodes[_i];
      this.traverseTreeNodeToGridData(gridData, childrenNode);
    }
  },
  setThemeByGlobalVariable: function(applicationName, currentCompName, compCfg) {
    var compType, currentCompStyle, styleCfg, styleHandler, styleHandlers, themeSetting, _ref;
    themeSetting = window[applicationName + '_theme'];
    if (themeSetting != null) {
      currentCompStyle = themeSetting[currentCompName];
      if (currentCompStyle != null) {
        styleHandlers = this.styleHandlers[currentCompStyle.level];
        _ref = currentCompStyle.styleSetting;
        for (compType in _ref) {
          styleCfg = _ref[compType];
          styleHandler = styleHandlers[compType];
          if (typeof styleHandler === "function") {
            styleHandler(compCfg, styleCfg);
          }
        }
      }
    }
  },
  parseDateData: function(valueObj, fieldObj) {
    var colValue, columnType, dt, path, type, _ref, _ref1, _ref2, _ref3;
    for (path in valueObj) {
      colValue = valueObj[path];
      type = (_ref = fieldObj[path]) != null ? (_ref1 = _ref.type) != null ? _ref1.toLowerCase() : void 0 : void 0;
      columnType = (_ref2 = fieldObj[path]) != null ? (_ref3 = _ref2.columnType) != null ? _ref3.toLowerCase() : void 0 : void 0;
      if ((type === 'date' || columnType === 'date' || columnType === 'datetime') && colValue) {
        dt = new Date(colValue);
        valueObj[path] = dt;
      }
    }
  },
  formSubmit: function(comp, url, target) {
    var action, form, formPanel, params;
    formPanel = Ext.create('Ext.form.Panel', {
      standardSubmit: true,
      method: "post"
    });
    form = formPanel.getForm();
    if (comp.generatePostData) {
      params = {
        data: Ext.JSON.encode(comp.generatePostData())
      };
    } else {
      params = comp.generatePostParams();
    }
    action = Ext.create("Ext.form.action.StandardSubmit", {
      form: form,
      target: target,
      params: params,
      url: url
    });
    form.doAction(action);
    Ext.defer(function() {
      form.destroy();
    }, 200);
  },
  download: function(comp, url) {
    var dlFrame, frameName;
    url = url.replace('api/delegator', 'api/delegator/download');
    frameName = "downloadIframe";
    if (!frames[frameName]) {
      dlFrame = Ext.DomHelper.createDom({
        tag: "iframe",
        style: {
          display: 'none'
        },
        name: frameName
      }, Ext.getBody());
      dlFrame.onload = function() {
        var err, jsonStr, rtnStr;
        try {
          rtnStr = this.contentDocument.body.innerHTML;
          if (rtnStr) {
            jsonStr = rtnStr.substring(rtnStr.indexOf("{"), rtnStr.lastIndexOf("}") + 1);
            Corefw.util.Request.processResponseObject(JSON.parse(jsonStr));
          }
        } catch (_error) {
          err = _error;
          console.error("Parsing error be found on download callback: " + err.message);
        }
      };
    }
    this.formSubmit(comp, url, frameName);
  },
  redirect: function(comp, url) {
    if (this.processProhibited(comp)) {
      return;
    }
    url = url.replace('api/delegator', 'api/delegator/redirect');
    this.formSubmit(comp, url, "_blank");
  },
  getValueByFieldName: function(fieldName, item, fn) {
    var arr, single, _i, _j, _len, _len1;
    if (Ext.isArray(item)) {
      arr = [];
      for (_i = 0, _len = item.length; _i < _len; _i++) {
        single = item[_i];
        arr.push(fn.call(this, single));
      }
      return arr;
    }
    if (Ext.isObject(item)) {
      if (Ext.isArray(fieldName)) {
        for (_j = 0, _len1 = fieldName.length; _j < _len1; _j++) {
          single = fieldName[_j];
          if (item[single] !== void 0) {
            return item[single];
          }
        }
      } else {
        return item[fieldName];
      }
    } else {
      return item;
    }
  },
  getDisplayValue: function(item) {
    return this.getValueByFieldName(['displayValue', 'displayField'], item, arguments.callee);
  },
  getValue: function(item) {
    return this.getValueByFieldName(['value', 'valueField'], item, arguments.callee);
  },
  getScrollBarHeight: function() {
    var el, h;
    el = document.createElement('div');
    document.body.appendChild(el);
    el.style.display = 'hidden';
    el.style.overflowX = 'scroll';
    h = el.offsetHeight - el.clientHeight;
    document.body.removeChild(el);
    return h;
  },
  processProhibited: function(comp, isBeforeRender) {
    var compName, compProps, compReadOnly, cu, element, elementProps, elementReadOnly, isEmpty, isProhibited, parent, parentCompReadOnly, parentProps, perspective, perspectiveProps, perspectiveReadOnly, view, viewProps, viewReadOnly, xtype, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
    if (!comp || (!isBeforeRender && !comp.el) || ((_ref = comp.ownerCt) != null ? _ref.xtype : void 0) === "datepicker") {
      return false;
    }
    xtype = comp.xtype;
    if (xtype === 'tab') {
      return false;
    }
    cu = Corefw.util.Uipath;
    isEmpty = Ext.isEmpty;
    if (comp.isInlineFilter) {
      comp = comp.column;
    }
    if (comp.uipath) {
      parent = cu.uipathToParentComponent(comp.uipath);
    } else {
      parent = comp.up('fieldcontainer');
    }
    if (!parent) {
      parent = this.findParentFieldContainerByDomId((_ref1 = comp.el) != null ? (_ref2 = _ref1.dom) != null ? _ref2.id : void 0 : void 0);
    }
    parentProps = (parent != null ? (_ref3 = parent.cache) != null ? _ref3._myProperties : void 0 : void 0) || {};
    parentCompReadOnly = parentProps.readOnly;
    compProps = comp != null ? (_ref4 = comp.cache) != null ? _ref4._myProperties : void 0 : void 0;
    if (!compProps && parentProps.navs) {
      compName = cu.uipathToShortName(comp.uipath);
      compProps = parentProps.navs[compName];
    }
    compReadOnly = compProps != null ? compProps.readOnly : void 0;
    if (!isEmpty(compReadOnly)) {
      return compReadOnly;
    }
    perspective = comp.up('[coretype=perspective]');
    perspectiveProps = (perspective != null ? (_ref5 = perspective.cache) != null ? _ref5._myProperties : void 0 : void 0) || {};
    perspectiveReadOnly = perspectiveProps.readOnly || false;
    view = comp.up('[coretype=view]');
    viewProps = (view != null ? (_ref6 = view.cache) != null ? _ref6._myProperties : void 0 : void 0) || {};
    viewReadOnly = viewProps.readOnly;
    if (isEmpty(viewReadOnly)) {
      viewReadOnly = perspectiveReadOnly;
    }
    element = comp.up('[coretype=element]');
    elementProps = (element != null ? (_ref7 = element.cache) != null ? _ref7._myProperties : void 0 : void 0) || {};
    elementReadOnly = elementProps.readOnly;
    if (isEmpty(elementReadOnly)) {
      elementReadOnly = viewReadOnly;
    }
    if (isEmpty(parentCompReadOnly)) {
      parentCompReadOnly = elementReadOnly;
    }
    isProhibited = parentCompReadOnly || elementReadOnly || viewReadOnly || perspectiveReadOnly;
    return isProhibited;
  },
  findParentFieldContainerByDomId: function(domId) {
    var dom, domMatches, domQuery, fieldcontainers, ft, qDomId, _i, _j, _len, _len1;
    fieldcontainers = Ext.ComponentQuery.query('fieldcontainer[el]');
    domQuery = Ext.DomQuery.select;
    qDomId = '#' + domId;
    for (_i = 0, _len = fieldcontainers.length; _i < _len; _i++) {
      ft = fieldcontainers[_i];
      domMatches = domQuery(qDomId, ft.el.dom);
      if (domMatches.length > 0) {
        for (_j = 0, _len1 = domMatches.length; _j < _len1; _j++) {
          dom = domMatches[_j];
          if (dom.id === domId) {
            return ft;
          }
        }
      }
    }
    return null;
  },
  formatValueBySpecial: function(value, format) {
    var fStr, formater, linkNumberFormatter, type, typeFormaters, _ref;
    linkNumberFormatter = function(val, fStr) {
      var d2d, denomination, denominationRegExp, divisor, isNumber;
      denominationRegExp = /[0,\.#]+(K|MM|BN)?$/;
      isNumber = Ext.isNumber(val);
      if (!isNumber) {
        return val;
      }
      if (denominationRegExp.test(fStr)) {
        d2d = {
          K: 1000,
          MM: 1000000,
          BN: 1000000000
        };
        denomination = RegExp.$1;
        divisor = d2d[denomination];
        if (divisor) {
          val = val / divisor;
        }
      }
      return Ext.util.Format.number(val, fStr);
    };
    typeFormaters = {
      NUMBER: linkNumberFormatter,
      DATE: Ext.util.Format.date
    };
    _ref = format.split(':'), type = _ref[0], fStr = _ref[1];
    formater = typeFormaters[type];
    if (!formater) {
      return value;
    }
    return formater(value, fStr);
  },
  configureViewDragAndDrop: function(comp, isGrid) {
    var cache, cfg, dragDropViewRender, dragFromUipath, generateDragDropPostData, isDraggable, isDroppable, props, ptype, recievablePaths, startUpObj;
    if (isGrid == null) {
      isGrid = true;
    }
    cache = comp.cache;
    props = cache._myProperties;
    isDraggable = props.draggable || false;
    recievablePaths = props.recievablePaths || [];
    isDroppable = recievablePaths.length > 0;
    ptype = isGrid ? 'gridviewdragdrop' : 'treeviewdragdrop';
    dragFromUipath = props.uipath;
    dragDropViewRender = this.dragDropViewRender;
    generateDragDropPostData = this.generateDragDropPostData;
    startUpObj = Corefw.util.Startup.getStartupObj();
    if (isDraggable || isDroppable) {
      cfg = {
        viewConfig: {
          minHeight: 10,
          plugins: {
            ptype: ptype,
            ddGroup: isGrid ? 'GridDD' : 'TreeDD',
            enableDrag: isDraggable,
            enableDrop: isDroppable,
            onViewRender: function(view) {
              dragDropViewRender(this, view, isGrid, dragFromUipath);
            }
          },
          listeners: {
            drop: function(node, data, dropRec, dropPosition) {
              var dragFromView, dropToUipath, dropToView, grid, postData, rq, url, _ref, _ref1;
              grid = this.up('grid');
              grid.getStore().remove(data.records);
              rq = Corefw.util.Request;
              dragFromView = data.view;
              dropToView = node.dataset ? Ext.getCmp(node.dataset.boundview) : this;
              if (!dropToView) {
                return false;
              }
              dragFromView.getSelectionModel().select(parseInt(data.item.dataset.recordindex));
              dragFromUipath = (_ref = dragFromView.up('fieldcontainer')) != null ? _ref.cache._myProperties.uipath : void 0;
              dropToUipath = (_ref1 = dropToView.up('fieldcontainer')) != null ? _ref1.cache._myProperties.uipath : void 0;
              if (!dragFromUipath && !dropToUipath) {
                return;
              }
              postData = generateDragDropPostData(dragFromView, dropToView, dragFromUipath);
              url = dropToUipath + '/ONDND/' + dragFromUipath;
              url = rq.objsToUrl3(url);
              rq.sendRequest5(url, rq.processResponseObject, dropToUipath, postData, 'The drag and drop request is failed', 'POST', null, null, null);
            }
          }
        }
      };
      if (isGrid) {
        Ext.apply(comp, cfg);
      } else {
        Ext.apply(comp.treeConfig, cfg);
      }
    }
  },
  dragDropViewRender: function(me, view, isGrid, dragFromUiPath) {
    var dragCfg, dropCfg, gridDropZoneCfg, scrollEl;
    if (me.enableDrag) {
      if (me.containerScroll) {
        scrollEl = view.getEl();
      }
    }
    view.copy = true;
    dragCfg = {
      view: view,
      ddGroup: 'viewDD',
      dragText: me.dragText,
      scrollEl: scrollEl,
      beforeDragOver: function(dropTo, e, id) {
        var recievablePaths, _ref;
        recievablePaths = ((_ref = dropTo.view.up('fieldcontainer')) != null ? _ref.cache._myProperties.recievablePaths : void 0) || [];
        if (-1 < recievablePaths.indexOf(dragFromUiPath)) {
          return true;
        } else {
          return false;
        }
      },
      beforeDragDrop: function(dropTo, e, id) {
        var r, records, _i, _len;
        records = this.dragData.records;
        for (_i = 0, _len = records.length; _i < _len; _i++) {
          r = records[_i];
          if (r.childNodes) {
            r.data.checked = true;
          } else {
            this.dragData.view.select(r);
          }
        }
        return true;
      }
    };
    dropCfg = {
      view: view,
      ddGroup: 'viewDD'
    };
    if (isGrid) {
      if (me.enableDrag) {
        dragCfg.containerScroll = me.containerScroll;
        me.gridDragZone = new Ext.view.DragZone(dragCfg);
      }
      if (me.enableDrop) {
        gridDropZoneCfg = {
          onNodeOut: function(target, dd, e, data) {
            return this.hideIndicator();
          },
          onNodeOver: function(target, dd, e, data) {
            var cls, columnIndex, columns;
            cls = Ext.dd.DropZone.prototype.dropAllowed;
            columns = this.view.getGridColumns();
            columnIndex = this.getEventTargetIndex(e);
            this.positionIndicator(columnIndex);
            this.valid = true;
            return cls;
          },
          hideIndicator: function() {
            this.getTopIndicator().hide();
            this.getBottomIndicator().hide();
          },
          positionIndicator: function(columnIndex) {
            var bottomIndicator, bottomXY, column, topIndicator, topXY, x;
            column = this.view.getGridColumns()[columnIndex];
            if (!column) {
              return;
            }
            this.hideIndicator();
            topIndicator = this.getTopIndicator();
            bottomIndicator = this.getBottomIndicator();
            x = column.getX() + column.getWidth() - this.indicatorXOffset;
            topXY = [x, column.getY() - topIndicator.getHeight()];
            bottomXY = [x, column.getY() + column.getHeight()];
            topIndicator.show();
            bottomIndicator.show();
            topIndicator.setXY(topXY);
            bottomIndicator.setXY(bottomXY);
          },
          getEventTargetIndex: function(e) {
            var column, columnWidth, columnX, columns, eventX, index, _i, _len;
            columns = this.view.getGridColumns();
            eventX = e.getX();
            for (index = _i = 0, _len = columns.length; _i < _len; index = ++_i) {
              column = columns[index];
              columnX = column.getX();
              columnWidth = column.getWidth();
              if (eventX > columnX && eventX < columnX + columnWidth) {
                return index;
              }
            }
            return -1;
          },
          getTopIndicator: function() {
            if (!this.topIndicator) {
              this.topIndicator = Ext.DomHelper.append(Ext.getBody(), {
                role: 'presentation',
                cls: "col-move-top",
                "data-sticky": true,
                html: "&#160;"
              }, true);
              this.indicatorXOffset = Math.floor((this.topIndicator.dom.offsetWidth + 1) / 2);
            }
            return this.topIndicator;
          },
          getBottomIndicator: function() {
            if (!this.bottomIndicator) {
              this.bottomIndicator = Ext.DomHelper.append(Ext.getBody(), {
                role: 'presentation',
                cls: "col-move-bottom",
                "data-sticky": true,
                html: "&#160;"
              }, true);
            }
            return this.bottomIndicator;
          }
        };
        Ext.apply(dropCfg, gridDropZoneCfg);
        me.gridGropZone = new Ext.grid.ViewDropZone(dropCfg);
      }
    } else {
      if (me.enableDrag) {
        dragCfg.displayField = me.displayField;
        dragCfg.repairHighlightColor = me.nodeHighlightColor;
        dragCfg.repairHighlight = me.nodeHighlightOnRepair;
        me.treeDragZone = new Ext.tree.ViewDragZone(dragCfg);
      }
      if (me.enableDrop) {
        dropCfg.allowContainerDrops = me.allowContainerDrops;
        dropCfg.appendOnly = me.appendOnly;
        dropCfg.allowParentInserts = me.allowParentInserts;
        dropCfg.expandDelay = me.expandDelay;
        dropCfg.dropHighlightColor = me.nodeHighlightColor;
        dropCfg.dropHighlight = me.nodeHighlightOnDrop;
        dropCfg.sortOnDrop = me.sortOnDrop;
        dropCfg.containerScroll = me.containerScroll;
        me.treeDropZone = new Ext.tree.ViewDropZone(dropCfg);
      }
    }
  },
  generateDragDropPostData: function(dragFromComp, dropToComp, dragFromUipath) {
    var dragFromPostData, dropToPostData;
    dragFromPostData = dragFromComp.up('fieldcontainer').generatePostData();
    dropToPostData = dropToComp.up('fieldcontainer').generatePostData();
    dropToPostData.from = dragFromPostData;
    dropToPostData.from.uipath = dragFromUipath;
    return dropToPostData;
  },
  findRecordIndex: function(store, record) {
    var data, nodeIndex, nodeList, tree;
    if (!store || !record) {
      return -1;
    }
    if (tree = store.tree) {
      nodeList = this.getNodeListFromTreeStore(store);
      nodeIndex = nodeList.indexOf(record);
      return nodeIndex - 1;
    } else if (data = store.data) {
      return store.indexOf(record);
    } else {
      return -1;
    }
  },
  getNodeListFromTreeStore: function(store) {
    var loopNodes, nodeList, root;
    nodeList = [];
    root = store.tree.root;
    loopNodes = function(nodeList, node) {
      var childNodes, n, _i, _len;
      if (node.childNodes.length === 0) {
        nodeList.push(node);
        return;
      }
      childNodes = node.childNodes;
      nodeList.push(node);
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        n = childNodes[_i];
        loopNodes(nodeList, n);
      }
    };
    loopNodes(nodeList, root);
    return nodeList;
  },
  setMaxAndMinHeight: function(fieldCt) {
    var childComp, elementForm, fieldProps, maxHeight, maxRow, minHeight, minRow, standardRowHeight, view, _ref, _ref1, _ref2;
    elementForm = fieldCt.up('coreelementform');
    if ((elementForm != null ? elementForm.cache._myProperties.isAbsoluteLayout : void 0) === true) {
      return;
    }
    fieldProps = ((_ref = fieldCt.cache) != null ? _ref._myProperties : void 0) || {};
    if (!fieldCt.el) {
      return;
    }
    childComp = fieldCt.grid || fieldCt.tree;
    if (!childComp) {
      return;
    }
    standardRowHeight = (_ref1 = childComp.getView()) != null ? (_ref2 = _ref1.getNode(0)) != null ? _ref2.offsetHeight : void 0 : void 0;
    standardRowHeight = standardRowHeight || childComp.standardRowHeight || 21;
    minRow = parseInt(fieldProps.minRow);
    maxRow = parseInt(fieldProps.maxRow);
    view = childComp.getView();
    if (!view) {
      return;
    }
    if (view.minHeight || view.maxHeight) {
      return;
    }
    if (minRow) {
      minHeight = minRow * standardRowHeight;
      this.setMaxAndMinHeightToView(view, false, minHeight);
    }
    if (maxRow) {
      maxHeight = maxRow * standardRowHeight;
      this.setMaxAndMinHeightToView(view, true, maxHeight);
    }
  },
  setMaxAndMinHeightToView: function(view, isMax, height) {
    var key;
    key = isMax ? "maxHeight" : "minHeight";
    if (view.isLockingView) {
      view.lockedView[key] = height;
      view.normalView[key] = height;
    } else {
      view[key] = height;
    }
  },
  getKeyByValue: function(v, obj) {
    var key;
    for (key in obj) {
      if (obj.hasOwnProperty(key) && obj[key] === v) {
        return key;
      }
    }
  },
  preventBackspaceEvent: function(event) {
    var element, inputType, keyCode, needPrevent, _ref;
    if (!event) {
      event = window.event;
    }
    keyCode = event.keyCode;
    element = event.target || event.srcElement;
    needPrevent = ((keyCode === 8) || (keyCode === 65 && event.ctrlKey)) && element.tagName !== "TEXTAREA";
    if (element.tagName === "INPUT") {
      inputType = ["button", "color", "file", "image", "radio", "range", "reset", "submit"];
      needPrevent = needPrevent && ((_ref = element.type, __indexOf.call(inputType, _ref) >= 0) || element.readOnly || element.disabled);
    }
    if (needPrevent) {
      if (!Ext.isIE) {
        event.stopPropagation();
      } else {
        event.returnValue = false;
      }
      return false;
    }
  },
  updateCommon: function(widget, newProps) {
    var newEnabled, newTitle, newVisible, oldEnabled, oldProps, oldTitile, oldVisible;
    oldProps = widget.cache._myProperties;
    oldTitile = oldProps.title;
    newTitle = newProps.title;
    oldVisible = oldProps.visible;
    newVisible = newProps.visible;
    oldEnabled = oldProps.enabled;
    newEnabled = newProps.enabled;
    if (oldEnabled !== newEnabled) {
      widget.setDisabled(!newEnabled);
    }
    if (widget.xtype === 'coreelementform' || widget.xtype === 'corecompositeelement') {
      this.updateElementHeader(widget, newProps, widget.xtype === 'corecompositeelement');
      if (newVisible !== oldVisible) {
        widget.setVisible(newVisible);
      }
    } else {
      if (newTitle !== oldTitile) {
        widget.setTitle(newTitle);
      }
    }
    if (oldProps.cssclass !== newProps.cssclass) {
      if (oldProps.cssclass) {
        widget.removeCls(oldProps.cssclass);
      }
      if (newProps.cssclass) {
        widget.addCls(newProps.cssclass);
      }
    }
  },
  getSearchXtypeForDownload: function(props) {
    var coretype, parentCache, parentProps, parentType, searchXtype, uip, _ref;
    uip = Corefw.util.Uipath;
    parentType = (_ref = props.widgetType) != null ? _ref.toLowerCase() : void 0;
    searchXtype = null;
    switch (parentType) {
      case 'form':
      case 'form_based_element':
        searchXtype = 'form';
        break;
      case 'table':
      case 'objectgrid':
      case 'object_grid':
        searchXtype = 'grid';
        break;
      case 'fieldset':
        searchXtype = 'corefieldset';
        break;
      case 'rcgrid':
        searchXtype = 'corercgrid';
        break;
      case 'tree_grid':
        searchXtype = 'coretreegrid';
        break;
      case 'view':
        searchXtype = '[coretype=view]';
        break;
      case 'perspective':
        searchXtype = 'coreperspective';
        break;
      case 'chart':
        searchXtype = 'corechartfield';
        break;
      case 'tree':
        searchXtype = 'coretreesimple';
        break;
      case 'composite_element':
        searchXtype = 'corecompositeelement';
        break;
      case 'breadcrumb':
        searchXtype = '[coretype=breadcrumb]';
        break;
      default:
        console.log('onNavClickEvent unable to find parentType: ', parentType);
        if (typeof parentType === 'undefined') {
          coretype = props.coretype;
        } else if (parentType === 'toolbar') {
          parentCache = uip.uipathToParentCacheItem(props.uipath);
          parentProps = parentCache._myProperties;
          coretype = parentProps.coretype;
        }
        switch (coretype) {
          case 'element':
            searchXtype = 'form';
            break;
          case 'view':
            searchXtype = '[coretype=view]';
            break;
          case 'perspective':
            searchXtype = 'coreperspective';
            break;
          case 'compositeElement':
            searchXtype = 'corecompositeelement';
        }
    }
    return searchXtype;
  },
  updateElementHeader: function(comp, newProps, isCompEl) {
    var me, nExpanded, nTitle, oExpanded, oTitle, oldProps, secondTitleCmp, su, _ref, _ref1, _ref2;
    me = comp;
    oldProps = me.cache._myProperties;
    oTitle = oldProps.title;
    nTitle = newProps.title;
    su = Corefw.util.Startup;
    if (!nTitle) {
      if (oTitle) {
        me.removeDocked(me.header);
      }
    }
    if (nTitle) {
      if (oTitle) {
        if (oldProps.collapsible && isCompEl && !su.getThemeVersion()) {
          nTitle = '&nbsp;&nbsp;&nbsp;' + nTitle;
        }
        me.title = nTitle;
        delete me.originalTitle;
      }
      if (!me.originalTitle || (oldProps.secondTitle !== newProps.secondTitle)) {
        me.secondTitle = newProps.secondTitle;
        secondTitleCmp = me.secondTitleCmp;
        if (secondTitleCmp) {
          me.header.remove(secondTitleCmp);
        }
        delete me.secondTitleCmp;
      }
      if (!me.originalTitle || (me.secondTitle && !me.secondTitleCmp)) {
        Corefw.util.Render.addSecondTitle(me);
      }
    }
    oTitle = nTitle;
    if (oldProps.toolTip !== newProps.toolTip) {
      if ((_ref = me.header) != null) {
        if ((_ref1 = _ref.el) != null) {
          if (typeof _ref1.set === "function") {
            _ref1.set({
              'data-qtip': newProps.toolTip
            });
          }
        }
      }
    }
    if (oldProps.collapsible !== newProps.collapsible) {
      return;
    }
    nExpanded = newProps.expanded;
    oExpanded = !me.collapsed;
    if (((_ref2 = me.el) != null ? typeof _ref2.hasCls === "function" ? _ref2.hasCls("" + Ext.baseCSSPrefix + "tabpanel-child") : void 0 : void 0) || !oldProps.collapsible || !oTitle || !newProps.visible) {
      return;
    }
    if (nExpanded !== oExpanded) {
      if (nExpanded) {
        me.expand();
      } else {
        me.collapse();
      }
    }
  },
  stripHtml: function(html) {
    var tmp;
    tmp = document.createElement("TDIV");
    tmp.innerHTML = html;
    return Ext.String.trim(tmp.textContent || tmp.innerText || "");
  }
});
