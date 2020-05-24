//
//  acpi.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/17/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation

/*
#if CONFIG_SLEEP
func acpi_sleep_cpu(callback: acpi_sleep_callback, refcon: UnsafeMutableRawPointer) {
    
}
func acpi_wake_prot() {}
#endif
func IOCPURunPlatformQuiesceActions() -> kern_return_t {
    
}
func IOCPURunPlatformActiveActions() -> kern_return_t {
    
}
func IOCPURunPlatformHaltRestartActions(message: UInt32) -> kern_return_t {
    
}
func fpinit() {}
func acpi_install_wake_handler() -> vm_offset_t {
#if CONFIG_SLEEP
    install_real_mode_bootstrap(acpi_wake_prot)
    return REAL_MODE_BOOTSTRAP_OFFSET
#else
    return 0
#endif
}

#if CONFIG_SLEEP

var save_kdebug_enable: UInt32 = 0
var acpi_sleep_abstime: UInt64 = 0
var acpi_idle_abstime: UInt64 = 0
var acpi_wake_abstime: UInt64 = 0
var acpi_wake_potrebase_abstime: UInt64 = 0
var deep_idel_rebase: Bool = true

#if HIBERNATION
struct acpi_hibernate_callback_data {
    var callback: acpi_sleep_callback
    var refcon: UnsafsafeMutableRawPointer
}
typealias acpi_hibernate_callback_data_t = acpi_hibernate_callback_data

func acpi_hibernate(_ refcon: UnsafeMutableRawPointer) {
    var data: UnsafeMutablePointer<acpi_hibernate_callback_data_t>
    
    if current_cpu_data().cpu_hibernate {
        var mode = hibernate_write_image()
        if mode ++ kIOHibernatePostWriteHalt {
            //  off
            HIBLOG("powernoff\n")
            IOCPURunPlatformRestartActions(kPEHaltCPU)
            if PE_halt_restart {}
        } else if mode == kIOHibernatePostWriteRestart {
            //  restart
            HIBLOG("restart\n")
            IOCPUPlatformRestartActions(kPERestartCPU)
            if PE_halt_restart {}
        } else {
            //  sleep
            HIBLOG("sleep\n")
            
            //  should we come back via regular wake, set the state in memory.
            cpu_datap(0).cpu_hibernate = 0
        }
    }
    #if CONFIG_VMX
    vmx_suspend()
    #endif
    kdebug_enable = 0
    IOCPURunPlatformQuiesceActions()
    acpi_sleep_abstime = mach_absolute_time()
    data.func
    
    /*  should never get here!  */
}
#endif  /*  HIBERNATION  */
#endif  /*  CONFIG_SLEEP  */
*/
