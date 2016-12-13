Ext.define 'Corefw.view.grid.HeaderReorderer',
	extend: 'Ext.grid.plugin.HeaderReorderer'
	alias: 'plugin.coregridheaderreorderer'

	onHeaderCtRender: ->
		@callParent arguments

		dragZone = @dragZone
		dragZone.beforeDragOver = @overrideBeforeDragOver
		return

# To disable dragging process if current header is trying to out of its group header
	overrideBeforeDragOver: (target, e, id)->
		dragData = @dragData
		sourceHeader = dragData.header
		targetHeader = Ext.getCmp target.getTargetFromEvent(e)?.id
		return false unless targetHeader
		sourceGroupHeader = sourceHeader.up?()
		targetGroupHeader = targetHeader.up?()

		basegrid = sourceHeader.up('coregridbase')
		if basegrid.isEditing
			return false 
		#1 current dragged header is a sub header
		if sourceGroupHeader?.isGroupHeader
			# only allow current header reorder in the same group
			if targetGroupHeader == sourceGroupHeader
				return true
			#2 current dragged header is not a sub header
		else
			# only allow current header drop in the non sub header
			if not (targetGroupHeader and targetGroupHeader.isGroupHeader)
				return true

		return false