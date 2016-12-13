# this class is necessary because we need to move the save/update buttons
#		to support textarea editing in the grid, which changes the height of the editor

Ext.define 'Corefw.view.grid.RowEditing',
	extend: 'Ext.grid.plugin.RowEditing'
	xtype: 'corerowediting'

	rowHeight: 29
	recordsAdded: []
	comboboxOriginalValues: {}
	helper: Corefw.util.RowEditorHelper
	serverData: {}

	listeners:
		# update the grid data
		edit: (editor, context) ->
			grid = context.grid
			grid.isEditing = false
			grid.stopFireEvents = false
			@hideMask()
			@helper.sendData editor.context, 'update'
			iv = Corefw.util.InternalVar
			iv.setByNameProperty 'roweditor', 'restoreinfo', null
			iv.setByNameProperty 'roweditor', 'needPostEditedData', false

		beforeedit: (editor, context) ->
			grid = context.grid
			# stop any field firing event from row editor form
			iv = Corefw.util.InternalVar
			iv.setByNameProperty 'roweditor', 'cancelEdit', false
			iv.setByNameProperty 'roweditor', 'suspendChangeEvents', true
			grid.setLoading 'Data Processing...'
			context.record.isEditing = true
			if editor
				context.serverData = {}
			@helper.beforeEdit context, editor.editor if not @isSkipBeforeEdit
			# check editable status if it changed by response data from before edit event
			if @isNotEditable grid
				grid.isEditing = false
				return false

			@initGridLayout()
			return

	startEdit: (record, columnHeader) ->
		grid = @grid
		iv = Corefw.util.InternalVar
		if grid.rowEditor.editing
			return
		#	set init editing states
		if grid.xtype isnt 'coretreebase'
			@recordIndex = grid.store.indexOf record
		else
			@recordIndex = grid.getNodeIndex record
		@columnIndex = grid.columnManager.getHeaderIndex columnHeader
		if columnHeader.cache?._myProperties?.events['ONBLUR']
			++@columnIndex
		isReadOnly = grid?.cache?._myProperties?.readOnly or false
		grid.isEditing = true
		if grid.stopOpeningEditor
			grid.stopOpeningEditor = false
			return
		if isReadOnly or @helper.processProhibited grid, record
			grid.isEditing = false
			return
		if not @view.body
			@view.body = @view
		@origRowData = Ext.clone record.getData()
		@callParent arguments
		#Stop process editing
		if @isNotEditable grid
			grid.isEditing = false
			return false
		# row editor env recheck
		editor = @editor
		if not editor or not editor.el
			return
		# set some editing status to related component
		ft = grid?.up 'fieldcontainer'
		ft?.valueChanged = true
		record.isEditing = true
		# adjust editor layout
		if @elementLayoutType is 'VBOX'
			@configureEditorVboxLayout()
		else
			@configureEditorAbsoluteLayout()
		# adjust position of buttons
		editor.syncFieldsHorizontalScroll()
		# do some addional workd for editor
		@helper.startEdit editor, columnHeader
		# resume fields in row editor form firing event
		iv.setByNameProperty 'roweditor', 'suspendChangeEvents', false
		grid.setLoading false
		@preventBackspaceEventOnRowEditing()
		#show mask
		@showMask @grid
		return

	completeEdit: ->
#		@helper.updateRecord @editor.context.record, @editor.getForm().getFieldValues()
		if @isProcessingEvent # stop updating when there is event fired before
			@shouldResumeUpdating = true
			return
		else
			@shouldResumeUpdating = false
			@callParent arguments
		return

	restoreEditor: (host = @grid, recordIndex = @recordIndex, columnIndex = @columnIndex) ->
		host.stopFireEvents = true
		record = host.store?.getAt? recordIndex
		column = host.columnManager?.getHeaderAtIndex? columnIndex
		if record and column and host.isEditing
			#	restore the row editor
			@startEdit record, column
			# to stop last start editing procssing
			Corefw.util.InternalVar.setByNameProperty 'roweditor', 'cancelEdit', true
		host.stopFireEvents = false
		return

	isNotEditable: (grid) ->
		iv = Corefw.util.InternalVar
		props = grid.cache?._myProperties or {}
		rowsData = props.data?.items or []
		currRowMetaData = rowsData[@recordIndex]?._myProperties
		readOnly = currRowMetaData?.readOnly or false
		editable = if currRowMetaData and currRowMetaData.hasOwnProperty 'editable' then currRowMetaData.editable else true
		cancelEdit = iv.getByNameProperty 'roweditor', 'cancelEdit'
		if cancelEdit or (currRowMetaData and (readOnly or not editable))
			grid.setLoading false
			return true
		else
			return false

	# if buttons are not visible, then adjust
	# needed after we adjust grid height with VBOX layout
	adjustButtonPlacement: (rowIndex) ->
		grid = @grid
		gridHeight = grid.getHeight()
		rowHeight = @rowHeight
		editor = @editor
		editorHeight = editor.getHeight()
		# adjust editorHeight to include buttons
		editorHeight += rowHeight
		editorY = editor.getLocalY()
		btns = editor.floatingButtons
		# if there's not enough space at the bottom, move the buttons to the top
		if (editorY + editorHeight + btns.getHeight()) > gridHeight
			btns = editor.floatingButtons
			btns.setLocalY -rowHeight
		return


	# to support multi-row edit, calculate how much extra space is needed
	configureEditorVboxLayout: ->
		rowHeight = @rowHeight
		buttonHeight = @rowHeight
		editor = @editor
		return unless editor.el
		editorHeight = editor.getHeight()
		gridField = @grid.up()
		gridHeight = @origGridHeight
		record = @context.record
		store = @context.record.store
		cm = Corefw.util.Common
		rowIndex = cm.findRecordIndex store, record
		btns = editor.floatingButtons

		# by default, always start with the buttons on the bottom
		btns.setLocalY editorHeight
		btns.setHeight buttonHeight

		if editorHeight < 35 and rowIndex > 2
			# normal editor behavior, do nothing
			# restore grid to original height
			gridField.setHeight gridHeight
			@adjustButtonPlacement rowIndex
			return


		adjustment = (editorHeight / 2) - (rowHeight / 2)
		newLocalY = editor.getLocalY() - adjustment

		# add button height for subsequent calculations
		editorHeight += rowHeight
		editor.setLocalY newLocalY
		maxHeight = gridField.maxHeight
		minHeight = gridField.minHeight
		delete gridField.maxHeight
		delete gridField.minHeight
		# the entire editor fits in the grid, so remove all the extra space
		if newLocalY + editorHeight < gridHeight
			gridField.setHeight gridHeight
		else
			adjustmentGridHeight = editor.getLocalY() + editorHeight + rowHeight / 2
			gridField.setHeight adjustmentGridHeight
		# restore the max and min height
		gridField.maxHeight = maxHeight if maxHeight
		gridField.minHeight = minHeight if minHeight
		return

	# to support this, figure out how much space is needed,
	#	and then insert that many rows to fill the space
	configureEditorAbsoluteLayout: (record) ->
		rowHeight = @rowHeight
		editor = @editor
		return unless editor.el
		editorHeight = editor.getHeight()
		if editorHeight < 35
			# normal editor behavior, do nothing
			return
		grid = @grid
		gridHeight = grid.getHeight()
		# how many rows on the bottom need extra space
		rowsFromEndNeedSpace = Math.floor((editorHeight / 2) / rowHeight) + 1
		@rowsFromEndNeedSpace = rowsFromEndNeedSpace
		store = grid.store
		numRows = store.getCount()
		cm = Corefw.util.Common
		rowIndex = cm.findRecordIndex store, record
		currRowFromEnd = numRows - (rowIndex + 1)
		btns = editor.floatingButtons
		btnPosition = btns.position

		if currRowFromEnd < rowsFromEndNeedSpace
			rowsAdded = true

			# rows we need to add: (editorHeight/2 / rowHeight) - rowsFromEnd*rowHeight, rounded up
			rowsToAdd = Math.floor(((editorHeight / 2) - (currRowFromEnd * rowHeight)) / rowHeight) + 1

			@recordsAdded = []
			for i in [0... rowsToAdd]
				mod = store.add({})
				@recordsAdded.push mod[0]

			grid.getView().scrollBy 0, 999, false

		# @addFillerRows record
		placeEditor = Ext.Function.createDelayed ->
			# reset the midpoint of the editor
			adjustment = (editorHeight / 2) - (rowHeight / 2)
			newLocalY = editor.getLocalY() - adjustment
			# for variable height grids, grid height will have changed
			gridHeight = grid.getHeight()
			bottomY = gridHeight - editorHeight

			if rowsAdded
				newLocalY = bottomY

			editor.setLocalY newLocalY
			# if btnPosition is 'bottom' and not notEnoughSpace
			if btnPosition is 'bottom'
				btns.setLocalY editorHeight
			else
				btns.setLocalY -rowHeight
			btns.setHeight rowHeight
		, 1
		placeEditor()
		return

	cancelEdit: ->
		@suspendChangeEvents = true
		@cleanAfterEdit()
		grid = @context.grid
		grid.stopFireEvents = false
		ft = grid.ownerCt
		ft?.valueChanged = true
		grid.isEditing = false
		record = @context.record
		@helper.updateRecord record, @origRowData, true
		record.commit()
		record.dirty = true
		@helper.cancelEdit @context
		@hideMask()
		@callParent arguments
		Corefw.util.InternalVar.setByNameProperty 'roweditor', 'restoreinfo', null
		delete @suspendChangeEvents
		return

	validateEdit: ->
		passValidate = @callParent arguments
		if passValidate
			# if there are any comboboxes, check to see if they have valid values
			editor = @editor
			context = @context
			formRecord = context.record
			# if there are any other disabled fields other than comboboxes, update its value as well.
			disabledNonComboboxFields = editor.query '>[editable=true][disabled=true]:not(combobox)'
			for disabledNonComboboxField in disabledNonComboboxFields
				if disabledNonComboboxField.getValue
					formRecord.set disabledNonComboboxField.name, disabledNonComboboxField.getValue()
			@cleanAfterEdit()
		return passValidate

	# clean up after editing
	cleanAfterEdit: ->
		grid = @grid
		gridField = grid.up()
		store = grid.store
		recAddedArray = @recordsAdded
		if recAddedArray and recAddedArray.length and store.remove
			store.remove? recAddedArray

		if @elementLayoutType is 'VBOX'
			gridField.maxHeight = @origMaxHeight if @origMaxHeight?
			gridField.setHeight @origGridHeight
			@context.row.setAttribute 'style', null

		gridpickers = @editor.query '>roweditorgridpicker'
		for gp in gridpickers
			gp.hideGridWindow()
		@recordsAdded = []
		return


	# modify the grid layout for showing editor
	initGridLayout: ->
		grid = @grid
		elementUp = grid.up 'coreelementform'
		layoutType = elementUp.cache?._myProperties?.layout?.type

		@originalGridHeight = gridHeight = grid.getHeight()
		@origGridHeight = gridHeight
		@elementLayoutType = layoutType

		if layoutType is 'VBOX'
			# add a bunch of extra space
			gridField = grid.up()
			@origGridHeight = gridField.getHeight()
			@origMaxHeight = gridField.maxHeight
			gridHeight = gridField.getHeight()
			gridField.setHeight gridHeight + 150
		return

	preventBackspaceEventOnRowEditing: ->
		cm = Corefw.util.Common
		_dom = @editor?.el?.dom
		if not _dom
			return
		_dom?.onkeydown = cm.preventBackspaceEvent
		return

	showMask: (grid) ->
		showEditingMask = true
		if not (grid and grid.el)
			showEditingMask = false
		else if (grid.cache?._myProperties?.showEditingMask is false)
			showEditingMask = false
		return if showEditingMask is false
		mask = Ext.get 'global'
		body = Ext.getBody()
		if not mask
			mask = Ext.getBody().createChild
				tag: 'div'
				class: Ext.baseCSSPrefix + 'mask'
				id: 'global'
				style: [
					'z-index:4'
					'width:' + body.getWidth()
					'height:' + body.getHeight()
					'right:auto'
					'left:0px'
					'top:0px'
					'visibility:hidden'
				].join ';'

		grid.z_index = grid.el.dom.style.zIndex
		grid.el.setStyle 'z-index', 5
		mask.show()
		@mask = mask
		return

	hideMask: ->
		grid = @grid
		return unless grid and grid.el and @mask
		grid.el.dom.style['z-index'] = grid.z_index
		@mask?.remove()
		delete @mask
		return