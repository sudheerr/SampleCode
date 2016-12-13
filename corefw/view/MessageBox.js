// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.MessageBox', {
  extend: 'Ext.window.MessageBox',
  xtype: 'coremessagebox',
  mixins: [],
  closeAction: 'destroy',
  initComponent: function() {
    var button, cache, cancelButton, config, me, nav, navArray, navs, okButton, okCallback, props, su, _i, _j, _len, _len1, _ref;
    me = this;
    su = Corefw.util.Startup;
    cache = this.cache;
    props = cache._myProperties;
    config = {
      title: props.title,
      msg: props.message,
      hidden: !props.visible,
      disabled: !props.enabled,
      messageType: props.messageType,
      iconWidth: su.getThemeVersion() === 2 ? 48 : void 0
    };
    okButton = false;
    cancelButton = false;
    navs = this.cache._myProperties.navs;
    if (navs) {
      navArray = navs._ar;
      if (navArray && navArray.length) {
        for (_i = 0, _len = navArray.length; _i < _len; _i++) {
          nav = navArray[_i];
          if (nav.name === 'ok') {
            okButton = true;
            Ext.MessageBox.buttonText.ok = nav.title;
          } else if (nav.name === 'cancel') {
            cancelButton = true;
            Ext.MessageBox.buttonText.cancel = nav.title;
          }
        }
      }
    }
    if (okButton && cancelButton) {
      config.buttons = Ext.Msg.OKCANCEL;
    } else if (okButton && !cancelButton) {
      config.buttons = Ext.Msg.OK;
    } else if (!okButton && cancelButton) {
      config.buttons = Ext.Msg.CANCEL;
    } else {
      config.buttons = Ext.Msg.OKCANCEL;
    }
    okCallback = this.okCallback;
    config.fn = function(btn) {
      if (btn === 'ok') {
        if (okCallback) {
          okCallback();
        } else {
          me.triggerOKEvent();
        }
      } else if (btn === 'cancel') {
        me.triggerCancelEvent();
      }
    };
    switch (props.messageType) {
      case 'INFORMATION':
        config.icon = Ext.Msg.INFO;
        break;
      case 'WARNING':
        config.icon = Ext.Msg.WARNING;
        break;
      case 'ERROR':
        config.icon = Ext.Msg.ERROR;
        break;
      case 'CONFIRM':
        config.icon = Ext.Msg.QUESTION;
        break;
      default:
        config.icon = Ext.Msg.INFO;
    }
    Ext.apply(this.uipath, props.uipath);
    this.callParent(arguments);
    if (su.getThemeVersion() === 2) {
      _ref = me.msgButtons;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        button = _ref[_j];
        button.minWidth = 60;
        button.height = 28;
      }
      me.topContainer.padding = '15';
    }
    this.show(config);
    console.log('MESSAGE_BOX: ', this);
    if (su.getThemeVersion() === 2) {
      this.addtools(this.tools);
    }
  },
  findAllNavs: function() {
    var navArray, navs;
    navs = this.cache._myProperties.navs;
    if (!navs) {
      return;
    }
    return navArray = navs._ar;
  },
  findNavFromCache: function(navName) {
    var nav, navArray, _i, _len;
    navArray = this.findAllNavs();
    if (!navArray || !navArray.length) {
      return;
    }
    for (_i = 0, _len = navArray.length; _i < _len; _i++) {
      nav = navArray[_i];
      if (nav.name === navName) {
        return nav;
      }
    }
  },
  triggerOKEvent: function() {
    this.triggerEvent('ok');
  },
  triggerCancelEvent: function() {
    this.triggerEvent('cancel');
  },
  triggerEvent: function(buttonLabel) {
    var cm, nav, parentComp, postData, rq, uip, url;
    cm = Corefw.util.Common;
    rq = Corefw.util.Request;
    uip = Corefw.util.Uipath;
    nav = this.findNavFromCache(buttonLabel);
    if (nav && nav.events && nav.events._ar) {
      if (nav.events['ONCLICK']) {
        url = rq.objsToUrl3(nav.events['ONCLICK'].url);
        parentComp = uip.uipathToParentComponent(this.cache._myProperties.uipath);
        if ((parentComp != null) && parentComp !== void 0) {
          postData = parentComp.generatePostData();
          rq.sendRequest5(url, rq.processResponseObject, this.cache._myProperties.uipath, postData);
        } else {
          rq.sendRequest5(url, rq.processResponseObject, this.cache._myProperties.uipath, void 0);
        }
      } else if (nav.events['ONDOWNLOAD']) {
        this.processFile(Ext.ComponentQuery.query('[uipath=' + this.triggerUipath + ']:last')[0], rq.objsToUrl3(nav.events['ONDOWNLOAD'].url), cm.download);
      } else if (nav.events['ONREDIRECT']) {
        this.processFile(Ext.ComponentQuery.query('[uipath=' + this.triggerUipath + ']:last')[0], rq.objsToUrl3(nav.events['ONREDIRECT'].url), cm.redirect);
      }
    }
  },
  afterHide: function() {
    this.callParent(arguments);
    this.destroy();
  },
  addtools: function(tools) {
    var tool, _i, _len;
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      tool = tools[_i];
      if (tool.type === 'close') {
        tool.addCls("" + Ext.baseCSSPrefix + "window-close-btn");
        tool.setWidth(18);
        tool.setHeight(18);
      }
    }
  },
  processFile: function(button, url, func) {
    var cm, comp, parentCache, props, searchXtype, uip, uipath;
    cm = Corefw.util.Common;
    uip = Corefw.util.Uipath;
    uipath = button.uipath;
    parentCache = uip.uipathToParentCacheItem(uipath);
    props = parentCache._myProperties;
    searchXtype = cm.getSearchXtypeForDownload(props);
    if (searchXtype) {
      comp = button.up(searchXtype);
      if (!comp) {
        if (props.widgetType === 'TOOLBAR') {
          comp = uip.uipathToPostContainer(uipath);
        } else {
          comp = uip.uipathToComponent(button.uipath);
        }
      }
      func.call(cm, comp, url);
    }
  }
});
