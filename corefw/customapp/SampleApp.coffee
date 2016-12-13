# class that implements custom app-specific initialization code
# in the function that you want to perform app-specific initialization, add the following line:

# Corefw.customapp.Main.mainEntry 'functionToRun', this

# where "functionToRun" is the name of the function in this class
# the correct class function will be called depending on the name of the application


Ext.define 'Corefw.customapp.SampleApp',
	singleton: true

	perspectiveInit: (comp) ->
		return

#comp.tabBar =
#defaults:
#flex: 1
#height: 30
#maxWidth: 200
#dock: 'top'
# layout:
# 	pack: 'center'

# set a class that you can define in the CSS file
# comp.cls = 'some-class-specific-to-this-app'

# hard-code a style in all classes of this type, but only for this app
# comp.style = 'background-color: #f88;'


# post render code
# this is run AFTER top panel is rendered, so you can't just set attributes,
# you have to activate it somehow in the class
	topPanelInit: (comp) ->
		return