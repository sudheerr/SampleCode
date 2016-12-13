# class that implements custom app-specific initialization code
# in the function that you want to perform app-specific initialization, add the following line:

# Corefw.customapp.Main.mainEntry 'functionToRun', this

# where "functionToRun" is the name of the function in this class
# the correct class function will be called depending on the name of the application


Ext.define 'Corefw.customapp.LimitExposure',
	singleton: true

	perspectiveInit: (comp) ->
		return



	topPanelInit: (config) ->
		# config.margin = 0
		return

	viewInit: (comp) ->
		# comp.padding = '0 3 0 3'
		return