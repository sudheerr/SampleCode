###
Create splitter when it is TIME.
TIME is:
when
	container is vbox layout
or
	container is hbox layout, but no grid child components
or
	container is hbox layout, and all its grid view children has loaded
###
Ext.define 'Corefw.view.layout.SplitterWrapper',
	constructor: (config) ->
		compToSplit = config.compToSplit
		compToSplit.on 'boxready', Ext.bind @prepareSplitters, @
		@compToSplit = compToSplit
		@layoutType = config.layoutType
		@splitters = config.splitters
		@splitterCreated = false
		return

	setVerticalScrollBar: (comp) ->
		if comp.layoutManager.type is 'tab'
			tabChilds = comp.query ">>coreelementform"
			Ext.each tabChilds, (child) ->
				child.setAutoScroll true
				child.setOverflowXY 'hidden', 'auto'
			return
		comp.autoScroll = ''
		comp.setOverflowXY 'hidden', 'auto'
		return
# createSplitters is invoked after panel box ready, since splitter's container must have height/width,
	prepareSplitters: ->
		layoutType = @layoutType
		compToSplit = @compToSplit

		compToSplit.listenGridViewReady = true
		gridfieldbases = compToSplit.query "coregridfieldbase[rendered]"
		@gridCount = gridfieldbases.length

		if layoutType is 'hbox' and @gridCount > 0
			@loadedGrid = 0
			compToSplit.on 'gridviewready', Ext.bind @onGridViewReady, @
		else
			@createSplitters()

		return

# Be triggered after grid.viewready, Splitters will be loaded after all grid components are loaded
	onGridViewReady: ->
		# load splitters after all grid components are loaded
		if ++@loadedGrid is @gridCount
			@createSplitters()
		return

	createSplitters: ->
		compToSplit = @compToSplit
		layoutType = @layoutType
		splitters = @splitters
		layoutManager = compToSplit.layoutManager
		if not layoutManager
			return

		# TODO remove below deprecated code, that was used to for stretching hbox contents
		# @deprecated
		# Manully set self.height = self.getHeight().
		# To add a splitter, its hbox container must have specific height,
		# looks like an Extjs defect, the height of hbox container is undefined though it has value with getHeight()
		# compHeight = compToSplit.getHeight()
		# compToSplit.height = compHeight if not compToSplit.height and layoutType is 'hbox'

		for uipath, index in splitters
			componenetBeforeSplitter = compToSplit.down "[uipath=#{uipath}]"
			if not componenetBeforeSplitter
				continue
			componenetAfterSplitter = componenetBeforeSplitter.nextSibling()
			if not componenetAfterSplitter
				continue
			insertIndex = layoutManager.getContentIndex componenetBeforeSplitter
			splitter =
				xtype: 'splitter'
				size: 6

			if layoutType is 'vbox'
				componenetBeforeSplitter.addCls 'component-before-horizontal-splitter'
				#splitter.height = '8px'

				@setVerticalScrollBar componenetBeforeSplitter
				@setVerticalScrollBar componenetAfterSplitter
			else
				componenetBeforeSplitter.addCls 'component-before-vertical-splitter'
			#splitter.width = '8px'

			compToSplit.insert insertIndex + 1, splitter
			compToSplit.listenGridViewReady = false
		@splitterCreated = true
		return

# recordWH/applyWH is a hack for ExtJS.
# We need specify the content width/height when having splitter, otherwise the new added content will get hidden.
# @deprecated from widget update impl
	recordWH: (content) ->
		if not @splitterCreated
			return
		layoutType = @layoutType
		prevCmp = content.previousSibling?()
		nextCmp = content.nextSibling?()
		if prevCmp?.xtype is 'splitter' or nextCmp?.xtype is 'splitter'
			@contentHeight = content.getHeight() if layoutType is 'vbox'
			@contentWidth = content.getWidth() if layoutType is 'hbox'
		return
# @deprecated from widget update impl
	applyWH: (content) ->
		if not @splitterCreated
			return
		if not @contentHeight and not @contentWidth
			return
		content.height = @contentHeight if @contentHeight
		content.width = @contentWidth if @contentWidth
		delete @contentHeight
		delete @contentWidth
		delete content.flex
		return



