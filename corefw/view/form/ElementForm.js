// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.ElementForm', {
  extend: 'CitiRiskLibrary.view.CitiRiskFormPanel',
  mixins: ['Corefw.mixin.FieldContainer', 'Corefw.mixin.Refreshable'],
  xtype: 'coreelementform',
  formtype: 'elementform',
  layout: 'absolute',
  titleCollapse: true,
  hideCollapseTool: true,
  style: {
    border: 'none'
  },
  bodyStyle: {
    border: 'none'
  },
  defaults: {},
  suppressClosing: true,
  initComponent: function() {
    this.elementInitialize();
    if (this.additionalConfig) {
      this.additionalConfig();
    }
    this.addListeners();
    this.callParent(arguments);
    this.addCls('elementform-cls');
  },
  elementInitialize: function() {
    var allTopLevelNodes, cache, config, eachnode, elementCss, evt, headerCft, iv, key, layout, me, props, su, titleEl, treesinelement, uipath, val, value, valueprops;
    me = this;
    iv = Corefw.util.InternalVar;
    evt = Corefw.util.Event;
    su = Corefw.util.Startup;
    layout = Corefw.view.layout.Layout;
    cache = me.cache;
    props = cache._myProperties;
    uipath = props.uipath;
    me.layoutManager = layout.create(me);
    config = {
      frame: false,
      closable: false,
      coretype: 'element',
      autoScroll: false,
      collapsible: props.collapsible,
      border: 1,
      uipath: uipath,
      hidden: !props.visible,
      disabled: !props.enabled,
      secondTitle: props.secondTitle
    };
    if (su.getThemeVersion() === 2) {
      if (this.isChildWithHeader(cache)) {
        me.addCls('element-child-with-header');
      }
      for (key in cache) {
        value = cache[key];
        if (key !== '_myProperties') {
          valueprops = value._myProperties;
          if (valueprops && valueprops.widgetType === 'TREE_NAVIGATION') {
            config.bodyStyle = {
              background: '#53565A',
              border: '0px'
            };
            config.header = {
              style: 'background: #686A6D; color: #FFFFFF'
            };
            treesinelement = valueprops.treesinelement;
            if (treesinelement) {
              delete valueprops.treesinelement;
            } else {
              allTopLevelNodes = valueprops.allTopLevelNodes;
              for (eachnode in allTopLevelNodes) {
                val = allTopLevelNodes[eachnode];
                val.cls = 'topnodecls';
              }
            }
          }
        }
      }
    }
    elementCss = props.cssclass;
    if (elementCss) {
      me.addCls(elementCss);
    }
    if (props.hideBorder) {
      config.border = false;
      config.style = {
        border: '0px'
      };
    }
    if (props.closable) {
      config.closable = true;
    }
    if (props.toolTip) {
      config.header = config.header || {};
      titleEl = {
        autoEl: {
          'data-qtip': props.toolTip
        }
      };
      Ext.apply(config.header, titleEl);
    }
    if (props.toolbar) {
      config.header = config.header || {};
      headerCft = {
        padding: '0 7 0 5',
        minHeight: 30,
        listeners: {
          click: function(th, e, eOpts) {
            var form;
            if (e.target.tagName === 'DIV') {
              form = th.up('coreelementform');
              if (form && form.collapsible) {
                form.toggleCollapse();
              }
            }
          }
        }
      };
      if (!su.getThemeVersion()) {
        Ext.apply(config.header, headerCft);
      }
    }
    if (!su.useClassicTheme()) {
      config.ui = 'citiriskfixedpanel';
    }
    config.collapsed = !props.expanded;
    if (!props.title) {
      config.header = false;
      config.collapsed = false;
      me.addCls('element-without-header');
    } else {
      config.title = props.title;
      me.addCls('element-with-header');
    }
    if (me.autoScroll) {
      config.autoScroll = true;
    }
    if (me.flex) {
      delete config.autoScroll;
      config.overflowY = 'auto';
    }
    evt.addEvents(props, 'element', config);
    Ext.apply(me, config);
  },
  elementMixinRender: function() {
    var evt;
    evt = Corefw.util.Event;
    if (this.elementONLOADevent || this.elementONREFRESHevent) {
      evt.fireRenderEvent(this);
    }
  },
  generatePostData: function() {
    var fcMixin, postData;
    fcMixin = this.mixins['Corefw.mixin.FieldContainer'];
    postData = fcMixin.generatePostData.call(this);
    postData.expanded = !this.collapsed;
    return postData;
  },
  onRender: function() {
    var su;
    su = Corefw.util.Startup;
    this.disableFormEvents = true;
    this.callParent(arguments);
    this.rendered = true;
    if (this.xtype !== 'coreelementbar') {
      this.layoutMain();
      this.renderTooltips();
    }
    this.elementMixinRender();
    if (this.title && this.collapsible) {
      if (this.collapsed) {
        this.addCls('panelcolltxtclr');
      } else {
        this.addCls('panelexptxtclr');
      }
    }
  },
  afterRender: function() {
    var evt;
    this.callParent(arguments);
    this.restoreFieldFocus();
    this.addSecondTitle();
    delete this.disableFormEvents;
    evt = Corefw.util.Event;
    evt.enableUEvent(this.uipath, 'ONCLOSE');
  },
  isOncloseEventDisabled: function() {
    return this.suppressClosing;
  },
  addSecondTitle: function() {
    var rdr;
    if (this.isBarElement) {
      return;
    }
    rdr = Corefw.util.Render;
    rdr.addSecondTitle(this);
  },
  restoreFieldFocus: function() {
    var delayFunc, fieldComp, fieldUipath, iv, me, uip, uipath, _ref;
    me = this;
    iv = Corefw.util.InternalVar;
    uip = Corefw.util.Uipath;
    uipath = this.uipath;
    fieldUipath = iv.getByUipathProperty(uipath, 'formfieldfocus');
    if (fieldUipath) {
      fieldComp = uip.uipathToComponent(fieldUipath);
      if (!fieldComp) {
        return;
      } else {
        if ((_ref = fieldComp.eventURLs) != null ? _ref.ONBLUR : void 0) {
          return;
        }
      }
      delayFunc = Ext.Function.createDelayed(function() {
        var origLookupEvent, origSelectEvent;
        if (fieldComp.fieldONSELECTevent) {
          origSelectEvent = true;
          delete fieldComp.fieldONSELECTevent;
        }
        if (fieldComp.fieldONLOOKUPevent) {
          origLookupEvent = true;
          fieldComp.isStop = true;
          delete fieldComp.fieldONLOOKUPevent;
        }
        me.restoreFieldCursorPosition(fieldComp);
        if (fieldComp.xtype !== 'coregridpicker') {
          fieldComp.focus();
        }
        iv.deleteUipathProperty(uipath, 'formfieldfocus');
        iv.deleteByNameProperty('radiofocus');
        if (origSelectEvent) {
          fieldComp.fieldONSELECTevent = true;
        }
        if (origLookupEvent) {
          fieldComp.fieldONLOOKUPevent = true;
          fieldComp.isStop = false;
        }
      }, 1);
      delayFunc();
      console.log('field focus component found: ', fieldUipath, fieldComp);
    }
  },
  restoreFieldCursorPosition: function(field) {
    var cursPos, dom, iv, node, uipath, _ref;
    iv = Corefw.util.InternalVar;
    uipath = field.uipath;
    cursPos = iv.getByUipathProperty(uipath, 'fieldcursorposition');
    if (!cursPos) {
      return;
    }
    console.log('restoring cursor position = ', cursPos);
    dom = (_ref = field.getEl()) != null ? _ref.dom : void 0;
    if (!dom) {
      return;
    }
    node = Ext.dom.Query.selectNode('input', dom);
    if (!node) {
      node = Ext.dom.Query.selectNode('textarea', dom);
      if (!node) {
        return;
      }
    }
    try {
      node.selectionStart = cursPos;
      node.selectionEnd = cursPos;
    } catch (_error) {
      console.log('failed to restore field cursor');
    }
  },
  onResize: function() {
    var me, myFunc;
    me = this;
    if (me.alreadyResize || me.collapsed) {
      return;
    }
    me.alreadyResize = true;
    me.callParent(arguments);
    me.layoutManager.resize();
    myFunc = Ext.Function.createDelayed(function() {
      delete me.alreadyResize;
    }, 1000);
    myFunc();
  },
  addListeners: function() {
    var additionalListeners;
    this.listeners = this.listeners || {};
    additionalListeners = {
      beforeexpand: this.onPanelExpand,
      beforecollapse: this.onPanelCollapse,
      afterlayout: this.afterPanelLayout,
      close: this.onElementClose,
      beforedestroy: this.beforeElementDestroy,
      destroy: this.afterPanelDestroy
    };
    Ext.apply(this.listeners, additionalListeners);
  },
  beforeElementDestroy: function() {
    var rdr;
    rdr = Corefw.util.Render;
    rdr.destroyThisComponent(this);
  },
  onElementClose: function() {
    this.suppressClosing = false;
  },
  afterPanelDestroy: function() {
    var _ref;
    if ((_ref = this.tooltipManager) != null) {
      if (typeof _ref.destroy === "function") {
        _ref.destroy();
      }
    }
    delete tooltipManager;
  },
  afterPanelLayout: function() {
    var _ref;
    if (this.resizeWhenVisible) {
      if ((_ref = this.layoutManager) != null) {
        if (typeof _ref.resize === "function") {
          _ref.resize();
        }
      }
      delete this.resizeWhenVisible;
    }
  },
  onPanelExpand: function(form) {
    var method, postData, rq, uipath, url;
    form.removeCls('panelcolltxtclr');
    form.addCls('panelexptxtclr');
    if (this.eventURLs['ONELEMENTEXPAND']) {
      rq = Corefw.util.Request;
      uipath = this.uipath;
      url = rq.objsToUrl3(this.eventURLs['ONELEMENTEXPAND']);
      postData = this.generatePostData();
      postData.expanded = true;
      method = 'POST';
      rq.sendRequest5(url, rq.processResponseObject, this.uipath, postData);
    }
  },
  onPanelCollapse: function(form) {
    form.removeCls('panelexptxtclr');
    form.addCls('panelcolltxtclr');
  },
  isChildWithHeader: function(cache) {
    var contentCache, contentKey, contentProps, hasTitleBar;
    for (contentKey in cache) {
      contentCache = cache[contentKey];
      if (contentKey !== '_myProperties') {
        contentProps = contentCache._myProperties;
        switch (contentProps != null ? contentProps.widgetType : void 0) {
          case 'FIELD':
          case 'FIELDSET':
            return false;
          case 'MIXED_GRID':
            if (!Ext.isEmpty(contentProps.title)) {
              hasTitleBar = true;
            }
            break;
          case 'OBJECT_GRID':
          case 'RCGRID':
          case 'TREE_GRID':
          case 'HIERARCHY_OBJECT_GRID':
          case 'PIVOTGRID':
          case 'TREE':
          case 'DYNAMIC_TREE':
            if (contentProps.showTitleBar === true) {
              hasTitleBar = true;
            }
        }
      }
    }
    return hasTitleBar;
  },

  /*
     	@override
     	@param {boolean} isInitLoading if true, before loading record, will suspend all change event and reset original value of the form fields
   */
  loadRecord: function(record, isInitLoading) {
    var form;
    if (isInitLoading == null) {
      isInitLoading = false;
    }
    form = this.getForm();
    if (isInitLoading) {
      form.trackResetOnLoad = true;
      form.getFields().items.forEach(function(field) {
        field.suspendCheckChange++;
      });
    }
    this.callParent(arguments);
    if (isInitLoading) {
      form.trackResetOnLoad = false;
      form.getFields().items.forEach(function(field) {
        field.lastValue = field.getValue();
        field.suspendCheckChange--;
      });
    }
  }
});