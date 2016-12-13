// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.field.DropDownField', {
  extend: 'Ext.form.field.ComboBox',
  mixins: ['Corefw.mixin.CoreField'],
  xtype: 'coredropdownfield',
  queryMode: 'local',
  editable: false,
  forceSelection: true,
  displayField: 'displayValue',
  valueField: 'value',
  enableKeyEvents: false,
  queryCache: [],
  listConfig: {
    style: {
      whiteSpace: 'nowrap'
    }
  },
  initComponent: function() {
    var fieldProps;
    fieldProps = this.cache._myProperties;
    this.applyConfig(fieldProps);
    this.configureTriggers();
    this.applyStore(fieldProps);
    return this.callParent(arguments);
  },
  applyConfig: function(fieldProps) {
    var config, su;
    config = {
      name: fieldProps.name,
      emptyText: fieldProps.emptyText,
      multiSelect: fieldProps.multiSelect,
      autoSelect: !fieldProps.multiSelect,
      uipath: fieldProps.uipath,
      value: fieldProps.value,
      fieldLabel: fieldProps.title,
      readOnly: fieldProps.readOnly,
      disabled: fieldProps.disabled,
      historyInfo: fieldProps.historyInfo,
      hideTrigger: fieldProps.readOnly,
      listeners: {}
    };
    if (!this.editable) {
      su = Corefw.util.Startup;
      if (su.getThemeVersion() === 2) {
        config.triggerBaseCls = 'formtriggericon';
        config.triggerCls = 'combotrig';
        config.height = 26;
        config.fieldStyle = {
          borderRightWidth: '0px'
        };
      }
      config.listeners.keydown = this.onKeyDownEvent;
      config.listeners.change = this.onChangeEvent;
    }
    return Ext.merge(this, config);
  },
  applyStore: function(fieldProps) {
    var st, validValues;
    validValues = fieldProps.validValues;
    if (!validValues.length && fieldProps.hasOwnProperty('displayValue')) {
      validValues = validValues.concat({
        displayValue: fieldProps.displayValue,
        value: fieldProps.value
      });
    }
    st = this.createStore(fieldProps.uipath, validValues);
    return st && (this.store = st);
  },
  afterRender: function() {
    var _ref;
    this.callParent(arguments);
    return (_ref = this.triggerEl.elements[1]) != null ? _ref.hide() : void 0;
  },
  onKeyDownEvent: function(_, e) {
    var q;
    if (e.keyCode < 31) {
      return;
    }
    this.queryCache.push(String.fromCharCode(e.keyCode));
    q = this.queryCache.join('');
    if (this.triggerAction === 'all') {
      this.doQuery(q, true);
    } else if (this.triggerAction === 'last') {
      this.doQuery(q, true);
    } else {
      this.doQuery(q, false, true);
    }
  },
  onTriggerClick: function() {
    this.callParent(arguments);
    return this.queryCache = [];
  },
  onClearClick: function() {
    if (this.readOnly || this.disabled) {
      return;
    }
    this.clearValue();
    this.triggerEl.elements[1].hide();
    this.updateLayout();
    this.fireEvent('clear', this);
    return this.queryCache = [];
  },
  configureTriggers: function() {
    var baseCSSPrefix, version;
    version = Ext.getVersion().major;
    baseCSSPrefix = Ext.baseCSSPrefix;
    if (version === 4) {
      this.trigger1Cls = baseCSSPrefix + 'form-arrow-trigger';
      this.onTrigger1Click = function() {
        return this.onTriggerClick();
      };
      this.trigger2Cls = baseCSSPrefix + 'form-clear-trigger';
      return this.onTrigger2Click = this.onClearClick;
    } else if (version > 4) {
      return this.triggers = {
        clear: {
          weight: 1,
          cls: Ext.baseCSSPrefix + 'form-clear-trigger',
          hidden: true,
          handler: 'onClearClick',
          scope: 'this'
        },
        picker: {
          weight: 2,
          handler: 'onTriggerClick',
          scope: 'this'
        }
      };
    }
  },
  createStore: function(id, data) {
    var dropDown, storeConfig;
    if (data == null) {
      data = [];
    }
    if (data.length === 0) {
      return null;
    }
    dropDown = this;
    storeConfig = {
      fields: [dropDown.displayField, dropDown.valueField],
      data: data,
      id: id
    };
    return Ext.create('Ext.data.Store', storeConfig);
  },
  onChangeEvent: function() {
    var clearTrigger;
    clearTrigger = this.triggerEl.elements[1];
    if (Ext.isEmpty(this.value)) {
      clearTrigger.hide();
    } else {
      clearTrigger.show();
    }
  },
  updateValue: function() {
    var selectedRecords;
    selectedRecords = this.valueCollection.getRange();
    this.callParent();
    if (selectedRecords.length > 0) {
      this.getTrigger('clear').show();
      this.updateLayout();
    }
  },
  setValue: function(value) {
    var me;
    if (!Ext.isEmpty(value)) {
      me = this;
      if (!me.isRecord(value)) {
        if (!Ext.isArray(value)) {
          arguments[0] = me.parseValue(value);
        } else {
          arguments[0] = value.map(function(v) {
            if (me.isRecord(v)) {
              return v;
            } else {
              return me.parseValue(v);
            }
          });
        }
      }
    }
    return this.callParent(arguments);
  },
  isRecord: function(v) {
    return v.hasOwnProperty('store');
  },
  parseValue: function(v) {
    if (Ext.isObject(v)) {
      return v[this.valueField] || v.value;
    } else {
      return v;
    }
  },
  bindStore: function(store) {
    var historyValues, _ref;
    this.callParent(arguments);
    if (store) {
      historyValues = (_ref = this.historyInfo) != null ? _ref.historyValues : void 0;
      this.addHistoryData(historyValues, true);
    }
  },
  bindData: function(dropdownValues) {
    dropdownValues = Ext.Array.from(dropdownValues);
    if (dropdownValues.length === 0) {
      return false;
    }
    this.getStore().loadData(Ext.Array.from(dropdownValues));
    return true;
  },
  addHistoryData: function(data, isRemoveRepeat) {
    var datas, dropdown, store, valueField;
    datas = Ext.Array.from(data);
    if (!datas.length) {
      return false;
    }
    dropdown = this;
    store = dropdown.getStore();
    valueField = dropdown.valueField;
    if (isRemoveRepeat) {
      store.each(function(record) {
        var d, i, storeVal, _i, _len;
        if (record.raw.isHistory) {
          storeVal = record.get(valueField);
          for (i = _i = 0, _len = datas.length; _i < _len; i = ++_i) {
            d = datas[i];
            if (storeVal === d[valueField]) {
              store.removeAt(i);
              return;
            }
          }
        }
      });
    }
    datas.forEach(function(d) {
      return d.isHistory = true;
    });
    store.loadData(datas, true);
    return true;
  },
  getDisplayValue: function() {
    var displayValue;
    displayValue = this.callParent(arguments);
    return Ext.htmlDecode(displayValue);
  },
  generatePostData: function() {
    var displayValue, value;
    value = this.getValue();
    displayValue = this.getRawValue();
    return {
      name: this.name,
      value: Ext.isEmpty(value) ? "" : value,
      displayValue: Ext.isEmpty(displayValue) ? "" : displayValue
    };
  }
});