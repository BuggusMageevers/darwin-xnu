//
//  ipc_entry.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/11/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

/*
 *  Primitive functions to manipulate translation entries.
 */

import Foundation


/*
 *    Spaces hold capabilities for ipc_object_t's.
 *    Each ipc_entry_t records a capability.  Most capabilities have
 *    small names, and the entries are elements of a table.
 *
 *    The ie_index field of entries in the table implements
 *    a ordered hash table with open addressing and linear probing.
 *    This hash table converts (space, object) -> name.
 *    It is used independently of the other fields.
 *
 *    Free (unallocated) entries in the table have null ie_object
 *    fields.  The ie_bits field is zero except for IE_BITS_GEN.
 *    The ie_next (ie_request) field links free entries into a free list.
 *
 *    The first entry in the table (index 0) is always free.
 *    It is used as the head of the free list.
 */

struct ipc_entry {
    let ie_object: UnsafePointer<ipc_object>?
    let ie_bits: ipc_entry_bits_t
    let ie_index: mach_port_index_t
    
    enum EntryIndex {
        case next(mach_port_index_t)
        case request(ipc_table_index_t)
    }
    let index: EntryIndex
}

let index_request: ie_request
let index_next: ie_next

let IE_REQ_NONE = 0     /*  no request  */

let IE_BITS_UREFS_MASK: UInt32 = 0x0000_ffff    /*  16 bits of user-reference   */
func IE_BITS_UREFS(_ bits: UInt32) -> UInt32 { return bits & IE_BITS_UREFS_MASK }
let IE_BITS_TYPE_MASK: UInt32 = 0x001f_0000     /*  5 bits of capability        */
func IE_BITS_TYPE(_ bits: UInt32) -> UInt32 { return bits & IE_BITS_TYPE_MASK }

#if !NO_PORT_GEN
let IE_BITS_GEN_MASK: UInt32 = 0xff00_0000      /*  8 bits for generation       */
func IE_BITS_GEN(_ bits: UInt32) -> UInt32 { return bits & IE_BITS_GEN_MASK }
let IE_BITS_GEN_ONE: UInt32 = 0x0400_0000       /*  low bit of generation       */
let IE_BITS_ROLL_POS: UInt32 = 22              /*  LSB pos of generation       */
let IE_BITS_ROLL_BITS: UInt32 = 2               /*  number of generation rollover bits  */
func IE_BITS_ROLL_MASK() -> UInt32 { return ((1 << IE_BITS_ROLL_BITS) - 1) << IE_BITS_ROLL_POS }
func IE_BITS_ROLL(_ bits: UInt32) -> UInt32 { return ((bits & IE_BITS_ROLL_MASK()) << 8) ^ IE_BITS_GEN_MASK }

/*
 *  Restart a generation counter with the specified bits for the rollover point.
 *  There are 4 different rollover points:
 *  bits    rollover period
 *  0 0     64
 *  0 1     48
 *  1 0     32
 *  1 1     16
 */
func ipc_entry_new_rollpoint(_ rollbits: ipc_entry_bits_t) -> ipc_entry_bits_t {
    let newrollbits = (rollbits << IE_BITS_ROLL_POS) & IE_BITS_ROLL_MASK()
    let newgen: ipc_entry_bits_t = IE_BITS_GEN_MASK + IE_BITS_GEN_ONE
    return (newgen | newrollbits)
}

/*
 *  Get the next gencount, modulo the entry's rollover point.  If the sum rolls over,
 *  the caller should re-start the generation counter with a difference rollpoint.
 */
func ipc_entry_new_gen(_ oldgen: ipc_entry_bits_t) -> ipc_entry_bits_t {
    let sum: ipc_entry_bits_t = (oldgen + IE_BITS_GEN_ONE) & IE_BITS_GEN_MASK
    let roll: ipc_entry_bits_t = oldgen & IE_BITS_ROLL_MASK()
    let newgen: ipc_entry_bits_t = (sum % IE_BITS_ROLL(oldgen)) | roll
    return newgen
}

/*  Determine if a gencount has rolled over or not.  */
func ipc_entry_gen_rolled(_ oldgen: ipc_entry_bits_t, _ newgen: ipc_entry_bits_t) -> Bool {
    return (oldgen & IE_BITS_GEN_MASK) > (newgen & IE_BITS_GEN_MASK)
}

#else
let IE_BITS_GEN_MASK = 0
let IE_BITS_GEN = 0
let IE_BITS_GEN_ONE = 0
let IE_BITS_ROLL_POS = 0
let IE_BITS_ROLL_MASK = 0
func IE_BITS_ROLL(_ bits: UInt32) -> UInt32 { return bits }

func ipc_entry_new_rollpoint(_ rollbits: ipc_entry_bits_t) -> ipc_entry_bits_t { return 0 }

func ipc_entry_new_gen(_ oldgen: ipc_entry_bits_t) -> ipc_entry_bits_t { return 0 }

func ipc_entry_gen_rolled(_ oldgen: ipc_entry_bits_t, _ newgen: ipc_entry_bits_t) -> Bool { return false }

#endif  /*  !USE_PORT_GEN   */

let IE_BITS_RIGHT_MASK: UInt32 = 0x007f_ffff    /*  relevant to the right */


/*
 *    Routine:    ipc_entry_lookup
 *    Purpose:
 *        Searches for an entry, given its name.
 *    Conditions:
 *        The space must be read or write locked throughout.
 *        The space must be active.
 */
func ipc_entry_lookup(_ space: ipc_space_t, _ name: mach_port_name_t) -> ipc_entry_t {
    assert(is_active(space))
    
    let index: mach_port_index_t = MACH_PORT_INDEX(name)
    if index < space.is_table_size {
        let entry: ipc_entry_t = space.is_table[index]
        if IE_BITS_GEN(entry.ie_bits) != MACH_PORT_GEN(name) || IE_BITS_TYPE(entry.ie_bits) == MACH_PORT_TYPE_NONE {
            entry = IE_NULL
        }
    } else {
        entry = IE_NULL
    }
    
    assert((entry == IE_NULL) || IE_BITS_TYPE(entry.ie_bits))
    return entry
}

/*
 *    Routine:    ipc_entries_hold
 *    Purpose:
 *        Verifies that there are at least 'entries_needed'
 *        free list members
 *    Conditions:
 *        The space is write-locked and active throughout.
 *        An object may be locked.  Will not allocate memory.
 *    Returns:
 *        KERN_SUCCESS        Free entries were found.
 *        KERN_NO_SPACE        No entry allocated.
 */
func ipc_entries_hold(_ space: ipc_space_t, _ name: mach_port_name_t) -> kern_return_t {
    assert(is_active(space))
    
    let table: ipc_entry_t = withUnsafeMutableBytes(of: &space.is_table) { return pointer }
    
    var i = 0
    while i < entries_needed {
        next_free = table
        
        i += 1
    }
}

/*  Claim and initialize a held entry in a locked space  */
func ipc_entry_claim(_ name: ipc_space_t, _ namep: UnsafePointer<mach_port_name_t>, _ entryp: UnsafePointer<ipc_entry_t>) -> kern_return_t {
    
}

/*  Allocate an entry in a space    */
func ipc_entry_get(_ space: ipc_space_t, namep: UnsafePointer<mach_port_name_t>, _ entryp: UnsafePointer<ipc_entry_t>) -> kern_return_t {
    
}

/*  Allocate an entry in a space, growing the space if necessary  */
func ipc_entry_alloc(_ space: ipc_space_t, _ namep: UnsafePointer<mach_port_name_t>, _entryp: UnsafePointer<ipc_entry_t>) -> kern_return_t {
    
}

/*  allocate/find and entry in aspace with a specific name  */
func ipc_entry_alloc_name(_ space: ipc_space_t, _ name: mach_port_name_t, entryp: UnsafePointer<ipc_entry_t>) -> kern_return_t {
    
}

/*  Deallocate an entry from a space  */
func ipc_entry_dealloc(_ space: ipc_space_t, _ name: mach_port_name_t, _ entry: ipc_entry_t) {
    
}

/*  Mark and entry modified in a space  */
func ipc_entry_modified(_ space: ipc_space_t, _ name: mach_port_name_t, _ entry: ipc_entry_t) {
    
}

/*  Grow the table in a space  */
func ipc_entry_grow_table(_ space: ipc_space_t, _ target_size: ipc_table_elems_t) -> kern_return_t {
    
}

/*  Mask on/of default entry generation bits  */
func ipc_entry_name_mack(_ name: mach_port_name_t) -> mach_port_name_t {
    
}
