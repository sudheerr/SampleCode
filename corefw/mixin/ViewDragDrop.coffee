Ext.define 'Corefw.mixin.ViewDragDrop',
	commonBeforeDragOver: (dropTo, e, id) ->
		return true if @view is dropTo.view
		recievablePaths = dropTo.view.up('fieldcontainer')?.cache?._myProperties?.recievablePaths or []
		if -1 < recievablePaths.indexOf @view._uipath # uipath comes from view config in grid mixin
			return true
		else
			return false