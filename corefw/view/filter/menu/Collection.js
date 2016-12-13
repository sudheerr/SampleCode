// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.filter.menu.Collection', {
  extend: 'Corefw.view.component.MenuWin',
  alias: 'widget.filterMenuCollection',
  requires: ['Corefw.view.component.TextLookup'],
  width: 180,
  plain: true,
  config: {
    filterPath: '',
    itemName: '',
    repetitiveRatio: -1
  },
  title: '',
  items: [
    {
      xtype: 'combo',
      name: 'firstOperationCombo',
      queryMode: 'local',
      displayField: 'desc',
      editable: false,
      selectOnFocus: false,
      hideLabel: true,
      value: 'exists any',
      valueField: 'operation',
      store: Ext.create('Ext.data.Store', {
        fields: ['operation', 'desc'],
        data: [
          {
            'operation': 'existsAny',
            'desc': 'Exists Any'
          }, {
            'operation': 'existsAll',
            'desc': 'Exists All'
          }
        ]
      }),
      listeners: {
        change: function(combo, records, eOpts) {
          var cb, menu;
          menu = combo.up('filterMenuCollection');
          cb = menu.query('combo[name=secondOperationCombo]')[0];
          cb.show();
          cb.select('eq');
        }
      }
    }, {
      xtype: 'combo',
      name: 'secondOperationCombo',
      queryMode: 'local',
      displayField: 'desc',
      editable: false,
      selectOnFocus: false,
      hideLabel: true,
      value: 'eq',
      valueField: 'operation',
      store: Ext.create('Ext.data.Store', {
        fields: ['operation', 'desc'],
        data: [
          {
            'operation': 'eq',
            'desc': 'Equals'
          }, {
            'operation': 'ne',
            'desc': 'Not Equals'
          }, {
            'operation': 'like',
            'desc': 'Like'
          }, {
            'operation': 'notLike',
            'desc': 'Not Like'
          }, {
            'operation': 'isNull',
            'desc': 'IsNull'
          }, {
            'operation': 'isNotNull',
            'desc': 'IsNotNull'
          }, {
            'operation': 'isNullOrEmpty',
            'desc': 'IsNullOrEmpty'
          }, {
            'operation': 'isNotNullOrEmpty',
            'desc': 'IsNotNullOrEmpty'
          }, {
            'operation': 'in',
            'desc': 'In'
          }, {
            'operation': 'notIn',
            'desc': 'Not In'
          }
        ]
      }),
      listeners: {
        change: function(combo, records, eOpts) {
          var cb1, criteriaPanel, menu, tbIn;
          menu = combo.up('filterMenuCollection');
          cb1 = menu.query('combo[name=comboTextNormal]')[0];
          tbIn = menu.down('[name=toolbarIn]');
          criteriaPanel = menu.down('[name=criteriaPanel]');
          if (combo.getValue() === 'in' || combo.getValue() === 'notIn') {
            tbIn.show();
            criteriaPanel.show();
            cb1.hide();
          } else {
            tbIn.hide();
            criteriaPanel.hide();
            cb1.show();
            cb1.reset();
            cb1.getStore().removeAll();
            if (CorefwFilterModel.operandNumber(combo.getValue()) === 0) {
              cb1.hide();
              tbIn.hide();
            } else if (combo.getValue() === 'like') {
              Ext.apply(cb1, {
                queryMode: 'local',
                listConfig: {
                  emptyText: ''
                }
              });
            } else {
              Ext.apply(cb1, {
                queryMode: 'remote',
                listConfig: {
                  emptyText: 'No matching data found.'
                }
              });
            }
          }
        }
      }
    }, {
      name: 'comboTextNormal',
      xtype: 'textLookup'
    }, {
      xtype: 'toolbar',
      layout: 'hbox',
      isFormField: true,
      cls: 'formField',
      name: 'toolbarIn',
      hidden: true,
      items: [
        {
          xtype: 'textLookup',
          name: 'comboTextIn',
          flex: 1
        }, {
          xtype: 'button',
          text: '',
          cls: 'addIcon',
          height: 22,
          handler: function() {
            var criteriaPanel, inputValue, menu, textinputField;
            textinputField = Ext.getCmp(this.id).up('toolbar').down('textLookup');
            menu = textinputField.up('filterMenuCollection');
            inputValue = textinputField.getValue();
            criteriaPanel = menu.down('[name=criteriaPanel]');
            if (inputValue && inputValue !== void 0 && inputValue !== '') {
              if (inputValue.indexOf(';') > -1 || inputValue.indexOf(',') > -1 || inputValue.indexOf('~') > -1) {
                Corefw.Msg.alert('Alert', 'Please enter a valid value except \',;~\'!');
                return;
              }
              criteriaPanel.addItem(inputValue);
              textinputField.setValue('');
            } else {
              Corefw.Msg.alert('Alert', 'Please enter a valid value');
            }
          }
        }
      ]
    }, {
      xtype: 'simpleList',
      name: 'criteriaPanel',
      hidden: true,
      width: '100%',
      height: 185
    }
  ],
  bbar: [
    {
      xtype: 'button',
      scope: this,
      text: 'Apply',
      width: 55,
      cls: 'primaryBtn',
      handler: function(button, e) {
        var criObj, criteriaPanel, criteriaStore, fOpString, firstMenuCombo, inputValue, menu, opComboBoxStr, opMenuCombo, opMenuCombo2, opString, parentCriObj, path, temp, temp2, triggerOwner;
        menu = button.up('menu');
        path = menu.filterPath;
        parentCriObj = {};
        criObj = {};
        temp = '';
        temp2 = '';
        firstMenuCombo = menu.query('combo[name=firstOperationCombo]')[0];
        opMenuCombo = menu.query('combo[name=comboTextNormal]')[0];
        opComboBoxStr = menu.query('combo[name=secondOperationCombo]')[0];
        opMenuCombo2 = menu.query('combo[name=comboTextIn]')[0];
        criteriaStore = button.up('filterMenuCollection').criteriaStore;
        criteriaPanel = menu.down('[name=criteriaPanel]');
        fOpString = firstMenuCombo.getValue();
        opString = opComboBoxStr.getValue();
        inputValue = opMenuCombo.getValue();
        triggerOwner = menu.triggerOwner || {};
        parentCriObj.pathString = path;
        parentCriObj.operator = fOpString;
        parentCriObj.operandsString = [];
        parentCriObj.disabled = false;
        criObj.pathString = path;
        criObj.itemName = menu.getItemName();
        criObj.operator = opString;
        criObj.operandsString = [];
        criObj.disabled = false;
        if (criObj.operator === 'in' || criObj.operator === 'notIn') {
          criteriaPanel.getItems().forEach(function(value) {
            criObj.operandsString.push(value);
          });
          if (criObj.operandsString.length < 2) {
            opMenuCombo2.onFocus();
            Corefw.Msg.alert('Alert', 'Please add two values at least.');
            return;
          }
        } else if (CorefwFilterModel.operandNumber(criObj.operator) !== 0) {
          if (inputValue === null || inputValue === '') {
            Corefw.Msg.alert('Alert', 'Please enter a value');
            opMenuCombo.focus();
            return;
          } else {
            if (inputValue.indexOf(';') > -1 || inputValue.indexOf(',') > -1 || inputValue.indexOf('~') > -1) {
              Corefw.Msg.alert('Alert', 'Please enter a valid value except \',;~\'!');
              return;
            }
          }
          if ((criObj.operator === 'like' || criObj.operator === 'notLike') && /[*]{2,}/.test(inputValue)) {
            Corefw.Msg.alert('Invalid Filter Value', "Consecutive * is unnecessary and not allowed!");
            return;
          }
          temp = inputValue;
          if (criObj.operator === 'like') {
            if (!Ext.String.endsWith(temp, '*')) {
              temp = temp + '*';
            }
          }
          criObj.operandsString.push(temp);
        }
        criObj.measure = false;
        criObj.dataTypeString = menu.dataTypeString;
        criObj.repetitiveRatio = menu.repetitiveRatio;
        parentCriObj.operandsString.push(criObj);
        criteriaStore.addItemCriteriaStore(parentCriObj, triggerOwner);
        menu.setVisible(false);
      }
    }, '-', {
      xtype: 'button',
      text: 'Cancel',
      width: 55,
      cls: 'secondaryBtn',
      handler: function(button, e) {
        button.up('menu').setVisible(false);
      }
    }
  ],
  listeners: {
    beforeshow: function(m, eOp) {
      var a, itemName;
      itemName = m.getItemName();
      if (itemName) {
        m.setTitle(itemName);
      } else {
        a = m.filterPath.split(':');
        m.setTitle(a[a.length - 1]);
      }
      if (m.triggerOwner) {
        this.changeMenuFilterValue(m.triggerOwner);
      }
    }
  },
  setFilterMenuComboStore: function(menu, pathString, extraParams) {
    var lookup, lookupStore, _i, _len, _ref;
    _ref = menu.query('textLookup');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      lookup = _ref[_i];
      lookupStore = lookup.getStore();
      lookupStore.pathString = pathString;
      if (extraParams) {
        Ext.apply(lookupStore.getProxy().extraParams, extraParams);
      }
    }
  },
  clearMenu: function() {
    var a, b, criteriaPanel;
    a = this.down('combo[name=secondOperationCombo]');
    b = this.down('combo[name=firstOperationCombo]');
    criteriaPanel = this.down('[name=criteriaPanel]');
    b.select('existsAny');
    a.select('eq');
    criteriaPanel.removeAll();
    a = this.down('combo[name=comboTextNormal]');
    a.reset();
    a.lastValue = 'CCQ';
    a.lastQuery = 'YXR';
    a = this.down('combo[name=comboTextIn]');
    a.reset();
    a.lastValue = 'CXA';
    a.lastQuery = 'YKX';
    delete this.triggerOwner;
  },
  changeMenuFilterValue: function(triggerOwner) {
    var criteriaPanel, firstMenuCombo, firstOpr, menu, opComboBoxStr, opMenuCombo, opMenuCombo2, secondOpr, val;
    firstOpr = triggerOwner.data.operator;
    secondOpr = triggerOwner.data.operandsString[0].operator;
    val = triggerOwner.data.operandsString[0].operandsString;
    menu = this;
    firstMenuCombo = menu.query('combo[name=firstOperationCombo]')[0];
    opMenuCombo = menu.query('combo[name=comboTextNormal]')[0];
    opComboBoxStr = menu.query('combo[name=secondOperationCombo]')[0];
    opMenuCombo2 = menu.query('combo[name=comboTextIn]')[0];
    criteriaPanel = menu.query('[name=criteriaPanel]')[0];
    firstMenuCombo.setValue(firstOpr);
    opComboBoxStr.setValue(secondOpr);
    if (secondOpr !== 'in' && secondOpr !== 'notIn') {
      opMenuCombo.setValue(val[0]);
      opMenuCombo2.setValue(val[0]);
    } else {
      val.forEach(function(ele) {
        criteriaPanel.addItem(ele);
      });
    }
  },
  setRecord: function(record) {
    this.triggerOwner = record;
  }
});