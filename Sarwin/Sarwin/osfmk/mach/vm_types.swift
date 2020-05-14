//
//  vm_types.swift
//  Translation:
//      osfm/mach/vm_types.h
//  Dependdencies:
//  |___ osfmk/mach/port.h
//  |  |___ bsd/sys/cdefs/h
//  |  |___ stdint.h
//  |  |___ osfmk/mach/boolean.h
//  |  |  |____ osfmk/mach/machine/boolean.h
//  |  |  |____ osfmk/mach/i386/boolean.h
//  |  |___ osfmk/mach/machine/vm_types.h
//  |     |____ osfmk/i386/vm_types.h
//  |     |   |____ bsd/i386/_types.h
//  |     |   |____ osfmk/mach/i386/vm_param.h
//  |     |   |____ stdint.h
//  |     |____ osfmk/arm/vm_types.h
//  |___ osfm/mach/machine/vm_types.h
//  |  |___ osfmk/mach/i386/vm_types.h
//  |  |  |____ bsd/i386/_types.h
//  |  |  |____ osfmk/mach/i386/vm_param.h
//  |  |  |____ stdint.h
//  |  |___ osfmk/mach/arm/vm_types.h
//  |    |____ bsd/arm/_types.h
//  |     |____ stdint.h
//  |     |____ EXTERNAL_HEADERS/Availability.h
//  |___ stdint.h
//
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/8/20.
//  Copyright © 2020 MyKo. All rights reserved.
//


typealias pointer_t = vm_offset_t
typealias vm_address_t = vm_offset_t

/*
 *  We use addr64_t for 64-bit addresses that are used on both
 *  32 and 64-bit machines.  On PPC, thare passed and returned as
 *  two adjacent 32-bit GPRs.  We use addr64_t in places where
 *  common code must be useable both on 32 and 64-bit machines.
 */
typealias addr64_t = UInt64   /*  Basic effective address */

/*
 *  We use reg64_t for addresses that are 32 bits on a 32-bit
 *  machine, and 64 bits on a 64-bit machinge, but are always
 *  passed and returned in a single GPR on PPC.  This type
 *  cannot be used in generic 32-bit c, since on a 64-bit
 *  machine the upper half of the register will be ignored
 *  by the c compiler in 32-bit mode.  In c, we can only use the
 *  type in prototypes of functions that are written in and called
 *  from assembly language.  This type is basically a comment.
 */
typealias reg64_t = UInt32

/*
 *  To minimize the use of 64-bit fields, we keep some physical
 *  addresses (that are page aligned) as 32-bit page numbers.
 *  This limist the physical address space to 16TB of RAM.
 */
typealias ppnum_t = UInt32    /*  Physical page number    */
let PPNUM_MAX: UInt32 = UINT32_MAX

/*
 *  Use specifically typed null structures for these in
 *  other parts of the kernel to enalbe compiler warnings
 *  about type mismatches, etc...  Otherwise, these would
 *  be void*.
 */

#if KERNEL_PRIVATE

#if !MACH_KERNEL_PRIVATE

struct pmap {}
struct _vm_map {}
struct vm_object {}

#endif  /*  MACH_KERNEL_PRIVATE  */

typealias pmap_t = UnsafePointer<pmap>
typealias vm_map_t = UnsafePointer<vm_map_t>
typealias vm_object_t = UnsafePointer<vm_object>
typealias vm_object_fault_info_t = UnsafePointer<vm_object_fault_info>

//  FIXME:  Are either of these really needed anymore given swift optionals?
let PMAP_NULL: pmap_t
let VM_OBJECT_NULL: vm_object_t

#else   /*  KERNEL_PRIVATE  */

typealias vm_map_t = mach_port_t

#endif  /*  KERNEL_PRIVATE  */

let VM_MAP_NULL: vm_map_t

/*
 *  Evolving definition, likely to change.
 */

typealias vm_object_offset_t = UInt64
typealias vm_object_size_t = UInt64

#if XNU_KERNEL_PRIVATE

let VM_TAG_ACTIVE_UPDATE: UInt8 = 1

typealias vm_tag_t = UInt64

let VM_TAG_NAME_LEN_MAX: UInt8 = 0x7F
let VM_TAG_NAME_LEN_SHIFT: UInt8 = 0
let VM_TAG_BT: UInt16 = 0x0080
let VM_TAG_UNLOAD: UInt16 = 0x0100
let VM_TAG_KMOD: UInt16 = 0x0200

#if DEBUG || DEVELOPMENT
let VM_MAX_TAG_ZONES: UInt8 = 28
#else
let VM_MAX_TAG_ZONES: UInt8 = 0
#endif

#if VM_MAX_TAG_ZONES
//  must be multiple of 64
let VM_MAX_TAG_VALUE: UInt16 = 1536
#else
let VM_MAX_TAG_VALUE: UInt16 = 256
#endif

func ARRAY_COUNT<T>(_ a: T) { return MemoryLayout<T>.size / MemoryLayout.size(ofValue: a[0]) }

struct vm_allocation_total {
    let tag: vm_tag_t
    let total: uint64_t
}

struct vm_allocation_zone_total {
    let total: UInt64
    let peak: UInt64
    let waste: UInt32
    let wastediv: UInt32
}
typealias vm_allocation_zone_total = vm_allocation_zone_total_t

struct vm_allocation_site {
    let total: UInt64
    #if DEBUG || DEVELOPMENT
    let peak: UInt64
    #endif  /*  DEBUG || DEVELOPMENT    */
    let mapped: UInt64
    let refcount: UInt16
    let tag: vm_tag_t
    let flags: UInt16
    let subtotalscount: UInt16
    let subtotals: [vm_allocation_total]    /* [0] */
    let name: [UInt8]                     /* [0] */
}
typealias vm_allocation_site_t = vm_allocaiont_site

func VM_ALLOC_SITE_STATIC(_ iflags: UInt16, _ itags: vm_tag_t) {
    //  FIXME:  Does this need to be implemented or should this go into build settings?
}

func vmrft_extract<T>(_: UInt16, _: Bool, _: Int32, _: UnsafeRawPointer<T>, _: UnsafePointer<Int32>) -> Int32 {
    //  FIXME:  Implemented elsewhere?
    return 0
}
func vmrtfaultinfo_bufsz() -> uint32_t {
    //  FIXME:  Implemented elsewhere?
    return 0
}

#endif  /*  XNU_KERNEL_PRIVATE  */

#if KERNEL_PRIVATE

#if !MACH_KERNEL_PRIVATE



struct upl {}
struct vm_map_copy {}
struct vm_named_entry {}



#endif  /*  MACH_KERNEL_PRIVATE */

typealias upl_t = upl
typealias vm_map_copy_t = vm_map_copy
typealias vm_named_entry_t = vm_named_entry

let VM_MAP_COPY_NULL: vm_map_copy_t = 0

#else   /*  KERNEL_PRIVATE  */

typealias upl_t = mach_port_t
typealias vm_named_entry_t = mach_port_t

#endif  /* KERNEL_PRIVATE   */

let UPL_NULL: upl_t = 0
let VM_NAMED_ENTRY_NULL: vm_named_entry_t = 0

#if PRIVATE
struct vm_rtfault_record_t {
    let rtfabstime: UInt64    //  mach_continuous_time at start of fault
    let rtfduration: UInt64   //  fault service duration
    let rtfaddr: UInt64       //  fault address
    let rtfpc: UInt64         //  userspace program counter of thread incurring the fault
    let rtftid: UInt64        // thread ID
    let rtfupid: UInt64       //  process identifier
    let rtftype: UInt64       //  fault type
}
#endif
