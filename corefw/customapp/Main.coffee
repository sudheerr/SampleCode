# this is the main entry point for performing application-specific initialization

Ext.define 'Corefw.customapp.Main',
	singleton: true

# which class in the directory "customapp" provides the custom functions for this application?
	customAppRoutingInfo:
	#ArcApplication: 'CitiArc'
		SampleApplication: 'SampleApp'
		LimitExposureApplication: 'LimitExposure'

# place a call to this function immedately in front of the callParent of the class function
# 		or, at the very bottom of the calling function if there's no callParent

# "action" param is a string representing the function in the class that you want to call
#		functions that perform the same action will have the same name across classes
#		Classes do not need to implement all functions, so new functions can be added
#			to a class without triggering an exception in any other class
#		Implement only the classes you need for that application
	mainEntry: (action, comp) ->
		su = Corefw.util.Startup
		customapp = Corefw.customapp
		appName = su.getApplicationName()

		classPointerStr = @customAppRoutingInfo[appName]
		if classPointerStr
			appClass = customapp[classPointerStr]
			if appClass
				addlFunction = appClass[action]
				if addlFunction
					return addlFunction comp

		return
