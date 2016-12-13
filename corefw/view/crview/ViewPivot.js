// Generated by CoffeeScript 1.8.0
var __slice = [].slice;

Ext.define('Corefw.view.crview.ViewPivot', {
  extend: 'Ext.container.Container',
  xtype: 'coreviewpivot',
  componentCls: 'cv-viewpivot',
  mixins: ['Corefw.mixin.Sharable'],
  layout: 'border',
  eventURLs: [],
  timeMarks: null,
  listeners: {
    afterrender: function() {
      Ext.Ajax.request({
        url: 'api/pivot/globalConfig',
        method: 'POST',
        scope: this,
        params: {
          uipath: this.uipath
        },
        success: function(response) {
          var responseJson;
          responseJson = Ext.decode(response.responseText);
          return this.updateShared(responseJson);
        }
      });
      return this.down('domainnavpanel').down('filterCriteriaView').store.on({
        refresh: function(store) {
          return this.updateShared('globalFilter', store.getCriteria());
        },
        remove: function(store) {
          return this.updateShared('globalFilter', store.getCriteria());
        },
        scope: this
      });
    }
  },
  initComponent: function() {
    Corefw.util.Common.copyObjProperties(this, this.cache._myProperties, ['domainName', 'uipath']);
    this.callParent(arguments);
    return this.updateShared({
      'domainName': this.domainName,
      'reqTimeMarks': this.reqTimeMarks.bind(this)
    });
  },
  updateUIData: function(viewCache) {
    this.domainName = viewCache._myProperties.domainName;
    return this.updateShared('domainName', this.domainName);
  },
  reqTimeMarks: function() {
    var args, cb, scope;
    cb = arguments[0], scope = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (scope == null) {
      scope = this;
    }
    if (this.timeMarks) {
      return cb.apply(scope, [this.timeMarks].concat(args));
    } else {
      return Ext.Ajax.request({
        url: 'api/pivot/timeMark',
        method: 'POST',
        scope: this,
        params: {
          uipath: this.uipath,
          domainName: this.domainName
        },
        success: function(response) {
          this.timeMarks = Ext.decode(response.responseText);
          return cb.apply(scope, [this.timeMarks].concat(args));
        }
      });
    }
  },
  items: [
    {
      xtype: 'domainnavpanel',
      region: 'west',
      collapsible: true,
      split: true,
      width: '14%'
    }, {
      xtype: 'panel',
      region: 'center',
      layout: 'vbox',
      flex: 1,
      height: '100%',
      items: [
        {
          xtype: "pivottablefield",
          layout: 'hbox',
          width: '100%',
          flex: 1
        }
      ]
    }
  ]
});
