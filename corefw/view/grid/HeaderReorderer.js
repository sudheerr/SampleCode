// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.grid.HeaderReorderer', {
  extend: 'Ext.grid.plugin.HeaderReorderer',
  alias: 'plugin.coregridheaderreorderer',
  onHeaderCtRender: function() {
    var dragZone;
    this.callParent(arguments);
    dragZone = this.dragZone;
    dragZone.beforeDragOver = this.overrideBeforeDragOver;
  },
  overrideBeforeDragOver: function(target, e, id) {
    var basegrid, dragData, sourceGroupHeader, sourceHeader, targetGroupHeader, targetHeader, _ref;
    dragData = this.dragData;
    sourceHeader = dragData.header;
    targetHeader = Ext.getCmp((_ref = target.getTargetFromEvent(e)) != null ? _ref.id : void 0);
    if (!targetHeader) {
      return false;
    }
    sourceGroupHeader = typeof sourceHeader.up === "function" ? sourceHeader.up() : void 0;
    targetGroupHeader = typeof targetHeader.up === "function" ? targetHeader.up() : void 0;
    basegrid = sourceHeader.up('coregridbase');
    if (basegrid.isEditing) {
      return false;
    }
    if (sourceGroupHeader != null ? sourceGroupHeader.isGroupHeader : void 0) {
      if (targetGroupHeader === sourceGroupHeader) {
        return true;
      }
    } else {
      if (!(targetGroupHeader && targetGroupHeader.isGroupHeader)) {
        return true;
      }
    }
    return false;
  }
});