//
//  clock_types.swift
//  Translation:
//      osfmk/mach/clock_types.h
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/4/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
struct ClockTypes {
    typealias alarm_type_t = Int32          /* alarm time type */
    typealias Sleep_type_t = Int32          /* sleep time type */
    typealias clock_id_t = Int32            /* clock identification type */
    typealias clock_flavor_t = Int32        /* clock favor type */
    typealias clock_attr_t = Int32     /* clock attribute type */
    typealias clock_res_t = Int32           /* clock resolution type */
    
    /*
     *  Normal time specification used by the kernel cock facility.
     */
    struct mach_timespec {
        var tv_sec: UInt32          /* seconds */
        var tv_nsec: clock_res_t    /* nanoseconds */
    }
    /**********************************************************
    enum ClockID {
        case system
        case calendar
        case realtime
    }
     */
    //  FIXME:  Should be an enum as above?
    static let SYSTEM_CLOCK: UInt8 = 0
    static let CALENDAR_CLOCK: UInt8 = 1
    static let REALTIME_CLOCK: UInt8 = 0
    /**********************************************************/
    
    /**********************************************************
     * Attribute names
    enum AttributeNames: Int32 {
        case getTimeRes = 1     /* get_time call resolution */
        /*                2      * was map_time call resolution */
        case alarmCurRes = 3    /* current alarm resolution */
        case alarmMinRes        /* minimum alarm resolution */
        case alarmMaxRes        /* maximum alarm resolution */
    }
    */
    // FIXME:  Should be an enum as above?
    static let CLOCK_GET_TIME_RES: UInt8 = 1    /* get_time call resolution */
    /*                                           * was map_time call resolution */
    static let CLOCK_ALARM_CURRES: UInt8 = 3    /* current alarm resolution */
    static let CLOCK_ALARM_MINRES: UInt8 = 4    /* minimum alarm resolution */
    static let CLOCK_ALARM_MAXRES: UInt8 = 5    /* maximum alarm resolution */
    /**********************************************************/
    
    /**********************************************************/
    //  FIXME:  should be an enum?
    static let nsecPerUsec:UInt64 = 1_000           /* nanoseconds per microsecond */
    static let usecPerSec:UInt64 = 1_000_000        /* microseconds per second */
    static let nsecPerSec:UInt64 = 1_000_000_000    /* nanoseconds per second */
    static let nsecPerMsec:UInt64 = 1_000_000       /* nanoseconds per millisecond */
    /**********************************************************/
    static func bad_mach_timespec(_ time: mach_timespec) -> Bool {
        return time.tv_nsec < 0 || time.tv_nsec >= UInt32(nsecPerSec) ? true : false
    }
    /* t1 <=> t2, also (t1 - t2) in nsec with max of +- 1 sec */
    static func cmp_mach_timespec(_ t1: mach_timespec, _ t2: mach_timespec) -> Int32 {
        return t1.tv_sec > t2.tv_sec ? Int32(+nsecPerSec) : t1.tv_sec < t2.tv_sec ? Int32(nsecPerSec) * -1 : t1.tv_nsec - t2.tv_nsec
    }
    
    /* t1 += t2 */
    static func add_mach_timespec(_ t1: inout mach_timespec, t2: mach_timespec) {
            t1.tv_nsec = t1.tv_nsec + t2.tv_nsec
            if t1.tv_nsec >= Int32(nsecPerSec) {
                t1.tv_nsec = t1.tv_nsec - Int32(nsecPerSec)
                t1.tv_sec = t1.tv_sec + 1
            }
            t1.tv_sec = t1.tv_sec + t2.tv_sec
    }
    
    /* t1 -= t2 */
    static func sub_mach_timespec(_ t1: inout mach_timespec, t2: mach_timespec) {
        t1.tv_nsec = t1.tv_nsec - t2.tv_nsec
        if  t1.tv_nsec < 0 {
            t1.tv_nsec = t1.tv_nsec + Int32(nsecPerSec)
            t1.tv_sec = t1.tv_sec - 1
        }
        t1.tv_sec = t1.tv_sec - t2.tv_sec
    }
    
    enum AlarmParameter: UInt8 {
        case alrmtype = 0xff        /* type (8-bit field) */
        case time_absolute = 0x00   /* absolute time */
        case time_relative = 0x01   /* relative time */
        
        func bad_alrmtype() -> Bool {
            return (self.rawValue &~ AlarmParameter.time_relative.rawValue) != 0
        }
    }
}
*/
