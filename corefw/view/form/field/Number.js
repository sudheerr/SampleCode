// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.field.Number', {
  extend: 'Ext.form.field.Number',
  mixins: ['Corefw.mixin.CoreField'],
  xtype: 'corenumberfield',
  decimalSeparator: '.',
  baseChars: '0123456789',
  allowedCharsRe: /[-\d.]/g,
  allowedPseudoClassRe: /^abs:/,
  negativeSymbolRe: /^[-]/,
  nanText: '{0} is not a valid number',
  autoStripChars: false,
  decimalPrecision: 5,
  allowDecimals: true,
  enableKeyEvents: true,
  initComponent: function() {
    this.callParent(arguments);
    this.initializeField();
  },
  initValueFloatingLabel: function() {
    var id, me, valueLabel;
    me = this;
    id = me.id + 'floating-label';
    valueLabel = Ext.getCmp(id);
    if (!valueLabel) {
      valueLabel = Ext.create('Ext.form.Label', {
        id: id,
        hidden: true,
        shadow: false,
        floating: true,
        renderTo: Ext.getBody(),
        margin: '0 0 0 0',
        style: {
          'padding-top': '0.1%',
          'padding-left': '4px',
          'background-color': '#dae7f6',
          border: '1px solid rgb(154, 193, 239)'
        }
      });
      valueLabel.el.setZIndex(1900000);
    }
    me.valueLabel = valueLabel;
    if (me.value) {
      me.valueLabel.setText(me.formatValue(me.value));
    }
  },
  adjustValueFloatingLabel: function() {
    var me, valueLabel;
    me = this;
    if (me.valueLabel) {
      valueLabel = me.valueLabel;
      valueLabel.el.setXY([me.inputEl.getX(), me.inputEl.getY() + me.inputEl.getHeight()]);
      valueLabel.el.setWidth(me.inputEl.getWidth() + me.spinUpEl.getWidth());
      valueLabel.el.setHeight(me.inputEl.getHeight());
    }
  },
  initializeField: function(value) {
    var allowed, me, props, su;
    me = this;
    su = Corefw.util.Startup;
    if (me.minValue === void 0) {
      me.minValue = Ext.Number.from(value, Number.NEGATIVE_INFINITY);
    }
    if (me.maxValue === void 0) {
      me.maxValue = Ext.Number.from(value, Number.MAX_VALUE);
    }
    allowed = this.baseChars + this.decimalSeparator + '-';
    allowed = Ext.String.escapeRegex(allowed);
    me.maskRe = new RegExp("[" + allowed + "]");
    if (!me.cache) {
      me.cache = me.column.cache;
    }
    props = me.cache._myProperties;
    me.parsePseudoClass();
    if (su.getThemeVersion() === 2 && props.readOnly !== true) {
      me.fieldStyle = {
        borderRightWidth: '0px'
      };
    }
  },
  listeners: {
    boxready: function(comp, width, height) {
      return comp.format && comp.initValueFloatingLabel();
    },
    focus: function(comp, ev) {
      var value, valueLabel;
      value = comp.getValue();
      comp.adjustValueFloatingLabel();
      comp.setRawValue(comp.getValue());
      comp.editing = true;
      if (comp.format && (valueLabel = comp.valueLabel)) {
        comp.updateValueLabel(value);
        valueLabel.el.dom.style.visibility = '';
      }
    },
    blur: function(comp) {
      var _ref;
      comp.editing = false;
      if (comp.format) {
        if ((_ref = comp.valueLabel) != null) {
          _ref.el.hide();
        }
        comp.setRawValue(comp.formatValue(comp.getValue()));
      }
    },
    change: function(comp, newValue, oldValue) {
      var _ref;
      if (comp.hasOwnProperty('minValue')) {
        if (newValue < comp.minValue && comp.minValue === 0) {
          newValue = Math.abs(newValue);
          comp.setValue(newValue);
        }
      }
      return comp.format && ((_ref = comp.valueLabel) != null ? _ref.setText(comp.formatValue(newValue)) : void 0);
    },
    destroy: function() {
      var _ref;
      return (_ref = this.valueLabel) != null ? _ref.destroy() : void 0;
    },
    specialkey: function(comp, e) {
      var key, valueLabel;
      key = e.getKey();
      if (comp.format && (valueLabel = comp.valueLabel) && (key === e.TAB || key === e.ENTER)) {
        return valueLabel.el.hide();
      }
    }
  },
  setSpinValue: function(value) {
    this.isSpinValue = true;
    this.callParent(arguments);
    return delete this.isSpinValue;
  },
  setValue: function(value) {
    this.callParent(arguments);
    this.updateValueLabel(value);
  },
  updateValueLabel: function(value) {
    var valueLabel;
    if (this.format && (valueLabel = this.valueLabel)) {
      valueLabel.setText(this.formatValue(value));
    }
  },
  formatValue: function(value) {
    if (this.format) {
      if (this.isAbsOnly) {
        value = Math.abs(value);
      }
      return Ext.util.Format.number(value, this.format);
    }
    return value;
  },
  valueToRaw: function() {
    var rawValue;
    rawValue = this.callParent(arguments);
    if (!this.isSpinValue && !this.editing) {
      return this.formatValue(rawValue);
    } else {
      return rawValue;
    }
  },
  fixPrecision: function(value) {
    var expandedValue, me, nan, precision, roundValue;
    me = this;
    nan = isNaN(value);
    precision = me.decimalPrecision;
    if (nan || !value) {
      return (nan ? '' : value);
    } else {
      if (!me.allowDecimals || precision <= 0) {
        precision = 0;
      }
    }
    expandedValue = parseFloat(value) * Math.pow(10, precision);
    roundValue = Math.round(expandedValue);
    return parseFloat(Ext.Number.toFixed(roundValue / Math.pow(10, precision), precision));
  },
  parsePseudoClass: function() {
    var allowedPseudoClassRe, format, matchedClasses, me, pClass, _i, _len;
    if (!this.format) {
      return;
    }
    me = this;
    format = me.format;
    allowedPseudoClassRe = me.allowedPseudoClassRe;
    matchedClasses = format.match(allowedPseudoClassRe);
    if (!matchedClasses) {
      return;
    }
    for (_i = 0, _len = matchedClasses.length; _i < _len; _i++) {
      pClass = matchedClasses[_i];
      if (pClass === 'abs:') {
        me.isAbsOnly = true;
      }
    }
    me.format = format.replace(allowedPseudoClassRe, '');
  },
  parseValue: function(value) {
    var matchedValues;
    if (value === -0 || value === '-0') {
      return -0;
    }
    matchedValues = String(value).match(this.allowedCharsRe);
    if (!matchedValues) {
      return null;
    }
    value = parseFloat(matchedValues.join(''));
    if (isNaN(value)) {
      return null;
    } else {
      return this.fixPrecision(value);
    }
  },
  parseValueAsStr: function(value) {
    value = this.parseValue(value);
    if (!value) {
      return '';
    } else {
      return String(value);
    }
  },
  getErrors: function(value) {
    var errors, format, me, num;
    me = this;
    value = (this.parseValue(value)) || 0;
    value = String(value).replace(me.decimalSeparator, '.');
    arguments[0] = value;
    errors = me.callParent(arguments);
    format = Ext.String.format;
    value = (Ext.isDefined(value) ? value : this.processRawValue(this.getRawValue()));
    if (!value || value.length < 1) {
      return errors;
    }
    num = me.parseValue(value);
    if (me.minValue === 0 && num < 0) {
      errors.push(this.negativeText);
    } else {
      if (num < me.minValue) {
        errors.push(format(me.minText, me.minValue));
      }
    }
    if (num > me.maxValue) {
      errors.push(format(me.maxText, me.maxValue));
    }
    return errors;
  },
  getRawValue: function() {
    var rawValue;
    rawValue = this.callParent(arguments);
    if (!this.rendered || (Ext.isEmpty(rawValue)) || (this.format && this.editing) || Ext.isNumber(Ext.Number.from(rawValue))) {
      return rawValue;
    } else {
      return this.value;
    }
  }
});
