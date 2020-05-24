//
//  time_value.swift
//  Translation:
//      osfmk/mach/time_value.h
//  Dependencies:
//      osfmk/mach/machine/vm_types.h
//          osfmk/mach/i386/vm_types.h
//          osfmk/mach/arm/vm_types.h
//              bsd/i386/_types.h
//              osfmk/mach/i386/vm_param.h
//              stdint.h
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/8/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
/*
 *  Time value returned by kernel.
 */
struct time_value {
    var seconds: Int32
    var microseconds: UInt32
}

typealias time_value_t = time_value

/*
 *  macros to manipulate time values.  Assume that time values
 *  are normalized (microseconds <= 999999).
 */
let TIME_MICROS_MAX: UInt32 = 1_000_000

func time_value_add_usec(_ val: inout time_value, micros: UInt32) {
    val.microseconds += micros
    if  val.microseconds >= TIME_MICROS_MAX {
        val.microseconds -= TIME_MICROS_MAX
        val.seconds += 1
    }
}

func time_value_add(_ result: inout time_value, addend: time_value) {
    result.microseconds += addend.microseconds
    result.seconds += addend.seconds
    if result.microseconds >= TIME_MICROS_MAX {
        result.microseconds -= TIME_MICROS_MAX
        result.seconds += 1
    }
}
*/
