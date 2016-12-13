// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.view.tree.plugin.ViewDragDrop', {
  extend: 'Ext.tree.plugin.TreeViewDragDrop',
  alias: 'plugin.coretreeviewdragdrop',
  mixins: ['Corefw.mixin.ViewDragDrop'],
  ddGroup: 'ViewDD',
  onViewRender: function(view) {
    var me, scrollEl;
    me = this;
    if (me.enableDrag) {
      if (me.containerScroll) {
        scrollEl = view.getEl();
      }
      me.dragZone = new Ext.tree.ViewDragZone({
        view: view,
        ddGroup: me.dragGroup || me.ddGroup,
        dragText: me.dragText,
        displayField: me.displayField,
        repairHighlightColor: me.nodeHighlightColor,
        repairHighlight: me.nodeHighlightOnRepair,
        scrollEl: scrollEl,
        beforeDragOver: me.commonBeforeDragOver
      });
    }
    if (me.enableDrop) {
      me.dropZone = new Ext.tree.ViewDropZone({
        view: view,
        ddGroup: me.dropGroup || me.ddGroup,
        allowContainerDrops: me.allowContainerDrops,
        appendOnly: me.appendOnly,
        allowParentInserts: me.allowParentInserts,
        expandDelay: me.expandDelay,
        dropHighlightColor: me.nodeHighlightColor,
        dropHighlight: me.nodeHighlightOnDrop,
        sortOnDrop: me.sortOnDrop,
        containerScroll: me.containerScroll
      });
    }
  }
});