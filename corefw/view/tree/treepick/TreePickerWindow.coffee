Ext.define 'Corefw.view.tree.treepick.TreePickerWindow',
	extend: 'Ext.window.Window'
	xtype: 'coretreepickerwindow'

	height: 210
	header: false
	autoShow: true
	resizable: false
	draggable: false
	focusOnToFront: true
	layout: 'fit'
	ui: 'coretreepickerwindowui'
	expandThreshold: 500            # when nodes exceeds this number, only expand 1 level
# parentField: the field for which this window is picking items
# expandAll: if TRUE, then expand all nodes

	afterRender: ->
		@callParent arguments
		treeConfig =
			xtype: 'coretreefielddisplayvalue'
			layout: 'fit'
			cache: @cache

		#rdr = Corefw.util.Render
		evt = Corefw.util.Event
		evt.addEvents @respObj, 'field', treeConfig

		newtree = @add treeConfig

		@treefield = newtree
		@tree = newtree.tree

		treecolumns = newtree.tree?.columns
		console.log 'treecolumns: ', treecolumns

		if treecolumns and treecolumns.length
			treecolumns[0].dataIndex = newtree.displayColumn.index + ''

		treeNodesList = @tree.store.tree.flatten()
		treeNodeCount = treeNodesList.length
		console.log 'the number of records in the tree is: ', treeNodeCount

		if (@treeLoadMethod is 'init' or not @parentField.sendValue) or (treeNodeCount < @expandThreshold and @treeLoadMethod is 'search')
			for treeNode in treeNodesList
				if not treeNode.data.leaf and (not treeNode.data.children or not treeNode.data.children.length) and treeNode.parentNode and treeNode.parentNode.getPath?()
					@tree.expandPath treeNode.parentNode.getPath()
				else
					@tree.expandPath treeNode.getPath()

		# sadly, we have to attach a global event handler to every click in the document,
		# 	to see if any click is within the window coordinates
		# the window focus and blur events do not work reliably
		# this feature not supported by IE8

		# currently change to mousedown event since ok button may be clicked before
		document.addEventListener 'mousedown', this

		me = this
		focusDelay = Ext.Function.createDelayed ->
			if me.treeLoadMethod is 'locate'
				me.hightlightMatchedNodeText me.parentField.underlyingValue or me.parentField.value, 'locate'
			else
				me.hightlightMatchedNodeText me.parentField.sendValue, 'search'
			me.parentField.disableFocusEvents = true
			me.parentField.focus()
			me.tree.header.hide()
			deleteFocusDiabledFlag = Ext.Function.createDelayed ->
				delete me.parentField.disableFocusEvents
				return
			, 300
			deleteFocusDiabledFlag()
			return
		, 1
		focusDelay()
		return


# handles events from document.addEventListener
	handleEvent: (ev) ->
		if this.rendered and @parentField.rendered
			target = ev.target
			# if we clicked outside the window coordinates and outside the text field,
			# 		then hide the popup window
			if @el.dom.contains(target) or (@parentField.el and @parentField.el.dom.contains(target))
				return
			@hide()
			# restore the previous valid value
			parentField = @parentField
			if parentField.lastLoadMethod is 'search'
				parentField.forceLoad = true
			# restore the last valid value to the text field
			parentField.disableChangeEvents = true
			parentField.setValue parentField.lastDisplayValue
			parentField.sendValue = parentField.lastSendValue
			parentField.underlyingValue = parentField.lastSendValue
			parentField.disableChangeEvents = false
		return


# are the ev.x and ev.y click coordindates inside the Sencha component?
	isClickInside: (comp, ev) ->
		[x,y] = comp.getXY()
		width = comp.getWidth()
		height = comp.getHeight()
		if x < ev.x < x + width and y < ev.y < y + height
			return true
		return false

	generateSeqDisplayText: (record, displayField, text) ->
		path = record.getPath displayField, '>'
		return path.substr path.indexOf('>', 1) + 1

	hightlightMatchedNodeText: (searchStr, treeLoadMethod) ->
		treeStore = @tree.store
		if not searchStr
			return
		valueField = @tree.valueField

		if treeStore?.tree?.nodeHash
			nodeHash = treeStore.tree.nodeHash
			for key, nodeObj of nodeHash
				if key isnt 'root'
					value = nodeObj.data
					if treeLoadMethod is 'locate' and value and value[valueField] is searchStr
						@tree.selectPath nodeObj.getPath()
						return
		return

	onDestroy: ->
		@callParent arguments
		document.removeEventListener 'click', this
		return