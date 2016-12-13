# defines a file upload field
# contains another sub form and its own upload button
# the file has to be uploaded independently

Ext.define 'Corefw.view.form.field.FileUpload',
	extend: 'Ext.form.FieldContainer'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corefileupload'

	frame: false

	layout: 'hbox'
	cls: "#{Ext.baseCSSPrefix}corefileupload"
# enable or disable multiSelect files uploading
	multipleUpload: false

# enable or disable upload the files by itself
	uploadable: false

# limit the upload file types
	acceptFiles: []

	items: [
		xtype: 'filefield'
		buttonText: 'Select File...'
		name: 'file'
		flex: 1

	#Adding listeners to replace "C:\fakepath\" appearing in chrome in the uploadfield
		listeners:
			change: (field, value) ->
				value = []
				parent = field.up()
				isValidFileType = parent.isValidFileType
				validFileTypeReg = parent.validFileTypeReg
				for f in field.fileInputEl.dom.files
					if not isValidFileType f.name, validFileTypeReg
						# stop upload this field in request.js
						field.isInvalid = true
						Ext.Msg.alert 'Warning', "'#{f.name}' is not valid file type!"
						field.setRawValue ''
						return
					value.push f.name
				field.setRawValue value.join ','
				field.isInvalid = false
				uploadfield = field.up()
				# upload the files by itself
				if uploadfield.uploadable
					url = uploadfield.cache?._myProperties?.events?['ONCHANGE']?.url
					rq = Corefw.util.Request
					if url
						url = rq.objsToUrl3 url
						parent = Corefw.util.Uipath.uipathToParentComponent uploadfield.uipath
						postData = parent?.generatePostData?()
						opts =
							needFormSubmit: true
							filefields: [field]
						rq.sendRequest5 url, rq.processResponseObject, uploadfield.uipath, postData or {}, undefined, undefined, undefined, undefined, opts
				return
	]

	initComponent: ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			@items[0].buttonMargin = 8
			@items[0].msgTarget = 'under'
		@callParent arguments
		return

	generatePostData: ->
		fieldObj =
			name: @name
			value: null
		if @fileContents and @isStopUpload is false
			fileContents = @fileContents
			fileInfo = fileContents.fileInfo

			fieldObj =
				name: @name
				value:
					name: fileInfo.name
					size: fileInfo.size
					lastModifiedDate: fileInfo.lastModifiedDate.valueOf()
					mimeType: fileInfo.type
					data: fileContents.data

		return fieldObj

	afterRender: ->
		@callParent arguments
		props = @cache?._myProperties
		acceptFiles = props.acceptFiles or []
		if props
			@multipleUpload = props.multipleUpload
			@uploadable = props.uploadable or true
		fileField = @down('filefield')
		fileInputDom = fileField.fileInputEl.dom
		# make file field support multiple uploading
		if @multipleUpload
			fileInputDom.setAttribute 'multiple', 'multiple'
		# setting file types limitation information
		fileInputDom.title = "No file type limitation"
		this.setAcceptFile(acceptFiles, fileInputDom)
		fileInputDom.setAttribute 'name', @uipath
		mb = 1024 * 1024
		fileField.validator = ->
			fileHolder = @up()
			prop = fileHolder.cache?._myProperties
			maxUploadSize = prop.maxUploadSize or 0
			maxUploadTotalSize = prop.maxUploadTotalSize or 0
			if maxUploadSize or maxUploadTotalSize
				totalSize = 0
				for file in @fileInputEl.dom.files
					totalSize += file.size
					if (maxUploadSize and file.size >= maxUploadSize)
						return 'The maximum file upload size is ' + Math.round((maxUploadSize / mb) * 1000) / 1000 + 'MB'
					else if(maxUploadTotalSize and totalSize >= maxUploadTotalSize)
						return 'The maximum file upload total size is ' + Math.round((maxUploadTotalSize / mb) * 1000) / 1000 + 'MB'
			return true
		return

	setAcceptFile: (acceptFiles, fileInputDom) ->
		if acceptFiles.length >= 1
			@acceptFiles = acceptFiles
			types = acceptFiles.map (t)->
				t.replace '.', ''
			fileInputDom.title = 'Could only upload: ' + types.join '|'
			fileInputDom.setAttribute 'accept', acceptFiles.join ','
			@validFileTypeReg = new RegExp '[^\\.]+[\\.](' + types.join('|') + ')$'
		return

	isValidFileType: (filename, regExp) ->
		return true if not regExp
		regExp.test filename