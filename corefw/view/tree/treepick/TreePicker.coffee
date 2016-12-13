Ext.define 'Corefw.view.tree.treepick.TreePicker',
	#extend: 'Ext.form.field.Text'
	extend: 'Ext.form.field.Trigger'
	xtype: 'coretreepickernew'
	cls: 'treepicker'
	minChars: 2                # minimum number of characters needed to trigger a search
	searchDelay: 500        # milliseconds to wait after typing stops before sending search
	lastQueryStr: ''

	initComponent: ->
		props = @cache._myProperties
		if props.displayValue
			@value = props.displayValue
			@underlyingValue = props.value
		else
			@value = props.value
			@underlyingValue = props.value


		if props.emptyText
			@emptyText = props.emptyText

		@sendValue = @underlyingValue
		# @sendValue = props.value

		@lastDisplayValue = @value
		@lastSendValue = @sendValue

		@callParent arguments

		me = @
		me.bufferedGetData = Ext.Function.createBuffered ->
			myValue = me.getValue()
			me.sendValue = myValue
			me.getTreeData false, myValue, 'search'
			me.lastLoadMethod = 'search'
			return
		, me.searchDelay

		return


	onTriggerClick: ->
		@onFocus()
		return

	onFocus: ->
		win = @up('window')
		if win and win.el and win.el.isMasked() and @treewindow
			@treewindow.hide()
			return
		@callParent arguments

		if @disableFocusEvents
			delete @disableFocusEvents
			return

		if @treewindow and not @forceLoad
			@treewindow.showAt @getX(), @getY() + @getHeight()
			@disableChangeEvents = true
			@setValue ''
			@disableChangeEvents = false
			@focus()
		else if @underlyingValue
			@getTreeData true, false, 'locate'
			@disableChangeEvents = true
			@setValue ''
			@disableChangeEvents = false
			delete @forceLoad
			@lastLoadMethod = 'locate'
		else
			@getTreeData true, false, 'init'
			@lastLoadMethod = 'init'
			delete @forceLoad
		return

# set forceBlank to TRUE to pull all the values in the tree
# set expandAll to TRUE to expand all nodes after the tree loads
	getTreeData: (forceBlank, expandAll, treeLoadMethod) ->
		me = this

		treepickerCallback = (respObj, uipath)->
			ch = Corefw.util.Cache
			cm = Corefw.util.Common
			uip = Corefw.util.Uipath
			# de =  Corefw.util.Debug
			# if de.printOutRawResponse()
			# 	console.log '// Raw: TreePicker response, cache: ', respObj, me.cache

			props = me.cache._myProperties
			props.data = respObj.allTopLevelNodes
			windowUipath = me.uipath + '-treepickerwindow'
			ar = []
			props.columnAr = ar
			cacheConfig = ch.cacheConfigDef.header

			for item in respObj.allContents
				newObj =
					_myProperties: {}
				ar.push newObj
				cm.copyObjProperties newObj._myProperties, item, cacheConfig.propsUsed

			# destroy old window if it exists
			oldWindow = uip.uipathToComponent windowUipath
			if oldWindow
				oldWindow.destroy()

			# create the window
			twindow = Ext.create 'Corefw.view.tree.treepick.TreePickerWindow',
				treeLoadMethod: treeLoadMethod
				parentField: me
				width: me.getWidth()
				x: me.getX()
				y: me.getY() + me.getHeight()
				cache: me.cache
				uipath: windowUipath
			#TODO later parse this into cache
				respObj: respObj

			me.treewindow = twindow
			return

		# run the ONLOOKUP event to populate the tree
		rq = Corefw.util.Request
		appendFix = if treeLoadMethod is 'search' then @getRawValue() else ''
		url = rq.objsToUrl3 @eventURLs['ONLOOKUP'], null, appendFix
		errMsg = 'Did not receive a valid response for the treepicker'
		method = 'POST'

		rq.sendRequest5 url, treepickerCallback, @uipath, null, errMsg, method, null, null,
			beforeRequestFn: (opts) ->
				win = me.treewindow
				if win and win.el and not opts.isProgressEnd
					if me.currentLoadMask
						me.currentLoadMask.hide()
					me.currentLoadMask = win.setLoading true
					return
			afterRequestFn: (opts)->
				if me.currentLoadMask and opts.isProgressEnd
					me.currentLoadMask.hide()
					me.currentLoadMask = null;
					return
		return



	onChange: (newVal, oldVal) ->
		@callParent arguments

		if @disableChangeEvents
			delete @disableChangeEvents
			return

		# if strings are the same, ignoring leading and trailing spaces, then do nothing
		if oldVal and newVal and Ext.String.trim(newVal) is Ext.String.trim(oldVal)
			return

		# don't send blank strings
		newVal = if Ext.String.trim(newVal) then newVal else ""

		if not newVal.length or newVal.length >= @minChars
			@bufferedGetData()
		return


	generatePostData: ->
		if @setPostValueBlank
			postData =
				name: @cache._myProperties.name
				value: ''
		else
			sendValue = @sendValue
			if not sendValue
				sendValue = ''
			postData =
				name: @cache._myProperties.name
				value: sendValue
		if @hasOwnProperty 'expandingNodeId'
			postData.expandingNodeId = @expandingNodeId
			delete @expandingNodeId
		@lastQueryStr = postData.value
		return postData


	onDestroy: ->
		@callParent arguments
		if @treewindow
			@treewindow.destroy()
		return