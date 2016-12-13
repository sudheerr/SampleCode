# used to hold internal cached information about client-side objects

# all breadcrumb functions can accept either a breadcrumb object or a uipath

Ext.define 'Corefw.util.InternalVar',
	singleton: true

	internalCache: {}

	deleteByName: (name) ->
		delete this.internalCache[name]
		return

	deleteByUipathCascade: (uipath) ->
		caches = @internalCache
		for cache of caches
			if cache.toString().indexOf(uipath) isnt -1
				delete caches[cache]
		return

	getByName: (name) ->
		retObj = this.internalCache[name]

		if not retObj
			retObj = {}
			this.internalCache[name] = retObj

		return retObj

	getByNameProperty: (name, propertyName) ->
		retObj = this.getByName name
		return retObj[propertyName]

	setByNameProperty: (name, propertyName, propertyValue) ->
		retObj = this.getByName name
		retObj[propertyName] = propertyValue
		return retObj

	deleteByNameProperty: (name, propertyName) ->
		retObj = this.getByName name
		delete retObj[propertyName]
		return

	getArray: (name) ->
		retArray = this.internalCache[name]
		if not retArray
			retArray = []
			this.internalCache[name] = retArray
		return retArray

# add value to the array held by this key
	addToArray: (name, value) ->
		ar = this.getArray name
		ar.push value
		return

# removes the item at array index from the array
	removeIndexFromArray: (name, index) ->
		ar = this.getArray name
		if ar.length > index
			Ext.Array.splice ar, index, 1
		return


	addTaskByUipath: (uipath, heartBeatName) ->
		taskName = uipath
		if heartBeatName
			taskName = taskName + '/' + heartBeatName
		retObj = this.getByName 'TASKRUNNER'
		runner = new Ext.util.TaskRunner()
		retObj[taskName] = runner
		return retObj[taskName]

	getTaskByUipath: (uipath, heartBeatName) ->
		taskName = uipath
		if heartBeatName
			taskName = taskName + '/' + heartBeatName
		retObj = this.getByName 'TASKRUNNER'
		return retObj[taskName]

	deleteTaskByUipath: (uipath, heartBeatName) ->
		taskName = uipath
		if heartBeatName
			taskName = taskName + '/' + heartBeatName
		retObj = this.getByName 'TASKRUNNER'
		retObj[taskName].destroy()
		delete retObj[taskName]
		return

	getByUipath: (uipath) ->
		return this.getByName uipath

	getByUipathProperty: (uipath, propertyName) ->
		return this.getByNameProperty uipath, propertyName

	setByUipathProperty: (uipath, propertyName, propertyValue) ->
		return this.setByNameProperty uipath, propertyName, propertyValue

	deleteUipathProperty: (uipath, propertyName) ->
		obj = this.getByUipath uipath
		delete obj[propertyName]
		return

	clearTimersForUipath: (uipath) ->
		retObj = this.getByName 'TASKRUNNER'

		for taskName of retObj
			if taskName.indexOf(uipath) is 0
				retObj[taskName].destroy()
				delete retObj[taskName]
		return
