Ext.define 'Corefw.view.grid.plugin.ViewDragDrop',
	extend: 'Ext.grid.plugin.DragDrop'
	alias: 'plugin.coregridviewdragdrop'
	mixins: ['Corefw.mixin.ViewDragDrop']
	ddGroup: 'ViewDD'

	onViewRender: (view) ->
		me = this
		if me.enableDrag
			if me.containerScroll
				scrollEl = view.getEl()

			me.dragZone = new Ext.view.DragZone
				view: view
				ddGroup: me.dragGroup or me.ddGroup
				dragText: me.dragText
				containerScroll: me.containerScroll
				scrollEl: scrollEl
				beforeDragOver: me.commonBeforeDragOver

		if me.enableDrop
			me.dropZone = new Ext.grid.ViewDropZone
				view: view
				ddGroup: me.dropGroup or me.ddGroup
		return