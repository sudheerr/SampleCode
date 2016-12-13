### 
LayoutManager is an abstract class for managing layouts of Core widget container. So far uses as below
View - BoxLayoutManager(VBox)
ElementForm - BoxLayoutManager(VBox)/AbsoluteLayoutManager
FieldSet - AbsoluteLayoutManager
Toolbar - AbsoluteLayoutManager/Ext build-in toolbar layout
CompositeElement - BoxLayoutManager/TabLayoutManager/AccordionLayoutManager
###
Ext.define 'Corefw.view.layout.LayoutManager',
	#relative comp which layout works on
	comp: null
#layout type
	type: null
	constructor: (config) ->
		comp = config.comp
		cls = [
			"core-#{config.type}-layout"
			comp.xtype
		]
		collapsible = comp.cache?._myProperties?.collapsible
		if collapsible
			cls.push "collapsible-ct"
		comp.addCls cls
		# comp.cls = cls
		@comp = config.comp
		@type = config.type
		return
# front end layout configs validation
	validate: ->
		return true
# First time do the layout, add all existing contents. usually invoked at container.afterrender
	initLayout: ->
		return

# Add a new content, usually invoked at container.replaceChild
# @param: contentDef        content definition
# @param: index             index of the content
# @event: beforeAddContent  be triggered before add the content
# @event: afterAddContent   be triggered after add the content
	add: (contentDef, index, isAncestorUpdating) ->
		me = @
		comp = me.comp
		contentDefs = comp.contentDefs or []

		# for those dynamically added content
		existedContentDef = Ext.Array.findBy contentDefs, (conDef) ->
			return conDef.cache is contentDef.cache
		if existedContentDef and index is undefined
			index = Ext.Array.indexOf contentDefs, existedContentDef
		else
			if index > -1
				Ext.Array.insert contentDefs, index, contentDef
			else
				contentDefs.push contentDef

		contentProps = contentDef?.cache?._myProperties
		if contentProps?.isRemovedFromUI
			return

		if Ext.isFunction me.beforeAddContent
			me.beforeAddContent contentDef, index

		comp = me.comp
		if index > -1
			content = comp.insert index, contentDef
		else
			content = comp.add contentDef

		if Ext.isFunction me.afterAddContent
			me.afterAddContent content, contentDef, index, isAncestorUpdating

		this.resize()
		return

#TODO add toolbar to top
	addToolbar: (toolbarDef) ->
		return

# Remove a content, usually invoked before LayoutManager.add
# @event: beforeRemoveContent   be triggered before remove the content
	remove: (content) ->
		if not content
			return
		me = @
		comp = me.comp
		contentDefs = comp.contentDefs
		contentDef = Ext.Array.findBy contentDefs, (contentDef) ->
			return contentDef.cache._myProperties.uipath is content.uipath
		Ext.Array.remove contentDefs, contentDef


		if Ext.isFunction me.beforeRemoveContent
			me.beforeRemoveContent content

		comp.remove content
		return
	removeAll: ->
		return
	resize: ->
		return

# update content defs when calling #updateUIData
	updateContentDefs: (contentDefs) ->
		@comp.contentDefs = contentDefs
		return

# Get content index of its container
	getContentIndex: (content) ->
		return @comp.items.indexOf content