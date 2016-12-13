Ext.define 'Corefw.mixin.Maskable',
	showLoadMaskOnMe: true
	# by default use the global delays defined in Request
	loadingMaskDelay: null
	loadingMaskHideDelay: null

	getLoadMaskTarget: ->
		return this