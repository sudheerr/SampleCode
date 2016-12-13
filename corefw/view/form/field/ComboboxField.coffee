Ext.define 'Corefw.view.form.field.ComboboxField',
	extend: 'Ext.form.field.ComboBox'
	mixins: ['Corefw.mixin.CoreField', 'Corefw.mixin.Maskable']
	xtype: 'comboboxfield'
	forceSelection: false
	checkChangeBuffer: 500
	loadingMaskDelay: 1000
	loadingMaskHideDelay: 0
	statics:
		isLookupable: (props)->
			if props?.eventURLs?.ONLOOKUP or props?.events?.ONLOOKUP
				return true
			events = props?.events
			if events
				for event in events
					if event.type is 'ONLOOKUP'
						return true
			return false
		isEditable: (props)->
			return !!props?.lookupable
	getLoadMaskTarget: ->
		return @getPicker()
	listConfig:
	# If we set just maxHeight, combobox list will render to the maxHeight which is not good.
	# To resize the combobox list to max height only when required
		resizeHandles: 'w sw ne se nw'
		emptyText: '<div class="x-boundlist-item">No matching found.</div>'
		resizable:
			listeners:
				beforeresize: ()->
					this.resizeTracker.maxHeight = 10000
					this.target.maxHeight = 10000
					return
				resize: ()->
					this.resizeTracker.maxHeight = 300
					this.target.maxHeight = 300
					return
		style:
			whiteSpace: 'nowrap'
		listeners:
			beforerender: ()->
				combo = @up('comboboxfield') || @pickerField
				pageSize = if combo.cache then combo.cache._myProperties.pageSize else combo.pageSize
				if pageSize
					@pageSize = pageSize
					@pagingToolbar = @createPagingToolbar()
				return
			refresh: ()->
				combo = @up('comboboxfield') || @pickerField
				lookupable = combo.isLookupable()
				if lookupable
					combo.highLightKeywords()
					store = @getStore()
					if store.isDestroyed
						return
					getStartHisRecord = ()->
						result = null
						store.each((record)->
							if record.raw.isHistory
								result = record
								return false
							return
						)
						return result
					hisRecord = getStartHisRecord()
					hisNode = @getNode hisRecord
					if hisNode
						historyInfo = if combo.cache then combo.cache._myProperties.historyInfo else combo.historyInfo
						historyTitle = historyInfo?.historyTitle
						div = document.createElement 'div'
						div.className = 'historyValue-separator'

						cntDiv = document.createElement 'div'
						cntDiv.className = 'content'
						cntDiv.innerHTML = historyTitle

						div.appendChild cntDiv
						separator = new Ext.dom.Element div
						separator.insertBefore hisNode

					return
	validator: (value)->
		if not @editable or not value
			return true
		#check the input value in combobox's valid values
		me = @
		strValue = value.toString()
		replcement =
			"&amp;": "&"
			"&gt;": ">"
			"&lt;": "<"
			"&nbsp;": " "
			"&#39;": "'"

		findedIndex = me.getStore().findBy((record)->
			raw = record.get(me.displayField).toString()
			raw = raw.replace /&((amp)|(lt)|(gt)|(nbsp)|(#39));/g, (match)->
				return replcement[match]
			return raw is strValue)
		if findedIndex > -1
			return true
		return "The input value is invalid"

	isLookupable: ()->
		fn = Corefw.view.form.field.ComboboxField.isLookupable
		return (fn @) or (fn @cache?._myProperties)
	isEditable: ()->
		fn = Corefw.view.form.field.ComboboxField.isEditable
		return @editable or (fn @) or (fn @cache?._myProperties)
	initComponent: ()->
		me = @
		if me.isEditable() and not me.isLookupable()
			me.forceSelection = true
			addListeners =
				change: (me, newValue, oldValue)->
					if newValue is null
						me.setValue null
						me.setRawValue null
					return
			me.on addListeners
		# force selection as true when combo is not editable
		me.forceSelection = true if not me.isEditable()
		@callParent arguments
		return
	highLightKeywords: ()->
		if @picker
			keywords = @getRawValue()
			list = @picker
			store = list.getStore()
			if store.isDestroyed
				return

			if keywords
				keywords = keywords.replace(/[\/\\]/g, (match)->
					return "\\" + match
				)
				keywords = keywords.replace(/\*/g, ".*")
				nodes = (()->
					result = []
					store.each((record)->
						if not record.raw.isHistory
							node = list.getNode record
							if node
								result.push node
						return
					)
					return result)()
				reg = new RegExp(keywords, "gi")
				getReplacedContent = (highlight)->
					highLightWrapper = ["<font color='red'>", highlight, "</font>"]
					return highLightWrapper.join("")
				Ext.each nodes, (node)->
					node.innerHTML = node.innerHTML.replace(reg, (match)->
						return getReplacedContent(match)
					)
					return
		return

# override: supports to set object/array/string value
	setValue: (value)->
		if not Ext.isEmpty value
			me = @
			if not me.isRecord value
				# set the value to store if there is not data in it
				# to make display could show up correctly
				if me.getStore()?.data.length is 0
					me.setComboValues value
				if not Ext.isArray value
					arguments[0] = me.parseValue value
				else
					arguments[0] = value.map (v)->
						if me.isRecord v
							return v
						else
							return me.parseValue v

		@callParent arguments
		return

	isRecord: (v)->
		v.hasOwnProperty 'store'

	parseValue: (v)->
		if Ext.isObject v
			return (v[@valueField] or v.value)
		else if /^\[[\s\S]*\]$/.test v
		 	return v.replace(/\[|\]/g,'').split(',').map (s) -> Ext.String.trim s
		else
			return v

	onTypeAhead: ->
		if @store
			@callParent arguments
		return

	#disable combox local query method
	doQuery: ()->
		combo = @
		if combo.isLookupable()
			return
		else
			@callParent arguments
		return
	bindStore: (store)->
		me = @
		@callParent arguments
		if store
			historyInfo = if me.cache then me.cache._myProperties.historyInfo else me.historyInfo
			historyValues = historyInfo?.historyValues
			me.addHistoryData historyValues, true
		return
	setComboValues: (value) ->
		me = this
		me.validValues = value
		values = []
		getOneValueMap = (item) ->
			obj = {}
			if Ext.isObject item
				obj[me.displayField] = item[me.displayField] or item.displayValue or item.displayField
				obj[me.valueField] = item[me.valueField] or item.value or item.valueField
			else
				obj[me.displayField] = item
				obj[me.valueField] = item
			return obj

		if Ext.isArray(value)
			Ext.each(value, (item) ->
				values.push getOneValueMap(item)
				return
			)
		else
			values.push getOneValueMap(value)
		store = @getStore()
		store.clearFilter()
		store.loadData values
		return

	addHistoryData: (datas, isRemoveRepeat) ->
		if not datas
			return
		cm = Corefw.util.Common
		me = @
		store = me.getStore()
		if not Ext.isArray datas
			datas = [datas]
		if isRemoveRepeat
			store.each((record)->
				if record.raw.isHistory
					storeVal = record.get me.valueField
					for data,index in datas
						val = cm.getValue data
						if storeVal is val
							datas.splice index
				return
			)
		if not datas.length
			return
		getSingleData = (item)->
			obj = {}
			obj[me.displayField] = cm.getDisplayValue item
			obj[me.valueField] = cm.getValue item
			obj.isHistory = true
			return obj
		result = []
		if Ext.isArray datas
			for data in datas
				result.push getSingleData data
		store.loadData result, true
		return

	getDisplayValue: ->
		displayValue = @callParent arguments
		# decode the value for displaying
		return Ext.htmlDecode displayValue

	generatePostData: ->
		value = @getValue()
		displayValue = @getRawValue()
		fieldObj =
			name: @name
			value: if Ext.isEmpty(value) then "" else value
			displayValue: if Ext.isEmpty(displayValue) then "" else displayValue
		return fieldObj