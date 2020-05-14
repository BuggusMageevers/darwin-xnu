//
//  port.swift
//  Translation:
//      osfmk/mach/port.h
//  Dependencies:
//      bsd/sys/cdefs.h
//      stdint.h
//      osfmk/mach/boolean.h
//          osfmk/mach/machine/boolean.h
//              osfmk/mach/i386/boolean.h
//              osfmk/mach/arm/boolearn.h
//      osfmk/mach/machine/vm_types.h
//          osfmk/mach/i386/vm_types.h
//              bsd/i386/_types.h
//              osfmk/mach/i386/vm_param.h
//              stdint.h
//          osfmk/mach/arm/vm_types.h
//              bsd/arm/_types.h
//              stdint.h
//              EXTERNAL_HEADERS/Availability.h
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/8/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

/*
 *  Definition of a Mach port
 *
 *  Mach ports are the endpoints to Mach-implemented communications
 *  channels (usually uni-directional message queues, but other types
 *  also exist).
 *
 *  Unique collections of these endpoits are maintained for each
 *  Mach task.  Each Mach port in the task's colection is given a
 *  (task-local) name to identify it - and the various "rights"
 *  held by the task for that specific endpoint.
 *
 *  This file defines the types used to identify these Mach ports
 *  and the various rights associated with them.  For more info see:
 *
 *  mach/mach_port.h - manipulation of port rights in a given space
 *  mach/message.h - message queue [and port right passing] mechanism
 *
 */

import Foundation


/*
 *  mach_port_name_t - the local identity for a Mach port
 *
 *  The name is Mach port namespace specific.  If is used to
 *  identify the rights held for that port by the task whose
 *  namespace if implied [or specifically provided].
 *
 *  Use of this type usually implies just a name - no rights.
 *  See mach_port_t for a type that implies a "named right."
 *
 */

typealias mach_port_name_t = UInt32
typealias mach_port_name_array_t = UnsafePointer<mach_port_name_t>
typealias mach_port_index_t = mach_port_name_t  /*  index values        */
typealias mach_port_gen_t = mach_port_name_t    /*  generation numbers  */

#if KERNEL

/*
 *  mach_port_t - a named port right
 *
 *  In the kernel, "rights" are represented [named] by pointers to
 *  the ipc port object in question.  There is no port namespace for the
 * rights to be collected.
 *
 *  Actually, there is namespace for ther kernel task.  But most kernel
 *  code - including, but not limited to, Mach IPC code - lives in the
 *  limbo between the current user-level task and the "next" task.  Very
 *  little of the kernel code runs in full kernel task contect.  So very
 *  little of it gets to use ther kernel task's port name space.
 *
 *  Because of this implementation approach, all in-kernel rights for
 *  a given port coalesce [have the same name/pointer].  The actual
 *  references are counted in the port itself.  It is up to the kernel
 *  code in question to "just remember" how many [and what type of]
 *  rights it holds and handle them appropriately.
 *
 */
 
typealias ipc_port_t = ipc_port

let IPC_PORT_NULL: ipc_port_t        //  FIXME:  Should be Bool?
let IPC_PORT_DEAD: ipc_port_t       //  FIXME:  Should be Bool?
func IPC_PORT_INVALID(_ port: ipc_port_t) -> Bool {
    return port != IPC_PORT_NULL && port != IPC_PORT_DEAD
}

typealias mach_port_t = ipc_port_t

/*
 *  Since the 32-bit and 64-bit represenstations of ~0 are differenct,
 *  explicitly handle MACH_PORT_DEAD
 */
//  FIXME:  Do these really need to be pointers?
func CAST_MACH_PORT_TO_NAME(_ port: mach_port_t) -> mach_port_name_t {
    return UnsafePointer<mach_port_t>(port)
}
func CAST_MACH_NAME_TO_PORT(_ name: mach_port_name_t) -> mach_port_t {
    return name == MACH_PORT_DEAD ? IPC_PORT_DEAD : UnsafePointer<mach_port_t>(name)
}

#else   /*  KERNEL  */

/*
 *  mach_port_t - a name port right
 *  In user-space, "rights' are represented by the name of the
 *  right in the Mach port namespace.  Even so, this type is
 *  presented as a unique one to more clearly denote the prsence
 *  of a right coming along with the name.
 *
 *  Often, various rights for a port held in a single name space
 *  will coalesce and are, therefore, identified by a single name
 *  [this is the case for send and receive rights].  But not
 *  always [send-once right currently get a unique name for
 *  each right].
 *
 */

#endif  /*  KERNEL  */

typealias mach_port_array_t = mach_port_t

/*
 *  MACH_PORT_NULL is a legal value that can be carried in messages.
 *  It indicates the absence of any port or port rights.  (A port
 *  argument keeps the message from being "simple", even if the
 *  value is MACH_PORT_NULL.)  The value MACH_PORT_DEAD is also a legal
 *  value that can be carried in messages. It indicates
 *  that a port right was present, but it died.
 */

let MACH_PORT_NULL: mach_port_name_t
let MACH_PORT_DEAD: mach_port_name_t = mach_port_name_t(~0)
func MACH_PORT_INVALID(_ name: mach_port_name_t) -> Bool {
    return name != MACH_PORT_NULL && name != MACH_PORT_DEAD
}

/*
 *  For kernel-selected [assigned] port names, then name is
 *  comprised of two parts:  a generation number and an index.
 *  This approach keeps the exact same name from being generated
 *  and reused too quilcy [to catch right/reference counting bugs].
 *  The dividing line between the constituent parts is exposed so
 *  that efficient "mach_port_name_t to data structure pointer"
 *  conversion impolementation can be made.  But it is possible
 *  for user-level code to assign their own names to Mach ports.
 *  These are not required to participate in this algorithm.  So
 *  care should be taken before "assuming" this model.
 *
 */

#if !NO_PORT_GEN

func MACH_PORT_INDEX(_ name: mach_port_name_t) -> UInt32 { return name >> 8 }
func MACH_PORT_GEN(_ name: mach_port_name_t) -> UInt32 { return (name & 0xff) << 24 }
func MACH_PORT_MAKE(_ index: UInt32, gen: UInt32) -> UInt32 { return index << 8 | gen >> 24 }

#else

func MACH_PORT_INDEX(_ name: mach_port_name_t) -> mach_port_name_t { return name }
func MACH_PORT_GEN(_ name: mach_port_name_t) -> mach_port_name_t { return 0 }
func MACH_PORT_MAKE(_ index: UInt16, _ gen: UInt16) { return index }

#endif  /*  NO_PORT_GEN  */

/*
 *  These are the different rights a task may have for a port.
 *  The MACH_PORT_RIGHT_* definitions are used as arguments
 *  to mach_port_allocate, mach_port_get_refs, etc, to specify
 *  a particular right to act upon.  The mach_port_names and
 *  mach_port_type calls return bitmasks using the MACH_PORT_TYPE_*
 *  definitions.  This is because a single name may denote
 *  multiple rights.
 */

typealias mach_port_right_t = natural_t

let MACH_PORT_RIGHT_SEND: mach_port_right_t = 0
let MACH_PORT_RIGHT_RECEIVE: mach_port_right_t = 1
let MACH_PORT_RIGHT_SEND_ONCE: mach_port_right_t = 2
let MACH_PORT_RIGHT_PORT_SET: mach_port_right_t = 3
let MACH_PORT_RIGHT_DEAD_NAME: mach_port_right_t = 4
let MACH_PORT_RIGHT_LABELH: mach_port_right_t = 5
let MACH_PORT_RIGHT_NUMBER: mach_port_right_t = 6

typealias mach_port_type_t = natural_t
typealias mach_port_type_array_t = mach_port_type_t

func MACH_PORT_TYPE(_ right: mach_port_type_t) { mach_port_type_t(1) << right + mach_port_type_t(16) }
let MACH_PORT_TYPE_NONE = mach_port_type_t(0)
let MACH_PORT_TYPE_SEND = MACH_PORT_TYPE(MACH_PORT_RIGHT_SEND)
let MACH_PORT_TYPE_RECEIVE = MACH_PORT_TYPE(MACH_PORT_RIGHT_RECEIVE)
let MACH_PORT_TYPE_SEND_ONCE = MACH_PORT_TYPE(MACH_PORT_RIGHT_SEND_ONCE)
let MACH_PORT_TYPE_PORT_SET = MACH_PORT_TYPE(MACH_PORT_RIGHT_PORT_SET)
let MACH_PORT_TYPE_DEAD_NAME = MACH_PORT_TYPE(MACH_PORT_RIGHT_DEAD_NAME)
let MACH_PORT_TYPE_SEND_LABELH = MACH_PORT_TYPE(MACH_PORT_RIGHT_LABELH)

/*  Convenient combinations.  */

let MACH_PORT_TYPE_SEND_RECEIVE = MACH_PORT_TYPE_SEND | MACH_PORT_TYPE_RECEIVE
let MACH_PORT_TYPE_SEND_RIGHTS = MACH_PORT_TYPE_SEND | MACH_PORT_TYPE_SEND_ONCE
let MACH_PORT_TYPE_PORT_RIGHTS = MACH_PORT_TYPE_SEND_RIGHTS | MACH_PORT_TYPE_RECEIVE
let MACH_PORT_TYPE_PORT_OR_DEAD = MACH_PORT_TYPE_PORT_RIGHTS | MACH_PORT_TYPE_DEAD_NAME
let MACH_PORT_TYPE_ALL_RIGHTS = MACH_PORT_TYPE_PORT_OR_DEAD | MACH_PORT_TYPE_PORT_SET

/*  Dummy type bits that mach_port_type/mach_port_names can return  */

let MACH_PORT_TYPE_DNREQUEST = 0x8000_0000
let MACH_PORT_TYPE_SPREQUEST = 0x4000_0000
let  MACH_PORT_TYPE_SPREQUEST_DELAYED = 0x2000_0000

/*  User-reference for capabilities.  */

typealias mach_port_urefs_t = natural_t
typealias mach_port_delta_t = integer_t     /*  change in urefs  */

/*  Attributes of ports.  (See mach_port_get_receive_status.)  */

typealias mach_port_seqno_t = natural_t     /*  sequence number     */
typealias mach_port_mscount_t = natural_t   /*  make-send counst    */
typealias mach_port_msgcount_t = natural_t  /*  number of msgs      */
typealias mach_port_rights_t = natural_t    /*  number of rights    */

/*
 *  Are there outstanding send rights for a given port?
 */

let MACH_PORT_SRIGHTS_NONE = 0                  /*  no srights              */
let MACH_PORT_SRIGHTS_PRESENT = 1               /*  srights                 */
typealias MACH_PORT_SRIGHTS_PRESENT = UInt32  /*  status of send rights   */

struct mach_port_status_t {
    let mps_upset: mach_port_rights_t       /*  count of containing port sets   */
    let mps_seqno: mach_port_seqno_t        /*  sequenc number                  */
    let mps_mscount: mach_port_mscount_t    /*  make-send count                 */
    let mps_qlimit: mach_port_msgcount_t    /*  queue limit                     */
    let mps_msgcount: mach_port_msgcount_t  /*  number in the queue             */
    let mps_sorights: mach_port_rights_t    /*  how many send-one rights        */
    let mps_srights: Bool              /*  do send rights exist            */
    let mps_pdrequest: Bool            /*  port-deleted requested?         */
    let mps_nsrequest: Bool            /*  no-senders requested?           */
    let mps_flags: natural_t                /*  port flags                      */
}

/*  System-wide values for setting queue limits on a port  */
let MACH_PORT_QLIMIT_ZERO = 0
let MACH_PORT_QLIMIT_BASIC = 5
let MACH_PORT_QLIMIT_SMALL = 16
let MACH_PORT_QLIMIT_LARGE = 1024
let MACH_PORT_QLIMIT_KERNEL = 65534
let MACH_PORT_QLIMIT_MIN = MACH_PORT_QLIMIT_ZERO
let MACH_PORT_QLIMIT_DEFAULT = MACH_PORT_QLIMIT_BASIC
let MACH_PORT_QLIMIT_MAX = MACH_PORT_QLIMIT_LARGE

struct mach_port_limits {
    let mpl_qlimit: mach_port_msgcount_t    /*  number of msgs  */
}
typealias mach_port_limits_t = mach_port_limits

/*  Possible values for mps_flags (part of mach_port_status_t).  */
let MACH_PORT_STATUS_FLAG_TEMPOWER = 0x01
let MACH_PORT_STATUS_FLAG_GUARDED = 0x02
let MACH_PORT_STATUS_FLAG_STRICT_GUARD = 0x04
let MACH_PORT_STATUS_FLAG_IMP_DONATION = 0x08
let MACH_PORT_STATUS_FLAG_REVIVE = 0x10
let MACH_PORT_STATUS_FLAG_TASKPIR = 0x20

struct mach_port_info_ext {
    let mpie_status: mach_port_status_t
    let mpie_boost_cnt: mach_port_msgcount_t
    let reserved: [UInt32]    /*  size of 6  */
}
typealias mach_port_info_ext_t = mach_port_info_ext
typealias mach_port_info_t = integer_t  /*  varing array of natural_t  */

/*  Flavors for mach_port_get/set_attributes()  */
typealias mach_port_flavor_t = Int32
let MACH_PORT_LIMITS_INFO = 1           /*  uses mach_port_limits_t         */
let MACH_PORT_RECEIVE_STATUS = 2        /*  uses mach_port_status-t         */
let MACH_PORT_DNREQUESTS_SIZE = 3       /*  info is int                     */
let MACH_PORT_TEMPOWNER = 4             /*  indicates receive right will
                                         *  reassigned to another task      */
let MACH_PORT_IMPORTANCE_RECEIVER = 5   /*  indicates receive rigt accepts
                                         *  priority donation               */
let MACH_PORT_DENAP_RECEIVER = 6        /*  indicates receive right accepts
                                         *  de-nap donation                 */
let MACH_PORT_INFO_EXT = 7              /*  uses mach_port_info_ext_t       */

var MACH_PORT_LIMITS_INFO_COUNT: natural_t {
    return natural_t(MemoryLayout<mach_port_limits_t>.size / MemoryLayout<natural_t>.size)
}
var MACH_PORT_RECEIVE_STATUS_COUNT: natural_t {
    return natural_t(MemoryLayout<mach_port_status_t>.size / MemoryLayout<natural_t>.size)
}
let MACH_PORT_DNREQUESTS_SIZE_COUNT = 1
var MACH_PORT_INFO_EXT_COUNT: natural_t {
    return natural_t(MemoryLayout<mach_port_info_ext_t>.size / MemoryLayout<natural_t>.size)
}

/*
 *  Structure used to pass information about port allocation requests.
 *  Must be padded to 64-bits total length.
 */
struct mach_port_qos {
    let name: UInt32      /*  name given, 1 bit field             */
    let prealloc: UInt32  /*  prealloced message, 1 bit field     */
    let pad1: Bool     /*  30 bit fields                       */
    let len: natural_t
}
typealias mach_port_qos_t = mach_port_qos

/*
 *  Flags for mach_port_options (used for
 *  invocation of mach_port_construct).
 *  Indicates attributes to be set for the newly
 *  allocated port.
 */
let MPO_CONTEXT_AS_GUARD = 0x01     /*  Add guard to the port                   */
let MPO_QLIMIT = 0x02               /*  Set qlimit for the port msg queue       */
let MPO_TEMPOWNER = 0x04            /*  Set the tempowner bit of the port       */
let MPO_IMPORTANCE_RECEIVER = 0x08  /*  Mark the port as importanc receiver     */
let MPO_INSERT_SEND_RIGHT = 0x10    /*  Insert a send right for the port        */
let MPO_STRICT = 0x20               /*  Apply strict guarding for port          */
let MPO_DENAP_RECEIVER = 0x40       /*  Mark the port as App de-nap receiver    */
/*
 *  Structure to define optional attributes for a newly
 *  constructed port.
 */
struct mach_port_options {
    let flags: UInt32             /*  Flags defining attributes for port  */
    let mpl: mach_port_limits_t     /*  Message queue limit for port        */
    let reserved: [UInt32]        /*  Reserved                            */
}
typealias mach_port_options_t = mach_port_options
typealias mach_port_options_prt_t = mach_port_options_t

/*
 *  EXC_GUARD represent a guard violation for both
 *  mach ports and file descriptors.  GUARD_TYPE is used
 *  to differentiate among them.
 */
let GUARD_TYPE_MACH_PORT = 0x1

/*  Reasons for exception for a guarded mach port   */
struct mach_port_guard_exception_codes: OptionSet {
    let rawValue: UInt8
    static let kGUARD_EXC_DESTROY = mach_port_guard_exception_codes(rawValue: 1 << 0)
    static let kGUARD_EXC_MOD_REFS = mach_port_guard_exception_codes(rawValue: 1 << 1)
    static let kGUARD_EXC_SET_CONTEXT = mach_port_guard_exception_codes(rawValue: 1 << 2)
    static let kGUARD_EXC_UNGUARDED = mach_port_guard_exception_codes(rawValue: 1 << 3)
    static let kGUARD_EXC_INCORRECT_GUARD = mach_port_guard_exception_codes(rawValue: 1 << 4)
    /* sart of non-fatal guards */
    static let kGUARD_EXC_INVALID_RIGHT = mach_port_guard_exception_codes(rawValue: 1 << 8)
    static let kGUARD_EXC_INVALID_NAME = mach_port_guard_exception_codes(rawValue: 1 << 9)
    static let kGUARD_EXC_INVALID_VALUE = mach_port_guard_exception_codes(rawValue: 1 << 10)
    static let kGUARD_EXC_INVALID_ARGUMENT = mach_port_guard_exception_codes(rawValue: 1 << 11)
    static let kGUARD_EXC_RIGHT_EXISTS = mach_port_guard_exception_codes(rawValue: 1 << 12)
    static let kGUARD_EXC_KERN_NO_SPACE = mach_port_guard_exception_codes(rawValue: 1 << 13)
    static let kGUARD_EXC_KERN_FAILURE = mach_port_guard_exception_codes(rawValue: 1 << 14)
    static let kGUARD_EXC_KERN_RESOURCE = mach_port_guard_exception_codes(rawValue: 1 << 15)
    static let kGUARD_EXC_SEND_INVALID_REPLY = mach_port_guard_exception_codes(rawValue: 1 << 16)
    static let kGUARD_EXC_SEND_INVALID_VOUCHER = mach_port_guard_exception_codes(rawValue: 1 << 16)
    static let kGUARD_EXC_SEND_INVALID_RIGHT = mach_port_guard_exception_codes(rawValue: 1 << 17)
    static let kGUARD_EXC_RCV_INVALID_NAME = mach_port_guard_exception_codes(rawValue: 1 << 18)
    static let kGUARD_EXC_RCV_INVALID_NOTIFY = mach_port_guard_exception_codes(rawValue: 1 << 19)
}

#if !__DARWIN_UNIX03 && !_NO_PORT_T_FROM_MACH
/*
 *  Mach 3.0 renamed everything to have mach_ in front of it.
 *  These types and macros are provided for backward compatibility
 *  but are deprecated.
 */
typealias port_t = mach_port_t
typealias port_name_t = mach_port_name_t
typealias port_name_array_t = mach_port_name_t

let PORT_NULL: port_t = 0
let PORT_DEAD: port_t = ~0
func PORT_VALID(_ name: port_t) -> boolean_t { return name != PORT_NULL && name != PORT_DEAD }

#endif  /*  !__DARWIN_UNIX03 && !_NO_PORT_T_FROM_MACH */
