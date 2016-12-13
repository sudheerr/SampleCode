// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.pivot.PivotTableField', {
  extend: 'Ext.container.Container',
  alias: 'widget.pivottablefield',
  requires: ['Corefw.view.grid.pivot.PivotTable'],
  overflowX: 'auto',
  overflowY: 'auto',
  initComponent: function() {
    var _ref;
    this.callParent(arguments);
    return this.reloadPivot((_ref = this.cache) != null ? _ref._myProperties : void 0);
  },
  reloadPivot: function(props) {
    this.table = this.add({
      xtype: 'pivottable',
      uipathId: 'pivotGrid',
      width: '100%',
      height: '100%',
      props: props,
      subTotalPosition: 'bottom'
    });
  }
});
