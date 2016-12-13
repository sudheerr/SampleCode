Ext.define 'Corefw.mixin.Refreshable',
	updateNavigation: (navCache) ->
		# console.debug 'navCache', navCache
		nav = @.query('[uipath=' + navCache._myProperties.uipath + ']')[0]
		nav.setDisabled(not navCache._myProperties.enabled)
		nav.setVisible(navCache._myProperties.visible)
		return