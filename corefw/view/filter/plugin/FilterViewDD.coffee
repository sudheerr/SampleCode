Ext.define 'Corefw.view.filter.plugin.FilterViewDD',
	extend: 'Ext.AbstractPlugin'
	alias: 'plugin.filterviewdragdrop'
	requires: [ 'Corefw.model.FilterCriteria' ]
	ddGroup: 'filterViewDD'
	enableDrag: true
	enableDrop: true
	ifCopyDraggedItem: (parent, droppedParent, record) ->
		parent.getStore().isGlobal and CorefwFilterModel.fiscalRegex.test(record.get('pathString'))
	ifItemDraggable: (record) ->
		true
	ifItemDroppable: (record) ->
		true
	init: (parent) ->
		@parent = parent
		_this = this
		if @enableDrag
			parent.on 'render', ->
				_this._enableDragFeature parent
				return
		if @enableDrop
			parent.on 'render', ->
				_this._enableDropFeature parent
				return
		return
	_enableDragFeature: (parent) ->
		_this = this
		@dragZone = Ext.create 'Ext.dd.DragZone', parent.getEl(),
			ddGroup: @ddGroup
			getDragData: (e) ->
				sourceEl = e.getTarget parent.itemSelector, 10
				if sourceEl
					d = document.createElement 'div'
					d.id = Ext.id()
					d.innerHTML = parent.getDragContent parent.indexOf(sourceEl)
					data = 
						ddel: d
						sourceEl: sourceEl
						repairXY: Ext.fly(sourceEl).getXY()
						draggedStore: parent.getStore()
						draggedRecord: parent.getRecord sourceEl
						recordIndex: parent.indexOf sourceEl
					return data
				return
			onBeforeDrag: (data, e) ->
				_this.ifItemDraggable data.draggedRecord
			getRepairXY: ->
				@dragData.repairXY
			afterValidDrop: (target, e, id) ->
				me = this
				if _this.ifCopyDraggedItem parent, target.droppedParent, me.dragData.draggedRecord
					return
				parent.removeRecord me.dragData.draggedRecord
				return
		return
	_enableDropFeature: (parent) ->
		_this = this
		@dropZone = Ext.create 'Ext.dd.DropZone', parent.getEl(),
			ddGroup: @ddGroup
			droppedParent: parent
			onContainerOver: (source, e, data) ->
				if _this.ifItemDroppable(data.draggedRecord) and data.draggedStore isnt @droppedParent.getStore() and source.ddGroup is @ddGroup
					return @dropAllowed
				@dropNotAllowed
			onContainerDrop: (source, e, data) ->
				if data.draggedStore is @droppedParent.getStore()
					return false
				if _this.ifItemDroppable(data.draggedRecord)
					parent.receiveCriteria data.draggedStore.getCriteria()[data.recordIndex]
					return true
				false
		return
	constructor: ->
		@callParent arguments
		return