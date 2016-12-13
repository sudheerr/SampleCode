Ext.define 'Corefw.util.Formatter',
	alternateClassName: 'CorefwFormatter'
	singleton: true
	constructor: ->
		NUMBER_FONTSTYLE = ''
		NEGATIVE_VALUE_SIGN = '- '

		@varianceMap = 
			'DifferencePercentage': 'DifferencePercentage'
			'DifferenceValue': 'DifferenceValue'
			'ActualValue': 'NonControlValue'
			'AbsoluteDiffValue': 'AbsoluteDiffValue'

		@varianceNameMap = 
			'DifferencePercentage': 'DifferencePercentage'
			'DifferenceValue': 'DifferenceValue'
			'NonControlValue': 'ActualValue'
			'AbsoluteDiffValue': 'AbsoluteDiffValue'

		@formatBDMonthlyTimeMark = (value) ->
			p = new RegExp('~M')
			formattedString = CorefwFormatter.formatDate(value.split('-D')[0].split('-M')[0], if p.test(value) then 'ForDisplayM' else 'ForDisplayD')
			testStringList = value.split '~'
			if testStringList[5] is 'Daily'
				return formattedString
			formattedString + ' BD' + testStringList[4]

		@formatRelativeDate = (value, type) ->
			relativeTimeDisplayString = ''
			if value.indexOf(' (') > 1
				displayParts = value.split(' (')
				relativeTimeDisplayString = displayParts[0]
				timeMarkKey = displayParts[1].split(')')[0]
			else
				timeMarkKey = value
			timeMarkKeyDisplay = undefined
			if timeMarkKey.split('~M').length > 1
				timeMarkKeyDisplay = CorefwFormatter.formatBDMonthlyTimeMark(timeMarkKey)
			else
				timeMarkKeyDisplay = CorefwFormatter.formatDate timeMarkKey.split('~D')[0], 'ForDisplayD'
			relativeTimeDisplayString + ' (' + timeMarkKeyDisplay + ')'

		@formatDate = (value, type) ->
			dateValue = @parseDateValue(value)
			subtotalSuffix = ' - Sub Total'
			isSubtotal = Ext.String.endsWith value, subtotalSuffix
			temps = null
			if dateValue is null or dateValue is undefined or dateValue.toString() is 'NaN' or dateValue.toString() is 'Invalid Date'
				return value
			else if type is 'ForJavaMM'
				formattedDate = Ext.Date.format(dateValue, 'Y-n-j-H-i-s')
				formattedDateList = formattedDate.split('-')
				seperator = '~'
				return formattedDateList[0] + seperator + formattedDateList[1] + seperator + '0' + seperator + formattedDateList[2] + seperator + '0'
			else if type is 'ForDisplayD'
				returnDate = Ext.Date.format(dateValue, 'M j Y')
				returnDateArray = returnDate.split(' ')
				if returnDateArray[1].length is 1
					returnDate = returnDate.replace(returnDateArray[1], '0' + returnDateArray[1])
				return if isSubtotal then returnDate + subtotalSuffix else returnDate
			else if type is 'ForDisplayM'
				return Ext.Date.format(dateValue, 'M Y')
			else if type is 'ForDisplayMBD'
				temps = Ext.Date.format(dateValue, 'M-j-Y').split('-')
				return temps[0] + ' ' + temps[2] + ' BD' + temps[1]
			else if type is 'ForDisplayTimeMark'
				valueList = value.split('~')
				temps = Ext.Date.format(dateValue, 'M-j-Y').split('-')
				month = temps[0]
				day = temps[1]
				bd = valueList[4]
				year = temps[2]
				if value.indexOf('Monthly') > 0
					return month + ' ' + year + ' BD' + bd
				else if value.indexOf('Daily') > 0
					return month + ' ' + year + ' ' + day
				return month + ' ' + year + ' BD' + bd
			return

		@parseDateValue = (value) ->
			dateValue = null
			tmp = []
			str = undefined

			pad = (n) ->
				if n < 10 and n.toString().length is 1 then '0' + n else n

			dateValue = Ext.Date.parse value, 'Y-m-d'

			###*
			# IE Date parser needs '01' instead of '1' as month parameter, same logic to day parameter.
			###

			if !dateValue and value and typeof value is 'string'
				tmp = value.split('-')
				if tmp and tmp.length >= 3
					if tmp[2] <= 31 and tmp[2] >= 1
						str = tmp[0] + '-' + pad(parseInt(tmp[1])) + '-' + pad(parseInt(tmp[2]))
						dateValue = Ext.Date.parse(str, 'Y-m-d')
					else
						str = tmp[0] + '-' + pad(parseInt(tmp[1]) + '-' + 1)
						dateValue = Ext.Date.parse(str, 'Y-m')
			if dateValue is null or dateValue is 'NaN' or dateValue is undefined
				dateValue = Ext.Date.parse(value, 'Y-n-j-H-i-s')
			if dateValue is null or dateValue is 'NaN' or dateValue is undefined
				dateValue = new Date(value)
			if dateValue is null or dateValue is undefined or dateValue.toString() is 'NaN' or dateValue.toString() is 'Invalid Date'
				data = value.split('~')
				dataString = data[0] + '-' + pad(data[1])
				if pad(data[3]) != '00'
					dateValue = Ext.Date.parse(dataString + '-' + pad(data[3]), 'Y-m-d')
				else
					dateValue = Ext.Date.parse(dataString, 'Y-m')
			dateValue
			
		@getSpecailNum = (value) ->
			_value = (value + '').toUpperCase()
			specailNum = 
				'NAN': 'N/A'
				'+INFINITY': '+Infinity'
				'INFINITY': '+Infinity'
				'-INFINITY': '-Infinity'
			specailNum[_value]

		@formatDouble = (value) ->
			specailNum = @getSpecailNum(value)
			if specailNum
				return specailNum
			if value < 0
				'-' + Ext.util.Format.number Math.abs(value), '0,000.00'
			else
				Ext.util.Format.number value, '0,000.00'

		return this