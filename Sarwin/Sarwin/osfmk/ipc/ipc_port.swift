//
//  ipc_port.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/11/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation

/*
/*
 *  A receive right (port) can be in four states:
 *    1) dead (not active, ip_timestamp has death time)
 *    2) in a space (ip_receiver_name != 0, ip_receiver points
 *    to the space but doesn't hold a ref for it)
 *    3) in transit (ip_receiver_name == 0, ip_destination points
 *    to the destination port and holds a ref for it)
 *    4) in limbo (ip_receiver_name == 0, ip_destination == IP_NULL)
 *
 *  If the port is active, and ip_receiver points to some space,
 *  then ip_receiver_name != 0, and that space holds receive rights.
 *  If the port is not active, then ip_timestamp contains a timestamp
 *  taken when the port was destroyed.
 */

typealias ipc_port_timestamp_t = UInt16

struct ipc_port: OptionSet {
    /*
     *  Initial sub-structure in common with ipc-pset
     *  First element is an ipc_object second is a
     *  message queue
     */
    let ip_object: ipc_object
    let ip_messages: ipc_mqueue
    
    enum Data {
        case receiver(UnsafePointer<ipc_space>)
        case destination(UnsafePointer<ipc_port>)
        case timestamp(ipc_port_timestamp_t)
    }
    let data: Data
    
    indirect enum kData {
        case kObject(ipc_kobject)
        case imp_task(ipc_importance_task_t)
        case sync_inheritor_port(ipc_port_t)
        case sync_inheritor_knote(UnsafePointer<kNote>)
        case sync_inheritor_ts(UnsafePointer<turnstile>)
    }
    let kData: kData
    
    let ip_nsrequest: UnsafePointer<ipc_port>
    let ip_pdrequest: UnsafePointer<ipc_port>
    let ip_requests: UnsafePointer<ipc_port_request>
    
    enum kData2 {
        case premsg(UnsafePointer<ipc_kmsg>)
        case send_turnstile(UnsafePointer<turnstile>)
        case dealloc_elm(SLIST_ENTRY(ipc_port))
    }
    let kData2: dData2
    
    let ip_context: mach_vm_address_t
    
    struct ip_flags: OptionSet {
        let rawValue: Int32
        
        static let ip_sprequests = ip_flags(rawValue: 1 << 0)   /* send-possible requests outstanding */
        static let ip_spimportant = ip_flags(rawValue: 1 << 1)  /* ... at least one is importance donating */
        static let ip_impdonation = ip_flags(rawValue: 1 << 2)  /* port supports importance donation */
        static let ip_tempowner = ip_flags(rawValue: 1 << 3)    /* dont give donations to current receiver */
        static let ip_guarded = ip_flags(rawValue: 1 << 4)      /* port guarded (use context value as guard) */
        static let ip_strict_guard = ip_flags(rawValue: 1 << 5) /* Strict guarding; Prevents user manipulation of context values directly */
        static let ip_specialreply = ip_flags(rawValue: 1 << 6) /* port is a special reply port */
        static let ip_sync_link_state = ip_flags(rawValue: 3 << 7)  /* link the special reply port to destination port/ Workloop */
        static let ip_impcount = ip_flags(rawValue: 22 << 10)   /* number of importance donations in nested queue */
    }
    var ip_flags: ip_flags
    let ip_mscount: mach_port_mscount_t
    let ip_srights: mach_port_rights_t
    let ip_sorights: mach_port_rights_t
    
    #if MACH_ASSERT
    let IP_NSPARES = 4
    let IP_CALLSTACK_MAX = 16
    //    let ip_thread: queue_chain_t    /*  all allocated ports */
    let ip_thread: thread_t /*  who made me?  thread context    */
    let ip_timetrack: UInt32    /*  give an idea of "when" created  */
    let ip_callstack: [UnsafePointer<UInt16>]   /*  stack trace, size of IP_CALLSTACK_MAX   */
    let ip_spares: [UnsafePointer<UInt32>]      /*  for debugging, size of IP_NSPARES   */
    #endif  /*  MACH_ASSERT */
    #if DEVELOPMENT || DEBUG
    let ip_srp_lost_link: Bool  /*  special reply port turnstile link chain broken  */
    let ip_srp_msg_sent: Bool   /*  special reply port msg sent */
    #endif
}

let ip_object.ip_references: ip_references
let ip_object.io_bits: ip_bits
*/
