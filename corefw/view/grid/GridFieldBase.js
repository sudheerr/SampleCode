// Generated by CoffeeScript 1.8.0

/*
	base class for all grids that need to be in a field container,
		i.e., any grids found in a form
 */
Ext.define('Corefw.view.grid.GridFieldBase', {
  extend: 'Ext.form.FieldContainer',
  xtype: 'coregridfieldbase',
  padding: 0,
  border: 0,
  layout: 'fit',
  flex: 1,
  hideLabel: true,
  onResize: function() {
    if (this.alreadyResized) {
      delete this.alreadyResized;
      return;
    }
    this.alreadyResized = true;
    this.callParent(arguments);
  },
  addGrid: function(grid) {
    this.items = [grid];
    this.grid = grid;
    grid.parentComponent = this;
  },
  isFilterEnabledForAnyColumn: function(fieldItems) {
    var enabledforcolumn;
    enabledforcolumn = false;
    Ext.each(fieldItems, function(item) {
      if (typeof item._myProperties.filterType !== 'undefined') {
        enabledforcolumn = true;
      }
    });
    return enabledforcolumn;
  }
});