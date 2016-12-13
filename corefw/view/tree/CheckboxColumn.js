// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.tree.CheckboxColumn', {
  extend: 'Ext.tree.Column',
  xtype: 'treecheckboxcolumn',
  treeRenderer: function(value, metaData, record) {
    var output, replaceStr, _ref;
    output = this.callParent(arguments);
    replaceStr = 'treenode-disabled x-tree-checkbox" disabled';
    if (record != null ? (_ref = record.raw) != null ? _ref.disabled : void 0 : void 0) {
      output = output.replace(/x-tree-checkbox"/g, replaceStr);
    }
    return output;
  }
});