Ext.define 'Corefw.view.grid.plugin.BufferedSelect',
	extend: 'Ext.grid.plugin.BufferedRenderer'
	alias: 'plugin.corebufferedsel'

	init: (grid) ->
		@grid = grid
		@methodIntercept grid

	methodIntercept: (grid) ->
		_generatePostData = grid.generatePostData
		_generatePagingPostData = grid.generatePagingPostData
		postGeneratePostData = @generatePostData
		grid.generatePostData = ->
			postData = _generatePostData.apply grid, arguments
			return postGeneratePostData.call grid, postData
		grid.generatePagingPostData = ->
			postData = _generatePagingPostData.apply grid, arguments
			return postGeneratePostData.call grid, postData

	generatePostData: (postData) ->
		selColumn = @down 'coreselectcolumn'
		if selColumn
			return Ext.apply selColumn.generatePostData(), postData
		else
			gridProps = this.cache._myProperties
			bufferedPostData =
				selectedAll: gridProps.selectedAll
				selectAllScope: gridProps.selectAllScope
				deSelectingAll: false
			return Ext.apply bufferedPostData, postData