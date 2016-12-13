# contains cache object and functions to create and maintain cache

Ext.define 'Corefw.util.Cache',
	singleton: true
	maincache: {}

# parameters for separate levels of cache
# TODO eliminate this list
	cacheConfigDef:
		application:
			nextLevel: 'perspective'
			propsUsed: [
				'enabled'
				'events'
				'layout'
				'name'
				'title'
				'visible'
				'widgetType'
				'messages'
				'allNavigations'
				'cssbyPath'
				'uipath'
				'breadcrumb'
				'maxInactiveInterval'
			]
			renames:
				allNavigations: 'navs'
		perspective:
			nextLevel: 'view'
			nextLevelArray: 'views'
			propsUsed: [
				'enabled'
				'visible'
				'active'
				'title'
				'events'
				'name'
				'layout'
				'closable'
				'hideBorder'
				'toolTip'
				'uniqueKey'
				'widgetType'
				'allNavigations'
				'messages'
				'toolbar'
				'heartBeats'
				'uipath'
				'isRemovedFromUI'
				'readOnly'
			]
			renames:
				allNavigations: 'navs'
		view:
			nextLevel: 'element'
			nextLevelArray: 'elements'
			propsUsed: [
				'enabled'
				'title'
				'visible'
				'active'
				'visited'
				'events'
				'coordinate'
				'popup'
				'layout'
				'closable'
				'closed'
				'hideBorder'
				'name'
				'group'
				'toolTip'
				'widgetType'
				'allNavigations'
				'messages'
				'warningMessages'
				'height'
				'width'
				'position'
				'draggable'
				'resizable'
				'uipath'
				'isRemovedFromUI'
				'subnavigator'
				'readOnly'
				'coordinateX'
				'coordinateY'
				'valiationStatus'
				'type'
				'domainName'
			]
			renames:
				allNavigations: 'navs'

		compositeElement:
			nextLevel: 'element'
			nextLevelArray: 'elements'
			propsUsed: [
				'enabled'
				'title'
				'active'
				'secondTitle'
				'visible'
				'cssclass'
				'coordinate'
				'messages'
				'layout'
				'events'
				'closable'
				'expanded'
				'hideBorder'
				'name'
				'toolTip'
				'toolbar'
				'widgetType'
				'allNavigations'
				'collapsible'
				'uipath'
				'verticalSeparator'
				'readOnly'
				'isRemovedFromUI'
			]
			renames:
				allNavigations: 'navs'
		element:
			nextLevel: 'field'
			nextLevelArray: 'fields'
			propsUsed: [
				'enabled'
				'title'
				'active'
				'visible'
				'coordinate'
				'messages'
				'layout'
				'events'
				'closable'
				'expanded'
				'hideBorder'
				'name'
				'group'
				'toolTip'
				'pageSize'
				'widgetType'
				'allNavigations'
				'collapsible'
				'secondTitle'
				'uipath'
				'toolbar'
				'cssclass'
				'readOnly'
				'verticalSeparator'
				'isRemovedFromUI'
			]
			renames:
				allNavigations: 'navs'
		fieldset:
			nextLevel: 'field'
			nextLevelArray: 'fields'
			propsUsed: [
				'enabled'
				'title'
				'visible'
				'coordinate'
				'messages'
				'layout'
				'events'
				'name'
				'group'
				'toolTip'
				'widgetType'
				'uipath'
				'allNavigations'
				'readOnly'
				'isRemovedFromUI'
			]
			renames:
				allNavigations: 'navs'
		field:
			nextLevel: 'content'
			nextLevelArray: 'none'
			propsUsed: [
				'pivotMeasures'
				'pivotCells'
				'pivotColumnHeaders'
				'pivotRowHeaders'
				'enableTextSelection'
				'groupField'
				'onlyRefreshGridData'
				'enableAutoSelectAll'
				'fieldMask'
				'enabled'
				'title'
				'visible'
				'editable'
				'selectable'
				'coordinate'
				'layout'
				'events'
				'name'
				'menu'
				'items'
				'grid'
				'subGrid'
				'path'
				'feValidations'
				'pathString'
				'group'
				'toolTip'
				'type'
				'columnType'
				'masked'
				'locked'
				'isLookup'
				'style'
				'series'
				'seriesType'
				'color'
				'lineWidth'
				'radius'
				'width'
				'xAxisTitle'
				'yaxisTitle'
				'xLabelTransfer'
				'stacked'
				'legend'
				'alignLegend'
				'showAs'
				'chartColors'
				'textDisplayStyle'
				'axesConfig'
				'labelRotated'
				'groupBy'
				'groupHeaders'
				'validValues'
				'disabledValidValues'
				'validations'
				'value'
				'displayValue'
				'values'
				'valueType'
				'selectType'
				'widgetType'
				'emptyText'
				'columnItems'
				'rows'
				'rowItems'
				'cellItems'
				'allNavigations'
				'allContents'
				'subContents'
				'centerGrid'
				'columnGrid'
				'rowGrid'
				'currentPage'
				'selectablePageSizes'
				'pageSize'
				'totalRows'
				'sortHeaders'
				'checkOnly'
				'supportAutoNumber'
				'numberOfLockedHeaders'
				'allTopLevelNodes'
				'messages'
				'tooltipValue'
				'collapsible'
				'lazyLoading'
				'axis'
				'multiSelect'
				'lookupable'
				'minRow'
				'maxRow'
				'verticalSeparator'
				'format'
				'uipath'
				'spinnerSpec'
				'gridPicker'
				'expandSelectedNode'
				'mandatory'
				'cssClass'
				'cssClassList'
				'fill'
				'iconStyle'
				'cellCssClass'
				'maxUploadSize'
				'maxUploadTotalSize'
				'showTitleBar'
				'readOnly'
				'showFullRow'
				'supportWholeCheck'
				'textAlign'
				'historyInfo'
				'multiColumnSortingEnabled'
				'isRemovedFromUI'
				'draggable'
				'recievablePaths'
				'monthPickerType'
				'appointDay'
				'multipleUpload'
				'expandAllNodes'
				'uploadable'
				'pseudoProtocol'
				'acceptFiles'
				'headerEllipses'
				'headerTitleRows'
				'readOnlyStyle'
				'multiSelectable'
				'closable'
				'hideRefresh'
				'allowAutoWidth'
				'selectableNumberScaleUnits'
				'currency'
				'numberScaleUnit'
				'columns'
				'vertical'
				'footerPagingToolbar'
				'footerText'
				'align'
				'allowAutoWidth'
				'noLines'
				'titleBackgroundIsWhite'
				'enableClientSideSelectAll'
				'hideGridHeaderFilters'
				'hideGridHeaderMenus'
				'infinity'
				'bufferedPages'
				'infiniteFinish'
				'minDate'
				'maxDate'
				'lookupCacheable'
				'borderless'
				'showEditingMask'
				'buffered'
				'selectAllScope'
				'selectedAll'
			]
			renames:
				allNavigations: 'navs'
		content:
			nextLevel: 'none'
			nextLevelArray: 'none'
		nav:
			propsUsed: [
				'enabled'
				'visible'
				'coordinate'
				'events'
				'style'
				'group'
				'menu'
				'name'
				'title'
				'label'
				'toolTip'
				'type'
				'cssClass'
				'uipath'
			]
		header:
			propsUsed: [
				'enabled'
				'title'
				'visible'
				'editable'
				'events'
				'name'
				'menu'
				'dropdownMenu'
				'pathString'
				'group'
				'toolTip'
				'type'
				'masked'
				'locked'
				'style'
				'series'
				'rows'
				'width'
				'minWidth'
				'maxWidth'
				'groupBy'
				'validValues'
				'validations'
				'value'
				'valueType'
				'selectType'
				'fieldMask'
				'filterType'
				'filterValue'
				'filterOperator'
				'filterOperators'
				'multiFilterCriteria'
				'filterOptions'
				'index'
				'supportMultiSelect'
				'supportSort'
				'widgetType'
				'messages'
				'iconMap'
				'format'
				'multiSelect'
				'lookupable'
				'sortState'
				'uipath'
				'spinnerSpec'
				'linkMap'
				'supportWholeCheck'
				'gridPicker'
				'textAlign'
				'multiColumnSortingEnabled'
				'pageSize'
				'flexWidth'
				'hideable'
				'lockable'
				'draggable'
				'showColumnsMenu'
				'minDate'
				'maxDate'
			]
		messagebox:
			propsUsed: [
				'closed'
				'enabled'
				'title'
				'visible'
				'events'
				'name'
				'widgetType'
				'messages'
				'message'
				'messageType'
				'allNavigations'
				'uipath'
			]
			renames:
				allNavigations: 'navs'
		toolbar:
			nextLevel: 'field'
			nextLevelArray: 'fields'
			propsUsed: [
				'enabled'
				'title'
				'visible'
				'events'
				'name'
				'widgetType'
				'allNavigations'
				'uipath'
				'layout'
				'cssClass'
			]
			renames:
				allNavigations: 'navs'
		breadcrumb:
			nextLevel: 'field'
			nextLevelArray: 'fields'
			propsUsed: [
				'enabled'
				'title'
				'visible'
				'events'
				'name'
				'widgetType'
				'allNavigations'
				'uipath'
				'layout'
				'isRemovedFromUI'
			]
			renames:
				allNavigations: 'navs'
		notification:
			propsUsed: [
				'message'
				'messageType'
				'position'
				'timeout'
				'title'
				'widgetType'
			]

	widgetTypeToLevelstr:
		APPLICATION: 'application'
		PERSPECTIVE: 'perspective'
		VIEW: 'view'
		COMPOSITE_ELEMENT: 'compositeElement'
		FORM_BASED_ELEMENT: 'element'
		BAR_ELEMENT: 'element'
		FIELD: 'field'
		FIELDSET: 'fieldset'
		HEADER: 'header'
		MESSAGE_BOX: 'messagebox'
		TOOLBAR: 'toolbar'
		BREADCRUMB: 'breadcrumb'
		NAVIGATION: 'nav'
		NOTIFICATION: 'notification'

	chartColorsSet:
		chart_color_soft_blue: '#4caeed'
		chart_color_light_orange: '#ff944c'
		chart_color_dark_moderate_cyan: '#4ca977'
		chart_color_bright_red: '#e54343'
		chart_color_light_grey: '#a7a5a6'
		chart_color_soft_orange: '#f7c54d'
		chart_color_dark_magenta: '#976ea0 '
		chart_color_light_red: '#ff694c'
		chart_color_strong_cyan: '#00b0b9'
		chart_color_dark_moderate_blue: '#4C6C9C'
		chart_color_dark_grey: '#53565a'
		chart_color_grayish_blue: '#99abc7'


	cssclassToIcon:
		EDIT: 'edit'
		SAVE: 'save'
		COPY: 'copy'
		DELETE: 'delete'
		TRASH: 'trash'
		SEARCH: 'search'
		INBOX: 'inbox'
		PDF: 'pdf'
		EXCEL: 'excel-xls'
		WORD: 'word-file'
		PRINT: 'print'
		HELP: 'help'
		INFO: 'info'
		REFRESH: 'refresh'
		CLOSE: 'delete-circle'
		NEW: 'new'
		SETTINGS: 'settings'
		UPLOAD: 'upload'
		DOWNLOAD: 'download'
		RESET: 'power'
		VIEW: 'view'
		COLLAPSE_ALL: 'collapse-all'
		EXPAND_ALL: 'expand-all'
		CANCEL: 'cancel'
		FILTER: 'filter'
		VALIDATE: 'check'
		SUBMIT: 'check-mark-submit'
		PAUSE: 'pause'
		RUN: 'run'
		POST: 'post'
		GENERATE: 'generate'
		I_ADD: 'plus'
		I_DELETE: 'delete'
		I_SAVE: 'save'
		I_EDIT: 'edit'
		I_IMPORT: 'download'
		I_COPY: 'copy'
		I_EXPORT: 'upload'
		I_DELETEALL: 'trash'
		I_OTHERREQUEST: 'users'
		I_MYREQUEST: 'user'
		I_PDF: 'pdf'
		I_EXCEL: 'excel-xls'
		I_CSV: 'csv'
		I_EMAIL: 'email'
		I_DOWNLOAD: 'download'
		I_UPLOAD: 'upload'
		I_REFRESH: 'refresh'
		I_RESET: 'power'
		I_CANCEL: 'cancel'
		I_SEARCH: 'search'
		I_LOCK: 'lock'
		I_UNLOCK: 'unlock'
		I_REJECT: 'reject'
		I_APPROVE: 'approve'
		I_CLEAR: 'delete-circle'
		I_RUN: 'run'
		I_CHAT: 'chat'
		I_POST: 'post'
		I_FAVORITE: 'favorite'
		I_LINK: 'link'
		I_SUBMIT: 'check-mark-submit'
		I_PAUSE: 'pause'
		I_GENERATE: 'generate'
		ICG_WHATIF_LINK: 'what-if'
		ICG_EE_LINK: 'ee'
		I_EQUAL: 'equal-to'
		I_NOTEQUAL: 'not-equal'
		I_LESSTHAN: 'less-than'
		I_LESSTHANEQUAL: 'lesser-equal'
		I_GREATERTHAN: 'greater-than'
		I_GREATERTHANEQUAL: 'greater-equal'
		I_IN: 'in'
		I_NOTIN: 'not-in'
		I_LIKE: 'like'
		navigation_navigator: 'compass'
		navigation_view: 'view'
		navigation_goto: 'go-to-ahead'
		navigation_approve: 'approve'
		navigation_refresh: 'refresh'
		navigation_collapseAll: 'collapse-all'
		navigation_expandAll: 'expand-all'
		navigation_previous: 'previous'
		navigation_next: 'next'
		navigation_disable: 'cancel'
		# Need Icons for these (requested to ux team)
		I_APPLY: 'restore'
		I_RELATEDREQUEST: 'checkin'
		I_TEST: 'maintenance'
		I_FILTER: 'filter'
		I_SHOW_EYE: 'view'
		I_SETTINGS: 'settings'
		REPORTS: 'reports'
		AUTHORIZE: 'authorize'
		CLEAR: 'delete'
		CLOSED: 'closed-folder'
		CA_DELETE: 'trash'
		FORMS: 'forms'
		GOTO: 'go-to-ahead'
		RESTORE: 'restore'
		WORKFLOW: 'workflow'
		ALPHA_SORT_ASC: 'alpha-sort-asc'
		ALPHA_SORT_DESC: 'alpha-sort-desc'
		SORT_NUMERIC_ASC: 'sort-numeric-asc'
		SORT_NUMERIC_DESC: 'sort-numeric-desc'
		SORT_ASC: 'sort-asc'
		SORT_DSC: 'sort-dsc'
		GO_TO_BACK: 'go-to-back'
		DOWN_TREND: 'down-trend'
		UP_TREND: 'up-trend'
		ATTACH: 'attach'
		ARCHIVE: 'archive'
		PASTE: 'paste'
		TAG: 'tag'
		XML: 'xml'
		ZIP_FILE: 'zip-file'
		TEXT_FILE: 'text-file'
		ELLIPSE: 'ellipse'
		VELLIPSIS: 'vellipsis'
		GRID: 'grid'
		TABLE: 'table'
		MAINTENANCE: 'maintenance'
		OPEN_FOLDER: 'open-folder'
		USER_MANAGE: 'user-manage'
		GROUP_MANAGE: 'group-manage'
		AUDIT: 'audit'
		CALCULATOR: 'calculator'
		QUERY: 'query'
		UNDO: 'undo'
		MEASURE: 'measure'
		CLOCK: 'clock'
		COLUMN_CHART: 'column-chart'
		BAR_CHART: 'bar-chart'
		PIE_CHART: 'pie-chart'
		LINE_GRAPH: 'line-graph'
		MAXIMIZE: 'maximize'
		NOTIFY: 'notify'
		FILTER_DELETE: 'filter-delete'
		MINIMIZE: 'minimize'
		COMMENT: 'comment'
		I_HIDE_EYE: 'hide'
		TREE_VIEW: 'tree'
		COMPASS: 'compass'
		GOVERNANCE: 'governance'
		POWER: 'power'
		PREVIOUS: 'previous'
		NEXT: 'next'

		SUCCESS: 'check'
		UNSUCCESS: 'alert'
		MANDATE: 'check-circle'
		NON_MANDATE: 'delete-circle'
		INCOMPLETE: 'page-delete'
		COMPLETED: 'check-circle'
		PENDING_INCOMPLETE: 'alert'
		BMP_FILE: 'bmp-file'
		GIF_FILE: 'gif-file'
		HTML_FILE: 'html-file'
		JPG_FILE: 'jpg-file'
		PNG_FILE: 'png-file'
		PPS_FILE: 'pps-file'
		PPT_FILE: 'ppt-file'
		RTF_FILE: 'rtf-file'
		TIFF_FILE: 'tiff-file'
		UNKNOWN_FILE: 'undefined-file'
		VSD_FILE: 'vsd-file'
		JUMP_DOWN: 'jump-down'
		JUMP_UP: 'jump_up'
		UNDERLINE: 'underline'
		BOLD: 'bold'
		ALIGN_RIGHT: 'align-right'
		ALIGN_LEFT: 'align-left'
		ALIGN_CENTER: 'align-center'
		LIST_BULLET: 'list-bullet'
		LIST_NUMBER: 'list-number'
		DECREASE_FONTSIZE: 'decrease-fontsize'
		INCREASE_FONTSIZE: 'increase-fontsize'
		ITALIC: 'italic'
		FONT_COLOR: 'font-color'
		TEXT_SELECTED: 'text-selected'
		DIMENSION: 'dimension'
		DETACH: 'detach'
		ATTACH: 'attach'
		ICON_ACTIVE: 'check-circle'
		ICON_INACTIVE: 'dash'
		PR: 'pr'
		PE: 'pe'
		ADMINISTRATOR: 'user-manage'
		EMAIL: 'email'
		CSV: 'csv'
		RESUME: 'power'
		LOCK: 'lock'
		REJECT: 'reject'
		EDITCAGID: 'edit'
		VIEW360: 'view'
		APPROVE: 'approve'
		RETURN: 'go-to-back'
		LINK: 'link'
		ADD: 'plus'
		APPROVAL: 'approve'
		UPDATE: 'edit'
		REWORK: 'go-to-back'
		REFER: 'user'
		NOT_SET: 'maintenance'
		SIMULATION: 'simulation'

	setMainCache: (maincache) ->
		@maincache = maincache
		return

	getMainCache: ->
		return @maincache

	updateMaincache: (perspectiveCache) ->
		props = perspectiveCache._myProperties
		uniqueKey = props.uniqueKey
		@maincache[uniqueKey] = perspectiveCache
		return

# index stands for sequence id if response is a list
	parseJsonToCache: (json, index) ->
		dt = Corefw.util.Data
		cache = {}
		@cacheWorker3 json, cache, index
		dt.cacheData3 cache
		return cache

	getLevelstr: (obj) ->
		levelstr = @widgetTypeToLevelstr[obj.widgetType]
		if not levelstr
			levelstr = 'field'
		return levelstr

# cache headers of grid or series of chart
	cacheDimension: (obj, cache, newObj) ->
		if obj.widgetType is 'HEADER' or obj.widgetType is 'SERIES'
			# add it to _ar as well

			props = cache._myProperties
			newObjProps = newObj._myProperties

			ar = props.columnAr
			if not ar
				ar = []
				props.columnAr = ar

			if obj.linkMap
				newObjProps.linkMap = obj.linkMap
			if obj.sortBy
				newObjProps.sortState = obj.sortBy
			if obj.filterType and obj.filterType isnt 'NONE' and obj.filterOperator
				newObjProps.filterOperator = obj.filterOperator
				newObjProps.filterValue = obj.filterValue

			ar.push newObj
		return

# same as cacheWorker2, but uses uipath instead of breadcrumb
# eliminate breadcrumb code
	cacheWorker3: (json, cache, index) ->
		cm = Corefw.util.Common

		levelstr = @getLevelstr json

		cacheConfig = @cacheConfigDef[levelstr]

		if not cacheConfig
			return

		if levelstr is 'application'
			newObj = cache
			newObj._myProperties = {}
		else
			# uniqueKey for perspective, name for other
			name = json.uniqueKey or json.name

			newObj =
				_myProperties:
					coretype: levelstr

			cache[name] = newObj
			@cacheDimension json, cache, newObj

		newObjProps = newObj._myProperties

		# copy properties from JSON object received from server into _myProperties
		cm.copyObjProperties newObjProps, json, cacheConfig.propsUsed, false

		# add index if respObj is list
		if index?
			newObjProps.respIndex = index

		renames = cacheConfig.renames
		if renames
			for oldName, newName of renames
				cm.objCopyProperty newObjProps, oldName, newName

		# save any nav info
		@cacheNav2 newObj
		@cacheEvents2 newObj

		# regressively
		nextLevelArray = json.allContents

		if nextLevelArray and nextLevelArray.length
			for item in nextLevelArray
				@cacheWorker3 item, newObj

		# cache toolbar and breadcrumb if exist
		@cacheTools json, newObj

		return

	cacheTools: (json, newObj) ->
		# cache toolbar if current component has a toolbar
		if json.toolbar
			@cacheWorker3 json.toolbar, newObj

		if json.breadcrumb
			@cacheWorker3 json.breadcrumb, newObj
		return

# for each nav property, add a breadcrumb
	cacheNav2: (cache) ->
		me = Corefw.util.Cache

		props = cache._myProperties
		navs = props.allNavigations

		#TODO: for compatibility with previous toolbar here, need refactor after toolbar seperated from nav
		toolbar = props.toolbar
		if toolbar and toolbar.allNavigations.length
			for toolbarBtn in toolbar.allNavigations
				toolbarBtn.isToolBar = true
			navs = navs.concat toolbar.allNavigations

		if props.widgetType is 'TOOLBAR' or props.widgetType is 'BREADCRUMB'
			for nav in navs
				nav.isToolBar = true

		newNavObj =
			_ar: navs

		props.navs = newNavObj

		# "navs" array has already been added, so just add breadcrumb property to each one
		if navs and navs.length
			for nav in navs
				newNavObj[nav.name] = nav
				me.cacheEvents2 nav
		return

	cacheEvents2: (cache) ->
		cm = Corefw.util.Common

		if cache._myProperties
			props = cache._myProperties
		else
			props = cache

		origevents = props.events
		if origevents and origevents.length
			# save the array in property _ar
			cm.objRenameProperty props, 'events', '_ar'
			props.events =
				_ar: props._ar
			delete props._ar

			# index each event by array type
			events = props.events
			ar = events._ar
			for ev in ar
				events[ev.type] = ev

		return

	cacheFilter: (cache, fn, result = []) ->
		for key, value of cache
			continue if key is '_myProperties'
			if fn key, value
				result.push value
			@cacheFilter value, fn, result
		return result