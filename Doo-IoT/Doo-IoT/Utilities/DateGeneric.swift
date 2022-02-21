//
//  DateGeneric.swift
//  BaseProject
//
//  Created by MAC240 on 04/06/18.
//  Copyright © 2018 MAC240. All rights reserved.
//

import Foundation

enum DateFormates {

    case system

    case day
    case month
    case dayMonth

    case yyyy_MM_dd
    case ceritficateSourceDate

    case yyyy_MM_dd_T_HH_mm_ss_SSSZ
    case dd_MMM_yyyy_HH_mm_ss_a
    case ddMMMMyyyAThhMMa
    case ddMMMyyyyAThhMMa
    case MMM_dd
    case DD_MMM_yyyy_hh_mm_a
    case ddMMM
    case hhMMa
    case MMMM_YYYY
    case MMM_YYYY
    case monthWithDateWithoutSpace
    case ddSpaceMMspaceYYYY
    case timeWithAMPM
    case hhmmss
    case ddSpaceMMspaceYY
    case yyyy_mm_dd_hh_mm_ss
    case eee_dd_mmm_yyyy_hh_mm_ss_z
    case eee_dd_mmm_yyyy_hh_mm_ss
    case eee_space
    case HHmmss
    case eee_dd_mmm_yyyy_HH_mm_00_z
    var text: String{
        switch self {
        case .system:
            return "yyyy-MM-dd HH:mm:ss Z"
        case .day:
            return "dd"
        case .month:
            return "MMM"
        case .dayMonth:
            return "dd MMM"
            
        case .yyyy_MM_dd:
            return "yyyy-MM-dd"
        case .ceritficateSourceDate:
            return "yyyy-MM-dd'T'HH:mm:ssZ"
            
        case .yyyy_MM_dd_T_HH_mm_ss_SSSZ:
            return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case .dd_MMM_yyyy_HH_mm_ss_a:
            return "dd-MMM-yyyy hh:mm:ss a" // "dd-MMM-yyyy hh:mm:ss a"
        case .ddMMMMyyyAThhMMa:
            return "dd MMMM yyyy | hh:mm a"
        case .ddMMMyyyyAThhMMa:
            return "dd MMM yyyy, | hh:mm a"
        case .MMM_dd:
            return "MMM dd"
        case .DD_MMM_yyyy_hh_mm_a:
            return "dd MMM yyyy hh:mm a"
        case .ddMMM:
            return "dd-MMM"
        case .hhMMa:
            return "hh:mm\na"
        case .MMMM_YYYY:
            return "MMMM-yyyy"
        case .MMM_YYYY:
            return "MMMM yyyy"
        case .monthWithDateWithoutSpace:
            return "MMMdd"
        case .ddSpaceMMspaceYYYY:
            return "dd MMM yyyy"
        case .timeWithAMPM:
            return "hh:mm a"
        case .hhmmss:
            return "hh:mm:ss"
        case .ddSpaceMMspaceYY:
            return "dd MMM yy"
        case .yyyy_mm_dd_hh_mm_ss:
            return "yyyy-MM-dd hh:mm:ss"
        case .eee_dd_mmm_yyyy_hh_mm_ss_z:
            return "EEE, dd MMM yyyy HH:mm:ss z"
        case .eee_space:
            return "EEE, "
        case .eee_dd_mmm_yyyy_hh_mm_ss:
            return "EEE, dd MMM yyyy HH:mm:ss"
        case.HHmmss:
            return "HH:mm:ss"
        case .eee_dd_mmm_yyyy_HH_mm_00_z:
            return "EEE, dd MMM yyyy HH:mm:00 z"
        }

    }
}

extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

extension Int {
    // convert seconds(supported by Swift) to milleseconds(supported by server)
    var secondsToMs: Int { return self * 1000 }
    // convert milleseconds(supported by server) to seconds(supported by Swift)
    var msToSeconds: Int { return self / 1000 }
    var toTimeInterval: TimeInterval { return TimeInterval(self) }
}

extension String {
    func getDate(format: DateFormates) -> Date? {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = format.text
        guard let date = dateFormator.date(from: self) else { return nil }
        return date
    }
}

extension Date {
    func getDateInString(withFormat format: DateFormates, abbreviation:String="") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.text
        if !abbreviation.isEmpty{
            formatter.timeZone = TimeZone.init(abbreviation: abbreviation)
        }
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

}

extension Int {
    func getDateUsingTimestamp() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
    
    // convert from server time interval to Date String
    // convert milleseconds(supported by server) to seconds(supported by Swift)
    func getDateByMSecsToSecs() -> Date {
        return Date(timeIntervalSince1970: self.msToSeconds.toTimeInterval)
    }
    
    func getDateStringByMSecsToSecs(format: DateFormates) -> String {
        let date = Date(timeIntervalSince1970: self.msToSeconds.toTimeInterval)
        return date.getDateInString(withFormat: format)
    }
}
