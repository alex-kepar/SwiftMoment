//
//  Moment.swift
//  SwiftMoment
//
//  Created by Adrian on 19/01/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

// Swift adaptation of Moment.js http://momentjs.com
// Github: https://github.com/moment/moment/

import Foundation

/**
Returns a moment representing the current instant in time at the current timezone

- parameter timeZone:   An NSTimeZone object
- parameter locale:     An NSLocale object

- returns: A moment instance.
*/
public func moment(timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment {
	return Moment(timeZone: timeZone, locale: locale)
}

public func utc() -> Moment {
	let zone = NSTimeZone(abbreviation: "UTC")!
	return moment(zone)
}

/**
Returns an Optional wrapping a Moment structure, representing the
current instant in time. If the string passed as parameter cannot be
parsed by the function, the Optional wraps a nil value.

- parameter stringDate: A string with a date representation.
- parameter timeZone:   An NSTimeZone object (or nil, in this case uses the default timeZone)
- parameter locale:     An NSLocale object (or nil, in this case uses the auto-updating current locale)

- returns: <#return value description#>
*/
public func moment(stringDate: String,
                   timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment? {
	
	let formatter = NSDateFormatter()
	formatter.timeZone = timeZone
	formatter.locale = locale
	let isoFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
	
	// The contents of the array below are borrowed
	// and adapted from the source code of Moment.js
	// https://github.com/moment/moment/blob/develop/moment.js
	let formats = [
		isoFormat,
		"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'",
		"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'",
		"yyyy-MM-dd'T'HH:mm:ss.SSSZ",
		"yyyy-MM-dd",
		"h:mm:ss A",
		"h:mm A",
		"MM/dd/yyyy",
		"MMMM d, yyyy",
		"MMMM d, yyyy LT",
		"dddd, MMMM D, yyyy LT",
		"yyyyyy-MM-dd",
		"yyyy-MM-dd",
		"GGGG-[W]WW-E",
		"GGGG-[W]WW",
		"yyyy-ddd",
		"HH:mm:ss.SSSS",
		"HH:mm:ss",
		"HH:mm",
		"HH"
	]
	
	for format in formats {
		formatter.dateFormat = format
		
		if let date = formatter.dateFromString(stringDate) {
			return Moment(date: date, timeZone: timeZone, locale: locale)
		}
	}
	return nil
}

public func moment(stringDate: String,
                   dateFormat: String,
                   timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment? {
	let formatter = NSDateFormatter()
	formatter.dateFormat = dateFormat
	formatter.timeZone = timeZone
	formatter.locale = locale
	if let date = formatter.dateFromString(stringDate) {
		return Moment(date: date, timeZone: timeZone, locale: locale)
	}
	return nil
}

/**
Builds a new Moment instance using an array with the following components,
in the following order: [ year, month, day, hour, minute, second ]

- parameter params:   An array of integer values as date components
- parameter timeZone: An NSTimeZone object
- parameter locale:   An NSLocale object

- returns: An optional wrapping a Moment instance
*/
public func moment(params: [Int],
                   timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment? {
	if params.count > 0 {
		let calendar : NSCalendar
		if let tz = timeZone {
			calendar = NSCalendar.currentCalendar()
			calendar.timeZone = tz
		} else {
			calendar = Moment.defaultCalendar
		}
		
		let components = NSDateComponents()
		components.year = params[0]
		
		if params.count > 1 {
			components.month = params[1]
			if params.count > 2 {
				components.day = params[2]
				if params.count > 3 {
					components.hour = params[3]
					if params.count > 4 {
						components.minute = params[4]
						if params.count > 5 {
							components.second = params[5]
						}
					}
				}
			}
		}
		
		if let date = calendar.dateFromComponents(components) {
			return moment(date, timeZone: timeZone, locale: locale)
		}
	}
	return nil
}

public func moment(dict: [String: Int],
                   timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment? {
	if dict.count > 0 {
		var params = [Int]()
		if let year = dict["year"] {
			params.append(year)
		}
		if let month = dict["month"] {
			params.append(month)
		}
		if let day = dict["day"] {
			params.append(day)
		}
		if let hour = dict["hour"] {
			params.append(hour)
		}
		if let minute = dict["minute"] {
			params.append(minute)
		}
		if let second = dict["second"] {
			params.append(second)
		}
		return moment(params, timeZone: timeZone, locale: locale)
	}
	return nil
}

public func moment(milliseconds: Int) -> Moment {
	return moment(NSTimeInterval(milliseconds / 1000))
}

public func moment(seconds: NSTimeInterval) -> Moment {
	let interval = NSTimeInterval(seconds)
	let date = NSDate(timeIntervalSince1970: interval)
	return Moment(date: date)
}

public func moment(date: NSDate,
                   timeZone: NSTimeZone? = nil,
                   locale: NSLocale? = nil) -> Moment {
	return Moment(date: date, timeZone: timeZone, locale: locale)
}

public func moment(moment: Moment) -> Moment {
	return Moment(date: moment.date, timeZone: moment.timeZone_, locale: moment.locale_)
}

public func past() -> Moment {
	return Moment(date: NSDate.distantPast())
}

public func future() -> Moment {
	return Moment(date: NSDate.distantFuture())
}

public func since(past: Moment) -> Duration {
	return moment().intervalSince(past)
}

public func maximum(moments: Moment...) -> Moment? {
	return moments.reduce(nil) { max, current in
		max==nil || current > max! ? current : max
	}
}

public func minimum(moments: Moment...) -> Moment? {
	return moments.reduce(nil) { min, current in
		min==nil || current < min! ? current : min
	}
}

/**
Internal structure used by the family of moment() functions.
Instead of modifying the native NSDate class, this is a
wrapper for the NSDate object. To get this wrapper object, simply
call moment() with one of the supported input types.
*/
public struct Moment: Comparable {
	public static let minuteInSeconds = 60
	public static let hourInSeconds = 3600
	public static let dayInSeconds = 86400
	public static let weekInSeconds = 604800
	public static let monthInSeconds = 2592000
	public static let yearInSeconds = 31536000
	
	public let date: NSDate
	private let timeZone_ : NSTimeZone?
	private let locale_ : NSLocale?
	static var _calendars = [String:NSCalendar]()
	static var gregorianCalendar : NSCalendar = Moment._gregorianCalendar()
	
	public var timeZone: NSTimeZone {
		return timeZone_ ?? Moment.defaultTimeZone
	}
	public var locale: NSLocale {
		return locale_ ?? Moment.defaultLocale
	}
	
	public static let defaultCalendar = NSCalendar.currentCalendar()
	public static let defaultTimeZone = NSTimeZone.defaultTimeZone()
	public static let defaultLocale = NSLocale.autoupdatingCurrentLocale()
	
	init(date: NSDate = NSDate(),
	     timeZone: NSTimeZone? = nil,
	     locale: NSLocale? = nil) {
		self.date = date
		self.timeZone_ = timeZone
		self.locale_ = locale
	}
	
	/// Returns the year of the current instance.
	public var year: Int {
		return calendar().component(.Year, fromDate: date)
	}
	
	/// Returns the month (1-12) of the current instance.
	public var month: Int {
		return calendar().component(.Month, fromDate: date)
	}
	
	/// Returns the name of the month of the current instance, in the current locale.
	public var monthName: String {
		let formatter = NSDateFormatter()
		formatter.locale = locale
		return formatter.monthSymbols[month - 1]
	}
	
	public var day: Int {
		return calendar().component(.Day, fromDate: date)
	}
	
	public var hour: Int {
		return calendar().component(.Hour, fromDate: date)
	}
	
	public var minute: Int {
		return calendar().component(.Minute, fromDate: date)
	}
	
	public var second: Int {
		return calendar().component(.Second, fromDate: date)
	}
	
	public var weekday: Int {
		return calendar().component(.Weekday, fromDate: date)
	}
	
	public var weekdayName: String {
		let formatter = NSDateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEEE"
		formatter.timeZone = timeZone
		return formatter.stringFromDate(date)
	}
	
	public var weekdayOrdinal: Int {
		return calendar().component(.WeekdayOrdinal, fromDate: date)
	}
	
	public var weekOfYear: Int {
		return calendar().component(.WeekOfYear, fromDate: date)
	}
	
	public var quarter: Int {
		return calendar().component(.Quarter, fromDate: date)
	}
	
	// Methods
	
	public func get(unit: TimeUnit) -> Int? {
		switch unit {
		case .Seconds:
			return second
		case .Minutes:
			return minute
		case .Hours:
			return hour
		case .Days:
			return day
		case .Weeks:
			return weekOfYear
		case .Months:
			return month
		case .Quarters:
			return quarter
		case .Years:
			return year
		}
	}
	
	public func get(unitName: String) -> Int? {
		if let unit = TimeUnit(rawValue: unitName) {
			return get(unit)
		}
		return nil
	}
	
	public func format(dateFormat: String = "yyyy-MM-dd HH:mm:ss ZZZZ") -> String {
		let formatter = NSDateFormatter()
		let cal = calendar()
		formatter.calendar = cal
		formatter.dateFormat = dateFormat
		formatter.timeZone = cal.timeZone
		formatter.locale = cal.locale
		return formatter.stringFromDate(date)
	}
	
	public func isEqualTo(moment: Moment) -> Bool {
		return date.isEqualToDate(moment.date)
	}
	
	public func intervalSince(moment: Moment) -> Duration {
		let interval = date.timeIntervalSinceDate(moment.date)
		return Duration(value: interval)
	}
	
	public func add(value: Int, _ unit: TimeUnit) -> Moment {
		let components = NSDateComponents()
		switch unit {
		case .Years:
			components.year = value
		case .Quarters:
			components.month = 3 * value
		case .Months:
			components.month = value
		case .Weeks:
			components.day = 7 * value
		case .Days:
			components.day = value
		case .Hours:
			components.hour = value
		case .Minutes:
			components.minute = value
		case .Seconds:
			components.second = value
		}
		if let newDate = Moment.gregorianCalendar.dateByAddingComponents(components, toDate: date,
		                                            options: []) {
			return Moment(date: newDate, timeZone: timeZone_, locale: locale_)
		}
		return self
	}
	
	public func add(value: NSTimeInterval, _ unit: TimeUnit) -> Moment {
		let seconds = Moment.convert(value, unit)
		let interval = NSTimeInterval(seconds)
		let newDate = date.dateByAddingTimeInterval(interval)
		return Moment(date: newDate, timeZone: timeZone_, locale: locale_)
	}
	
	public func add(value: Int, _ unitName: String) -> Moment {
		if let unit = TimeUnit(rawValue: unitName) {
			return add(value, unit)
		}
		return self
	}
	
	public func add(duration: Duration) -> Moment {
		return add(duration.interval, .Seconds)
	}
	
	public func subtract(value: NSTimeInterval, _ unit: TimeUnit) -> Moment {
		return add(-value, unit)
	}
	
	public func subtract(value: Int, _ unit: TimeUnit) -> Moment {
		return add(-value, unit)
	}
	
	public func subtract(value: Int, _ unitName: String) -> Moment {
		if let unit = TimeUnit(rawValue: unitName) {
			return subtract(value, unit)
		}
		return self
	}
	
	public func subtract(duration: Duration) -> Moment {
		return subtract(duration.interval, .Seconds)
	}
	
	public func isCloseTo(moment: Moment, precision: NSTimeInterval = 300) -> Bool {
		// "Being close" is measured using a precision argument
		// which is initialized a 300 seconds, or 5 minutes.
		let delta = intervalSince(moment)
		return abs(delta.interval) < precision
	}
	
	public func startOf(unit: TimeUnit) -> Moment {
/*		let cal = calendar()
		let determinantUnit: NSCalendarUnit
		let unitBase: Int
		
		switch unit {
		case .Years:
			determinantUnit = .Month
			unitBase = 1
			
		case .Quarters:
			determinantUnit = .Month
			unitBase = 1
			
		case .Months:
			determinantUnit = .Day
			unitBase = 1
			
		case .Weeks:
			determinantUnit = .Weekday
			unitBase = 1
			
		case .Days:
			determinantUnit = .Hour
			unitBase = 0
			
		case .Hours:
			determinantUnit = .Minute
			unitBase = 0
			
		case .Minutes:
			determinantUnit = .Second
			unitBase = 0
			
		case .Seconds:
			return self
		}
		
		let current = cal.component(determinantUnit, fromDate: date)
		if current <= unitBase {
			return self
		}
		let decrement: Int
		if unit == .Quarters {
			decrement = -((current-1) % 3)
			if decrement == 0 {
				return self
			}
		} else {
			decrement = -(current - unitBase)
		}

		guard let newDate = cal.dateByAddingUnit(determinantUnit, value: decrement, toDate: date, options: []) else {
			return self
		}
		
		return Moment(date: newDate, timeZone: timeZone_, locale: locale_)
		*/
		let components = calendar().components([.Year, .Month, .Weekday, .Day, .Hour, .Minute, .Second],
		                                fromDate: date)
		switch unit {
		case .Seconds:
			return self
		case .Years:
			components.month = 1
			fallthrough
		case .Quarters, .Months, .Weeks:
			if unit == .Weeks {
				components.day -= (components.weekday - 2)
			} else {
				components.day = 1
			}
			fallthrough
		case .Days:
			components.hour = 0
			fallthrough
		case .Hours:
			components.minute = 0
			fallthrough
		case .Minutes:
			components.second = 0
		}
		guard let newDate = calendar().dateFromComponents(components) else {
			return self
		}
		return Moment(date: newDate, timeZone: timeZone_, locale: locale_)
	}
	
	public func startOf(unitName: String) -> Moment {
		if let unit = TimeUnit(rawValue: unitName) {
			return startOf(unit)
		}
		return self
	}
	
	public func endOf(unit: TimeUnit) -> Moment {
		// TODO: this is a *very expensive* implementation
		return startOf(unit).add(1, unit).subtract(1.seconds)
	}
	
	public func endOf(unitName: String) -> Moment {
		if let unit = TimeUnit(rawValue: unitName) {
			return endOf(unit)
		}
		return self
	}
	
	public func epoch() -> NSTimeInterval {
		return date.timeIntervalSince1970
	}
	
	// Private methods
	
	static func convert(value: Double, _ unit: TimeUnit) -> Double {
		switch unit {
		case .Seconds:
			return value
		case .Minutes:
			return value * 60
		case .Hours:
			return value * 3600 // 60 minutes
		case .Days:
			return value * 86400 // 24 hours
		case .Weeks:
			return value * 605800 // 7 days
		case .Months:
			return value * 2592000 // 30 days
		case .Quarters:
			return value * 7776000 // 3 months
		case .Years:
			return value * 31536000 // 365 days
		}
	}

	func calendar() -> NSCalendar {
		if timeZone_ == nil && locale_ == nil {
			return Moment.defaultCalendar		// common case
		}
		let key =
			(locale_ == nil) ? timeZone_!.name :
			(timeZone_ == nil) ? locale_!.localeIdentifier :
			timeZone_!.name + locale_!.localeIdentifier

		// TODO: lock
		if let cal = Moment._calendars[key] {
			return cal
		}

		let cal = NSCalendar.currentCalendar()
		if let tz = timeZone_ {
			cal.timeZone = tz
		}
		if let locale = locale_ {
			cal.locale = locale
		}
		Moment._calendars[key] = cal
		return cal
	}

	static func _gregorianCalendar() -> NSCalendar {
		let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		cal.timeZone = NSTimeZone(name: "UTC")!
		return cal
	}
}

extension Moment: CustomStringConvertible {
	public var description: String {
		return format()
	}
}

extension Moment: CustomDebugStringConvertible {
	public var debugDescription: String {
		return description
	}
}
