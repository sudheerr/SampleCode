Ext.define 'Corefw.model.PivotValueConfigItem',
	extend: 'Corefw.model.PivotConfigItem'
	
	fields: [
		{name: 'aggregation', type: 'string', defaultValue: "Sum"}
		{name: 'variance', type: 'boolean', defaultValue: false}
		{name: 'varianceType', type: 'string'}
		{name: 'varianceTimeMark', type: 'string'}
		{name: 'valueItemId', convert: (value, record) ->
			if record.get 'variance'
				return '' if not record.getTimeMarkObj()
				[record.get 'path'
				 record.get 'varianceType'
				 record.getTimeMarkObj().key].join '~'
			else
				return record.get 'path'
		}
		{name: 'timeMarks', persist: false}
		{name: 'fullText', persist: false, convert: (value, record) ->
			if record.get 'variance'
				return '' if not record.getTimeMarkObj()
				varianceTypeName = CorefwFormatter.varianceNameMap[record.get('varianceType')]
				return "#{record.get('name')} (#{varianceTypeName} #{record.getTimeMarkObj().formatted})"
			else
				return record.get 'name'
		}
	]

	idProperty: 'valueItemId'

	getTimeMarkObj: ->
		timeMarkText = @get 'varianceTimeMark'
		for freq, freqObj of @get 'timeMarks'
			for timePoint, timeMark of freqObj
				if timePoint is timeMarkText
					return timeMark

	calcFields: ->
		@set 'valueItemId', ''
		@set 'fullText', ''

	copyFrom: ->
		@callParent arguments
		@calcFields()