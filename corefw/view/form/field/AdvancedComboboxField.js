// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.form.field.AdvancedComboboxField', {
  extend: 'Corefw.view.form.field.ComboboxField',
  mixins: ['Corefw.mixin.CoreField'],
  xtype: 'advancedcomboboxfield',
  hideAfterSelect: false,
  onListSelectionChange: function(list, selectedRecords) {
    var hasRecords, me, willHide;
    me = this;
    willHide = me.multiSelect ? false : me.hideAfterSelect;
    hasRecords = selectedRecords.length > 0;
    if (!me.ignoreSelection && me.isExpanded) {
      if (willHide) {
        Ext.defer(me.collapse, 1, me);
      }
      if (me.multiSelect || hasRecords) {
        me.setValue(selectedRecords, false);
      }
      if (hasRecords) {
        me.fireEvent('select', me, selectedRecords);
      }
      me.inputEl.focus();
    }
  },
  onItemClick: function(picker, record) {
    var me, selection, valueField;
    me = this;
    selection = me.picker.getSelectionModel().getSelection();
    valueField = me.valueField;
    if (!me.multiSelect && selection.length) {
      if (record.get(valueField) === selection[0].get(valueField)) {
        me.displayTplData = [record.data];
        me.setRawValue(me.getDisplayValue());
        if (me.hideAfterSelect) {
          me.collapse();
        }
      }
    }
  },
  initComponent: function() {
    var me, newListConfig;
    me = this;
    newListConfig = {
      xtype: 'listview',
      border: true,
      addListeners: {
        itemdblclick: function(listview, record, item, index, e) {
          me.fireEvent("itemdblclick", me, record, item, index);
        }
      },
      getTooltip: function(record) {
        return record.get("sub_dispField");
      },
      dataRenderer: function(value, metaData, record, rowIndex, colIndex, store, view) {
        var html;
        html = value + "<div style='font-style:italic;'>" + record.get("sub_dispField") + "</div>";
        return html;
      }
    };
    this.listConfig = Ext.apply({}, newListConfig);
    this.callParent(arguments);
  }
});
