Ext.define 'Corefw.controller.DomainTree',
	extend: 'Ext.app.Controller'
	views: [ 'tree.DomainTree' ]
	models: [ 'DomainTreeNode' ]
	stores: [ 'DomainTreeNode' ]
	requires: []
	init: ->
		@control 'domainTree':
			itemclick: (view, node, item, index, e) ->
				try
					if node.isLeaf()
					else if node.isExpanded()
						view.collapse node
					else
						view.expand node
				catch e
				return
			cellclick: (me, td, cellIndex, record, tr, rowIndex, e, eOpts) ->
				if e.getTarget('img', 10, true)
					me.getSelectionModel().select record
				return
			afterlayout: (me, layout, eOpts) ->
				nd = me.getSelectionModel().getLastSelected()
				if !Ext.isEmpty(nd)
					me.getView().focusRow me.getView().store.indexOf(nd)
				return
		return