Ext.define 'Corefw.view.layout.Layout',
	singleton: true,
	layoutClassByType:
		table: 'Corefw.view.layout.AbsoluteLayoutManager'
		vbox: 'Corefw.view.layout.BoxLayoutManager'
		hbox: 'Corefw.view.layout.BoxLayoutManager'
		accordion: 'Corefw.view.layout.AccordionLayoutManager'
		tab: 'Corefw.view.layout.TabLayoutManager'
		navigator: 'Corefw.view.layout.NavigatorLayoutManager'
	genLayoutType: (widgetType) ->
		if /^(FORM_BASED_ELEMENT|FIELDSET|BAR_ELEMENT)$/.test widgetType
			return "table"
		else if widgetType is 'VIEW' or widgetType is 'COMPOSITE_ELEMENT'
			return "vbox"
		return
	create: (comp, props) ->
		props = props or comp.cache?._myProperties or {}
		layoutType = props?.layout?.type?.toLowerCase()
		widgetType = props.widgetType
		if not layoutType
			return

		if layoutType is 'default'
			layoutType = @genLayoutType widgetType

		layoutClass = @layoutClassByType[layoutType]

		if not layoutClass
			console.error "Can't find layoutManager for layout type", layoutType
			return

		# below is a temp solution due to legacy code, to be removed after relativev legacy code is re-factored
		if layoutType is 'table'
			props.isAbsoluteLayout = true
		else if layoutType is 'vbox'
			props.isStackedLayout = true

		return Ext.create layoutClass, {comp: comp, type: layoutType}