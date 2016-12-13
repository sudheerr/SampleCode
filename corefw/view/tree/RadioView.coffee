Ext.define 'Corefw.view.tree.RadioView',
	extend: 'Ext.tree.View'
	xtype: 'treeradioview'

	checkboxSelector: '.' + Ext.baseCSSPrefix + 'tree-radioselect'

#	Radio view rules:
#	1. parent node doesn't have the radio button
#	2. Only one leaf node will be chcked at any time
#	3. Leaf node could not be unchecked
	initComponent: ->
		# see which record is already checked
		@getPreviousSelection false
		@callParent arguments
		return

	onCheckChange: (record) ->
		if record.raw.disabled
			return
		currChecked = record.get 'checked'
		isBoolean = Ext.isBoolean(currChecked)
		# only supports boolean value for checked property
		# do not supprts unchecking event
		return if not isBoolean or currChecked is true

		leaf = record.get 'leaf'
		# if this is not a leaf, do nothing
		if not leaf
			return
		@callParent arguments
		
		# if currChecked
		# if a previous record is checked, clear it
		if @prevCheckedRecord
			@prevCheckedRecord.set 'checked', false
			@fireEvent 'checkchange', record, record.get 'checked'
		@prevCheckedRecord = record
		return

	getPreviousSelection: (clearRecordsFlag)->
		store = @store
		record = store?.tree?.root
		@getPreviousSelection_worker record, clearRecordsFlag
		return


	getPreviousSelection_worker: (record, clearRecordsFlag) ->
		if not record
			return

		if not record.isLeaf()
			for node in record.childNodes
				@getPreviousSelection_worker node

		if record.get 'checked'
			if @prevCheckedRecord
				record.set 'checked', false
			else
				@prevCheckedRecord = record
			if clearRecordsFlag
				record.set 'checked', false
		return