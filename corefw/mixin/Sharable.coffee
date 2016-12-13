Ext.define 'Corefw.mixin.Sharable',

	isSharable: true
	_sharable: (key) ->
		@[key] = {} if not @hasOwnProperty key
		return @[key]

	updateShared: (key, value)->
		updatedKeys = []
		if Ext.isObject(key) and value is undefined
			Ext.apply @_sharable('_shared'), key
			updatedKeys = Ext.Object.getKeys key
		else
			@_sharable('_shared')[key] = value
			updatedKeys = [key]
		sharableChildren = Ext.ComponentQuery.query '[isSharable=true]', this
		for child in sharableChildren
			Ext.apply child._sharable('_shared'), @_sharable('_shared')
			updatedKeys.forEach (updatedKey)->
				cbDefs = child._sharable('_sharedUpdateCallbacks')[updatedKey]
				if cbDefs
					cbDefs.forEach (cbDef)->
						[cb, scope] = cbDef
						cb.call scope, child._sharable('_shared')[updatedKey]

	getShared: (key)->
		return if key then @_sharable('_shared')[key] else @_sharable('_shared')

	onSharedUpdate: (key, cb, scope=this)->
		@_sharable('_sharedUpdateCallbacks')[key] = @_sharable('_sharedUpdateCallbacks')[key] or []
		@_sharable('_sharedUpdateCallbacks')[key].push [cb, scope]