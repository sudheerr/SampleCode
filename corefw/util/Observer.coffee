Ext.define 'Corefw.util.Observer',
	singleton: true
	constructor: ->
		@store.parent = this
	###
    	@property {Object} stores the observed targets, observers, the relationship between target and observers
    ###
	store:
		mappings: {} # holds the information which mapping from target to observer
		targets: {} # holds the all state of targets
		observers: {} # holds the all information of observers and their events
		addMapping: (targetKey, state,  observerKey, eventTypes) ->
			target = @mappings[targetKey] or= {}
			state = target[state] or= {}
			observer = state[observerKey] or= {}
			events = observer.events or= []
			observer.events = events.concat eventTypes
			return targetKey
		getMapping: (targetKey) -> @mappings[targetKey]
		getMappings: (targetKeys = []) ->
			res = []
			me = this
			targetKeys.forEach (t) ->
				mapping = me.getMapping t
				mapping and res.push mapping
			return res
		###
    		register the observer
    		@param {String} targetKey The key of target, The default is uipath
    		@param {String} observerKey The key of observer, The default is uipath
    		@param {String} observedSate The state of target which observers observe to
    		@param {Array[String]} eventTypes The event of observer should be granted after target'state changed
    	###
		registerObserver: (targetKey, observerKey, observedSate, eventTypes = []) ->
			observer = @observers[observerKey]
			if not observer
				# add observer
				observer = @observers[observerKey] =
					eventGrantedTable: {} #record which event should be affected, key is event type, value is state
					targets: {}
			observer.targets[targetKey] = true # record target by key, the value 'true' doesn't mean any thing, just a value holder
			eventTypes.forEach (ev) -> not observer.eventGrantedTable[ev] and observer.eventGrantedTable[ev] = true # only granted the event which doesn't exist before
			# add observation mapping
			@addMapping targetKey, observedSate, observerKey, eventTypes
			return true
		getObserver: (observerKey) -> @observers[observerKey]
		# add a component as a target, it will grant all event if target is already existed
		addTarget: (targetKey) ->
			if target = @targets[targetKey]
				@parent.grantEvents target.state, targetKey
				return false
			@targets[targetKey] =
				state: @parent.States.INIT
				key: targetKey
			return true
		###
    		search all related targets for key
    		@param {String} targetKey The default value is 'all' which means will return all targets, Specially, This method
    		will find all targets matched by key's hierarchy.
    		for example:
    		The key is 'A/B/C/D', will return the targets matched keys:
    		'A/B/C/D','A/B/C','A/B','A'
    	###
		getTargets: (targetKey = 'all') ->
			ts = []
			targets = @targets
			if targetKey is 'all'
				for _, tar of targets
					ts.push tar
				return ts

			while (targetKey)
				target = targets[targetKey]
				ts.push target if target
				keys = targetKey.split '/'
				keys.pop()
				if keys.length is 0
					break
				targetKey = keys.join '/'
			return ts

		getTarget: (targetKey) -> @targets[targetKey]

		getTargetsByObserver: (observerKey) -> @mappings[observerKey] or []
		clear: ->
			@mappings = {}
			@targets = {}
			@observers = {}

	###
    	enum for defining target's states
    ###
	States:
		INIT: 'initialized' # default state
		DIRTY: 'dirty' # only notify observers which observed dirty
		SYNCED: 'synced' # notify all observers of target
	keyProperty: 'uipath'
	###
    	to add a component to be observed target and set its state as the 'INIT' if it is not exists in targets in store, then mark it is observed
    ###
	addTarget: (target) -> @store.addTarget target

	###
		to register a component to be the observer, any observed target information all comes from it event
		@param {String} observerKey The key of observer, the default is uipath
    	@events {Array[Object]} events The event object list
	###
	registerObserver: (observerKey, events = []) ->
		uip = Corefw.util.Uipath
		store = @store
		parentKey = uip.uipathToParentUipath observerKey
		me = this
		events.forEach (event) ->
			if event.dirtyCheck # always observe parent if observed state is DIRTY
				store.registerObserver parentKey, observerKey, me.States.DIRTY, [event.type]
			if observeTargetKeys = event.observeKeys
				observeTargetKeys = Ext.Array.from observeTargetKeys
				observeTargetKeys.forEach (targetKey) ->
					store.registerObserver targetKey, observerKey, me.States.SYNCED, [event.type]
		return true

	updateStateFromResponse: (response, state) ->
		return unless response
		me = this
		if Ext.isArray response
			response.forEach (res) ->
				me.updateStateFromResponse res, state
			return
		keyProperty = @keyProperty
		@updateState state, response[keyProperty]
		allContents = response.allContents or []
		for content in allContents
			@updateStateFromResponse content, state
		return

	###
    	update the target'state and grant its observers's event
 		@param {String} key target key
	###
	updateState: (state, key) ->
		return false unless (key and state) or @isSuspended
		store = @store
		target = store.getTarget key
		return false unless target
		target.state = state
		@grantEvents state, key
		return true

	###
    	grant the events of observers which observing target by target's state
		@param {String} key target key
	###
	grantEvents: (state, key) ->
		store = @store
		target = store.getTarget key
		return unless target
		mappings = store.getMappings [target.key]
		stateMappings = mappings.map (m) -> m[state]
		stateMappings.forEach (m) ->
			for observerKey, ob of m
				observer = store.getObserver observerKey
				events = ob.events
				events.forEach (ev) ->
					observer.eventGrantedTable[ev] = true
			return
		return

	isEventGranted: (observerKey, eventType) ->
		observer = @store.getObserver observerKey
		return true if not observer
		return observer.eventGrantedTable[eventType]
	###
    	disable all events of observer
	###
	disableAllEvents: (key) ->
		if observer = @store.getObserver key
			eventGrantedTable = observer.eventGrantedTable
			for event of observer.eventGrantedTable
				eventGrantedTable[event] = false
		return

	suspend: ->
		@isSuspended = true
	resume: ->
		@isSuspended = false