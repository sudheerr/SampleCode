// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.Perspective', {
  extend: 'Ext.tab.Panel',
  xtype: 'coreperspective',
  mixins: ['Corefw.mixin.Perspective'],
  plain: true,
  closable: false,
  layout: 'fit',
  coretype: 'perspective',
  listeners: {
    added: function(me, container, pos, eOpts) {
      me.addToolbarAndViews();
    }
  },
  initComponent: function() {
    var cache, cm, config, errArray, evt, key, oneCache, props, su, tabBarHidden, viewCaches, withoutTitleViewCaches, _ref;
    su = Corefw.util.Startup;
    evt = Corefw.util.Event;
    cm = Corefw.util.Common;
    cache = this.cache;
    props = cache._myProperties;
    config = {
      title: props.title,
      uniqueKey: props.uniqueKey,
      uipath: props.uipath,
      border: 1,
      hidden: !props.visible,
      disabled: !props.enabled
    };
    if (props.title) {
      errArray = (_ref = props.messages) != null ? _ref.ERROR : void 0;
      config.title = props.title + (errArray && errArray.length ? "<span style=\"color:#f00;\">(" + errArray.length + ")</span>" : "");
    } else {
      config.header = false;
    }
    if (props.toolTip) {
      config.tabConfig = {
        tooltip: props.toolTip + '\n<br>'
      };
    }
    if (props.hideBorder) {
      config.border = false;
    }
    if (props.closable) {
      config.closable = true;
    }
    evt.addEvents(props, 'perspective', config);
    evt.addHeartBeats(props, 'perspective');
    cm.setThemeByGlobalVariable(su.getApplicationName(), props.uniqueKey, config);
    if (!su.useClassicTheme()) {
      config.ui = 'tabnavigator';
    }
    if (su.getThemeVersion()) {
      config.ui = 'secondary-tabs-views';
      config.plain = false;
    }
    if (this.hasSubnavViews()) {
      props.hasSubnavViews = true;
    }
    viewCaches = [];
    for (key in cache) {
      oneCache = cache[key];
      if (key !== '_myProperties' && oneCache._myProperties.coretype === 'view' && oneCache._myProperties.visible) {
        viewCaches.push(oneCache);
      }
    }
    withoutTitleViewCaches = viewCaches.filter(function(cache) {
      return Ext.isEmpty(cache._myProperties.title);
    });
    tabBarHidden = withoutTitleViewCaches.length > 0 && viewCaches.length === withoutTitleViewCaches.length;
    config.tabBar = {
      hidden: tabBarHidden,
      style: 'margin-left: -2px;'
    };
    if (su.getThemeVersion() === 2) {
      config.tabBar.style = 'margin-left: 0px;';
      config.plugins = {
        ptype: 'topTabPanelMenu'
      };
    }
    Ext.apply(this, config);
    if (this.tab) {
      this.tab.coreperspective = this;
    }
    Corefw.customapp.Main.mainEntry('perspectiveInit', this);
    this.addListeners();
    this.callParent(arguments);
  },
  addListeners: function() {
    var additionalListeners;
    this.listeners = this.listeners || {};
    additionalListeners = {
      close: this.onPerspectiveClose,
      beforedestroy: this.beforePerspectiveDestroy,
      activate: this.activatePerspective,
      deactivate: this.deactivatePerspective
    };
    return Ext.apply(this.listeners, additionalListeners);
  },
  onPerspectiveClose: function() {
    var iv, uipath;
    iv = Corefw.util.InternalVar;
    uipath = this.cache._myProperties.uipath;
    iv.deleteByUipathCascade(uipath);
  },
  beforePerspectiveDestroy: function() {
    this.onPerspectiveDestroy();
  },
  activatePerspective: function() {
    this.onPerspectiveActive();
  },
  deactivatePerspective: function() {
    this.onPerspectiveDeactive();
  },
  onRender: function() {
    var evt;
    evt = Corefw.util.Event;
    this.callParent(arguments);
    if (this.perspectiveONLOADevent || this.perspectiveONREFRESHevent) {
      evt.fireRenderEvent(this);
    }
  },
  afterRender: function() {
    var evt, me, perspectiveReEnable, rdr, tabpanel, _ref;
    this.callParent(arguments);
    rdr = Corefw.util.Render;
    evt = Corefw.util.Event;
    evt.enableUEvent(this.uipath, 'ONCLOSE');
    me = this;
    if (!me.title) {
      me.tab.hide();
      tabpanel = me.up('tabpanel');
      if (tabpanel) {
        tabpanel.tabBar.hide();
      }
    } else {
      rdr.loadErrors(me.tab, (_ref = me.cache) != null ? _ref._myProperties : void 0);
    }
    perspectiveReEnable = Ext.Function.createDelayed(function() {
      evt.enableUEvent(me.uipath, 'ONCLOSE');
    }, 10000);
    perspectiveReEnable();
  },
  getActiveStatus: function() {
    var parentComponent;
    parentComponent = Ext.ComponentQuery.query('toptabpanel')[0];
    return (parentComponent != null ? parentComponent.getActiveTab() : void 0) === this;
  },
  generatePostData: function() {
    var compArray, postData, props, toolbarComp, toolbarPostData, viewComp, viewPostArray, viewPostData, _i, _len;
    props = this.cache._myProperties;
    viewPostArray = [];
    postData = {
      name: props.uniqueKey,
      allContents: viewPostArray,
      active: this.getActiveStatus()
    };
    compArray = this.query('[coretype=view]');
    for (_i = 0, _len = compArray.length; _i < _len; _i++) {
      viewComp = compArray[_i];
      if (viewComp.cache._myProperties.popup) {
        continue;
      }
      viewPostData = viewComp.generatePostData();
      viewPostArray.push(viewPostData);
    }
    toolbarComp = this.down('coretoolbar');
    if (toolbarComp) {
      toolbarPostData = toolbarComp.generatePostData();
      postData.toolbar = toolbarPostData;
    } else {
      toolbarComp = this.down('corecomplextoolbar');
      if (toolbarComp) {
        toolbarPostData = toolbarComp.generatePostData();
        postData.toolbar = toolbarPostData;
      }
    }
    return postData;
  },
  addToolbar: function(toolbarCache) {
    this.addToolbarNew(toolbarCache, null);
  },
  addNavs: function(props) {
    var rdr;
    rdr = Corefw.util.Render;
    rdr.renderNavs(props, this, null, this.toolbarConfig);
  },
  addToolbarAndViews: function() {
    var cache, comp, hasToolbar, key, oneCache, oneProps, props;
    cache = this.cache;
    props = cache._myProperties;
    this.selectedActiveTab = 0;
    hasToolbar = false;
    for (key in cache) {
      oneCache = cache[key];
      oneProps = oneCache._myProperties;
      if (key !== '_myProperties' && !(oneProps != null ? oneProps.isRemovedFromUI : void 0) && (oneProps != null ? oneProps.visible : void 0)) {
        if (oneProps.coretype === 'view') {
          if (!oneProps.popup) {
            if (oneProps.workflowType) {
              oneCache._myProperties.workflowType = true;
            }
            comp = this.addOneView(oneCache);
            if (oneProps.active) {
              this.selectedActiveTab = comp;
            }
          }
        } else if (oneProps.coretype === 'toolbar') {
          this.addToolbar(oneCache);
          hasToolbar = true;
        }
      }
    }
    if (!hasToolbar) {
      this.addNavs(props);
    }
    if (typeof this.activeTab === 'undefined' || this.activeTab === null) {
      this.setActiveTab(this.selectedActiveTab);
    }
    if (typeof this.createOrUpdateProgressIndicator === "function") {
      this.createOrUpdateProgressIndicator();
    }
  }
});
