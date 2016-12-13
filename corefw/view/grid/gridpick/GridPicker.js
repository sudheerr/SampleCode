// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.gridpick.GridPicker', {
  extend: 'Ext.form.field.ComboBox',
  xtype: 'coregridpicker',
  cls: 'gridpicker',
  minChars: 2,
  editable: false,
  firstLookup: true,
  queryMode: 'local',
  checkChangeBuffer: 500,
  initComponent: function() {
    var cm, me, props, su;
    me = this;
    su = Corefw.util.Startup;
    me.listeners = me.listeners || {};
    Ext.apply(me.listeners, this.addListeners);
    props = me.cache._myProperties;
    if (Corefw.view.form.field.ComboboxField.isLookupable(props)) {
      me.addCls('citiriskLookup');
      me.setHideTrigger(true);
    }
    me.setEditable(Corefw.view.form.field.ComboboxField.isEditable(props));
    cm = Corefw.util.Common;
    me.callParent(arguments);
    me.setRawValue(cm.getDisplayValue(props));
    me.postValue = cm.getValue(props);
    me.coretype = 'corefield';
    if (su.getThemeVersion() === 2) {
      if (!props.lookupable) {
        me.fieldStyle = {
          borderRightWidth: '0px'
        };
        this.triggerBaseCls = 'formtriggericon';
        this.triggerCls = 'combotrig';
      }
    }
  },
  addListeners: {
    blur: function(me, e) {
      var _ref;
      if ((_ref = me.gridwindow) != null ? _ref.el.dom.contains(e.target) : void 0) {
        return false;
      }
    },
    change: function(me, newVal, oldVal) {
      if (this.selChanging) {
        delete this.selChanging;
        return;
      }
      if (this.isLookupable()) {
        delete this.postValue;
        this.loadData(newVal);
      }
    },
    focus: function(me) {
      var lookup;
      if (!this.inited) {
        this.initGridwindow();
      } else if (this.gridwindow.isHidden()) {
        if (this.firstLookup) {
          lookup = '';
          this.firstLookup = false;
        } else {
          lookup = this.getRawValue();
        }
        this.loadData(lookup, function() {
          me.showGridWindow();
        });
      }
    },
    resize: function(me, width, height, oldWidth, oldHeight) {
      if (me.gridwindow && !me.gridwindow.isHidden()) {
        me.showGridWindow();
      }
    }
  },
  initGridwindow: function() {
    var me, props;
    me = this;
    props = this.cache._myProperties;
    this.gridwindow = Ext.create('Corefw.view.grid.gridpick.GridPickerWindow', {
      parentField: me,
      multiSelect: props.multiSelect
    });
    this.gridwindow.hide();
    this.loadData("", function() {
      me.showGridWindow();
    });
    this.inited = true;
  },
  setPickValue: function(val) {
    var cm, displayValue, value;
    cm = Corefw.util.Common;
    displayValue = cm.getDisplayValue(val);
    value = cm.getValue(val);
    this.setRawValue(displayValue);
    this.postValue = value;
  },
  setValue: function(val) {},
  loadData: function(searchString, callbackFn) {
    var callback, me, props, rq, url, win;
    if (!searchString) {
      searchString = '';
    }
    rq = Corefw.util.Request;
    props = this.cache._myProperties;
    me = this;
    win = me.gridwindow;
    if (!win) {
      return;
    }
    if (this.isLookupable()) {
      callback = function(respObj) {
        if (!me.isVisible()) {
          return;
        }
        win.showData(respObj);
        win.setSelectedValue(me.postValue);
        if (callbackFn) {
          callbackFn();
        }
      };
      url = rq.objsToUrl3(this.eventURLs['ONLOOKUP'], null, searchString);
      rq.sendRequest5(url, callback, this.uipath);
    } else {
      win = this.gridwindow;
      if (!this.inited) {
        win.showData(props);
      }
      win.setSelectedValue(this.postValue);
      if (callbackFn) {
        callbackFn();
      }
    }
  },
  getPostValue: function() {
    if (this.postValue === void 0) {
      return this.getRawValue();
    } else {
      return this.postValue;
    }
  },
  hideGridWindow: function() {
    this.gridwindow.hide();
    this.firstLookup = true;
  },
  showGridWindow: function() {
    var me, win;
    me = this;
    win = me.gridwindow;
    win.show();
  },
  isLookupable: function() {
    var _ref;
    return (Corefw.view.form.field.ComboboxField.isLookupable(this)) || (Corefw.view.form.field.ComboboxField.isLookupable((_ref = this.cache) != null ? _ref._myProperties : void 0));
  },
  isEditable: function() {
    var _ref;
    return (Corefw.view.form.field.ComboboxField.isEditable(this)) || (Corefw.view.form.field.ComboboxField.isEditable((_ref = this.cache) != null ? _ref._myProperties : void 0));
  },
  onDestroy: function() {
    this.callParent(arguments);
    if (this.gridwindow) {
      this.gridwindow.destroy();
      delete this.gridwindow;
    }
    delete this.inited;
  },
  generatePostData: function() {
    var displayValue, fieldObj, value;
    value = this.postValue;
    displayValue = this.getRawValue();
    fieldObj = {
      name: this.name,
      value: Ext.isEmpty(value) ? "" : value,
      displayValue: Ext.isEmpty(displayValue) ? "" : displayValue
    };
    return fieldObj;
  }
});