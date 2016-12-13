Ext.define 'Corefw.view.form.field.LookupField',
	extend: 'Corefw.view.form.field.DropDownField'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corelookupfield'
	queryMode: 'remote'
	editable: true
	forceSelection: false
	isLookup: true
	hideTrigger: true
	minChars: 1
	typeAhead: true
	enableKeyEvents: false

	listConfig:
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
				combo.highLightKeywords()
				store = @getStore()
				if store.isDestroyed
					return

				getStartHisRecord = ->
					result = null
					store.each (record)->
						if record.raw.isHistory
							result = record
							return false
						return
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

	initComponent: ->
		lookupCls = if @cls then (@cls + ' citiriskLookup') else 'citiriskLookup'
		config =
			cls: lookupCls
		Ext.merge @, config
		@callParent arguments

#override: disable combox local query method
	doQuery: ()->
		return

	highLightKeywords: ()->
		if @picker
			keywords = @getRawValue()
			list = @picker
			store = list.getStore()
			if store.isDestroyed
				return

			if keywords
				keywords = keywords.replace /[\/\\]/g, (match)->
					"\\" + match

				keywords = keywords.replace /\*/g, ".*"
				nodes = (()->
					result = []
					store.each (record)->
						if not record.raw.isHistory
							node = list.getNode record
							if node
								result.push node
						return
					result)()
				reg = new RegExp keywords, "gi"
				getReplacedContent = (highlight)->
					highLightWrapper = ["<font color='red'>", highlight, "</font>"]
					highLightWrapper.join("")
				Ext.each nodes, (node)->
					node.innerHTML = node.innerHTML.replace reg, (match)->
						getReplacedContent match
					return
		return

	validator: (value)->
		if not value
			return true
		#check the input value in lookupfield's valid values
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

	setValue: (value)->
		# set the value to store if there is not data in it
		# to make display could show up correctly
		if @getStore()?.data.length is 0
			@bindData value
		@callParent arguments