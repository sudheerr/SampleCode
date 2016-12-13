Ext.define 'Corefw.mixin.UiPathAware',

	parentuipath: null

	binduipath: ->
		parentWithUipath = @up '[uipath]'
		if parentWithUipath and parentWithUipath.uipath
			@parentuipath = parentWithUipath.uipath
			if @uipathId
				@uipath = "#{@parentuipath}/#{@uipathId}"