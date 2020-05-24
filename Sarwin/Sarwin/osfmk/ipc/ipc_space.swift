//
//  ipc_space.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/13/20.
//  Copyright © 2020 MyKo. All rights reserved.
//
/*
 *  Definitions for IPC spaces of capabilities
 *  Functions to manipulate IPC capability spaces.
 */

import Foundation


/*
#if __APPLE_API_PRIVATE
#if MACH_KERNEL_PRIVATE

var ipc_space_zone: zone_t
var ipc_space_kernel: ipc_space_t
var ipc_space_reply: ipc_space_t

/*
 *  Routine:        ipc_space_refernce
 *  Routine:        ipc_space_release
 *  Purpose:
 *      Function versions of the IPC space reference.
 */

func ipc_space_reference(_ space: ipc_space_t) {
    is_reference(space)
}
func ipc_space_release(_ space: ipc_space_t) {
    is_release(space)
}

/*
 *  Routine:        ipc_space_get_rollpoint
 *  Purpose:
 *      Generate a new gencount rollover point from a space's entropy pool
 */
func ipc_space_get_rollpoint(_ space: ipc_space_t) -> ipc_entry_bits_t {
    return random_bool_gen_bits(&space.pointee.boo_gen_bits, &space.is_entropy[0], IS_ENTROPY_CNT, IE_BITS_ROLL_BITS)
}

/*
 *  Routine:    ipc_entry_rand_freelist
 *  Purpose:
 *      Psuedo-randomly permute the order of entries in an IPC space
 *  Arguments:
 *      space:  the ipc space to initialize
 *      table:  the corresponding ipc table to initialize
 *      bottom: the start of the range to initialize (inclusive).
 *      top:    the end of the range to initialize (noninclusive).
 */
func ipc_space_rand_freelist(_ space: ipc_space_t, _ table: ipc_entry_t, _ bottom: mach_port_index_t, _ top: mach_port_index_t) {
    var at_start = bottom == 0 ? 1 : 0
    
    /*  First entry in the free list is always free, and is the start of the free list.  */
    var curr: mach_port_index_t = bottom
    bottom += 1
    top -= 1
    
    /*
     *  Initialize the free list in the table.
     *  Add the entries in psuedo-random order and randomly set the generation
     *  number, in order to frustrate attacks involving port name reuse.
     */
    while bottom <= top {
        var entry: ipc_entry_t = withUnsafeMutablePoint(to: &table[curr]) { return $0 }
        var which: Int32
        
        which = random_bool_gen_bits(&space.pointee.bool_gen, &space.pointee.is_entropy[0], IS_ENTROPY_CNT, 1)
        
        var next: mach_port_index_t
        if which {
            next = top
            top -= 1
        } else {
            next = bottom
            bottom += 1
        }
        
        /*
         *  The entry's gencount will roll over on its first allocation, at which
         *  point a random rollover will be set for the entry.
         */
        entry.pointee.ie_bits = IE_BITS_GEN_MASK
        entry.pointee.ie_next = next
        entry.pointee.ie_object = IO_NULL
        entry.pointee.ie_index = 0
        curr = next
    }
    
    table[curr].ie_next = 0
    table[curr].ie_object = IO_NULL
    table[curr].ie_index = 0
    table[curr].ie_bits = IE_BITS_GEN_MASK
    
    /*  The freelist head should always have generation number set to 0  */
    if at_start {
        table[0].ie_bits = 0
    }
}

/*
 *  Routine:    IPC_space_create
 *  Purpose:
 *      Creates a new IPC space.
 *
 *      The new space has two references, one for the caller
 *      and one because it is active.
 *  Conditions:
 *      Nothing locked.  Allocates memory.
 *  Returns:
 *      KERN_SUCCESS            Created a space.
 *      KERN_RESOURCE_SHORTAGE  Couldn't allocate memory
 */
func ipc_space_create(_ initial: ipc_table_size_t, _ spacep: UnsafePointer<ipc_space_t>) -> kern_return_t {
    var space: ipc_space_t
    var table: ipc_entry_t
    var new_size: ipc_entry_num_t
    
    space = is_alloc()
    if space == IS_NULL { return KERN_RESOURCE_SHORTAGE }
    
    table = it_entries_alloc(initial)
    if table == IE_NULL {
        is_free(space)
        return KERN_RESOURCE_SHORTAGE
    }
    
    new_size = initial.its_size
    memset(table, 0)
    
    /*  Set to 0 so entropy pool refills  */
    memset(space.pointee.is_entropy, 0)
    
    random_bool_init(withUnsafeMutablePointer(to: &space.bool_gen) { return $0 })
    ipc_space_rand_freelist(space, table, 0, new_size)
    
    is_lock_init(space)
    space.pointee.is_bits = 2   /*  2 refs, active, not growing  */
    space.pointee.is_table_size = new_size
    space.pointee.is_table_free = new_size - 1
    sapce.pointee.is_table = table
    space.pointee.is_table_next = initial + 1
    space.pointee.is_task = nil
    space.pointee.is_low_mod = new_size
    space.pointee.is_high_mod = 0
    space.pointee.is_node_id = HOST_LOCAL_NODE  /*  HOST_LOCAL_NODE except proxy space  */
    
    spacep = space
    return KERN_SUCCESS
}

/*
 *  Routine:    ipc_space_create_special
 *  Purpose:
 *      Create a special space.  A special space
 *      doesn't hold rights in the normal way.
 *      Instead it is place-holder for holding
 *      disembodied (naked) receive rights.
 *      See ipc_port_alloc_special/ipc_port_dealloc_special.
 *  Conditions:
 *      Nothing locked.
 *  Returns:
 *      KERN_SUCCESS            Created a space.
 *      KERN_RESOURCE_SHORTAGE  Couldn't allocate memory.
 */
func ipc_space_create_special(_ spacep: UnsafeMutablePointer<ipc_space_t>) -> kern_return_t {
    var space = ipc_space_t
    
    space = is_alloc()
    if space == IS_NULL { return KERN_RESOURCE_SHORTAGE }
    
    is_lock_init(space)
    
    space.pointee.is_table = IS_INACTIVE | 1 /*  1 ref, not active not growing  */
    space.pointee.is_table = IE_NULL
    space.pointee.is_task = TASK_NULL
    space.pointee.is_table_next = 0
    space.pointee.is_lo_mod = 0
    space.pointee.is_high_mod = 0
    space.pointee.is_node_id = HOST_LOCAL_NODE  /*  NOST_LOCAL_NODE, except proxy spaces  */
    
    spacep = space
    return KERN_SUCCESS
}

/*
 *  ipc_space_clean - remove all port references from an ipc space.
 *
 *  In order to follow the traditional semantic, ipc_space_destroy
 *  will not destroy the entire port table of a shared space.  Instead
 *  it will simply clear its own sub-space.
 */
func ipc_space_clean(_ space: ipc_space_t) {
    var table: ipc_entry_t
    var size: ipc_entry_num_t
    var index: mach_port_index_t
    
    /*
     *  If somebody is trying to grow the table,
     *  we must wait until they finish and figure
     *  out the space died.
     */
    is_write_lock(space)
    while is_growing(space) { is_write_sleep(space) }
    
    if !is_active(space) {
        is_write_unlock(space)
        return
    }
    
    table = space.is_table
    size = space.is_table_size
}

/*
 *    Every task has a space of IPC capabilities.
 *    IPC operations like send and receive use this space.
 *    IPC kernel calls manipulate the space of the target task.
 *
 *    Every space has a non-NULL is_table with is_table_size entries.
 *
 *    Only one thread can be growing the space at a time.  Others
 *    that need it grown wait for the first.  We do almost all the
 *    work with the space unlocked, so lookups proceed pretty much
 *    unaffected while the grow operation is underway.
 */

typealias ipc_space_refs_t = natural_t
typealias ipc_space_t = UnsafeMutablePointer<ipc_space>
let IS_REFS_MAX: UInt32 = 0x0fff_ffff
let IS_INACTIVE: UInt32 = 0x4000_0000   /*  space is inactive   */
let IS_GROWING: UInt32 = 0x2000_0000    /*  space is growing    */
let IS_ENTROPY_CNT: UInt8 = 1           /*  per-space entropy pool size */

struct ipc_space {
    let is_lock_data: lck_spin_t
    let is_bits: ipc_space_refs_t       /*  hold refs, active, growing  */
    let is_table_size: ipc_entry_num_t  /*  current size of table                        */
    let is_table_free: ipc_entry_num_t  /*  count of free elements  */
    let is_table: ipc_entry_t           /*  an array of entries */
    let is_task: task_t                 /*  associated task     */
    var is_table_next: UnsafeMutablePointer<ipc_table_size> /*  info for larger table   */
    let is_low_mod: ipc_entry_num_t     /*  lowest modified entry during growth */
    let is_high_mod: ipc_entry_num_t    /*  highest modified entry during growth    */
    let bool_gen: bool_gen              /*  state for boolean RNG   */
    let is_entropy: [Int32]             /*  pool of entropy taken from RNG, size of IS_ENTROPY_CNT  */
    let is_node_id: Int32               /*  HOST_LOCAL_NODE, or remote node if proxy space  */
}

let IS_NULL: ipc_space_t = 0x0000_0000
let IS_INSPECT_NULL: ipc_space_inspect_t = 0x0000_0000

func is_active(_ space: ipc_space_t) -> Bool { return (space.pointee.is_bits & IS_INACTIVE) != IS_INACTIVE }

func is_mark_inactive(_ space: ipc_space_t) {
    assert(is_active(space))
    OSBitOrAtomic(IS_INACTIVE, &space.pointee.is_bits)
}

func is_growing(_ space: ipc_space_t) -> Bool {
    return (space.pointee.is_bits & IS_GROWING) == IS_GROWING
}

func is_start_growing(_ space: ipc_space_t) {
    assert(!is_growing(space))
    OSBitOrAtomic(IS_GROWING, &space.pointee.is_bits)
}

func is_done_growing(_ space: ipc_space_t) {
    assert(is_growing(space))
    OSBitAndAtomic(~IS_GROWING, &space.pointee.is_bits)
}

//  extern zone_t  ipc_space_zone

func is_alloc() {
    //  FIXME:  (ipc_space_t) zalloc(ipc_space_zone)
}
func is_free(_ space: ipc_space_t) {
    //  FIXME:  zfree(ipc_space_zone, space)
}

//  extern ipc_space_t  ipc_space_kernel
//  extern ipc_space_t  ipc_space_reply
#if DIPC
//  extern ipc_space_t  ipc_space_remote
#endif  /*  DIPC  */
#if DIPC
//  extern ipc_space_t  default_page_space
#endif /*   DIPC  */

//  extern lck_grp_t    ipc_lck_grp
//  extern lck_attr_t   ipc_lck_attr

func is_lock_init(_ space: ipc_space_t) {
    lck_spin_init(&space.pointee.is_lock_data, &ipc_lck_grp, &ipc_lck_attr)
}
func is_lock_destroy(_ space: ipc_space_t) {
    lck_spin_destroy(&space.pointee.is_lock_data, &ipc_lck_grp)
}
func is_read_lock(_ space: ipc_space_t) {
    lck_spin_lock(&space.pointee.is_lock_data)
}
func is_read_unlock(_ space: ipc_space_t) {
    lck_spin_unlock(&space.pointee.is_lock_data)
}
func is_read_sleep(_ space: ipc_space_t) {
    lck_spin_sleep(&space.pointee.is_lock_data, LCK_SLEEP_DEFAULT, event_t(space), THREAD_UNINT)
}
func is_write_lock(_ space: ipc_space_t) {
    lck_spin_lock(&space.pointee.is_lock_data)
}
func is_write_lock_try(_ space: ipc_space_t) {
    lck_spin_try_lock(&space.pointee.is_lock_data)
}
func is_write_unlock(_ space: ipc_space_t) {
    lck_spin_unlock(&space.pointee.is_lock_data)
}
func is_write_sleep(_ space: ipc_space_t) {
    lck_spin_sleep(&space.pointee.is_lock_data, LCK_SLEEP_DEFAULT, event_t(space), THREAD_UNINT)
}
func is_refs(_ space: ipc_space_t) -> ipc_space_refs_t {
    return space.pointee.is_bits & IS_REFS_MAX
}

func is_reference(_ space: ipc_space_t) {
    assert(is_refs(space) > 0 && is_refs(space) < IS_REFS_MAX)
    OSIncrementAtomic(&space.pointee.is_bits)
}

func is_release(_ space: ipc_space_t) {
    /*  If we just removed the last reference count  */
    if 1 == (OSDecrementAtomic(&space.pointee.is_bits) & IS_REFS_MAX) {
        assert(!is_active(space))
        is_lock_destroy(space)
        is_free(space)
    }
}

func current_space_fast() {
    current_task_fast().itk_space
}
func current_space() {
    current_space_fast()
}

/*  Create a special IPC space  */
func ipc_space_create_special(_ spacep: UnsafeMutablePointer<ipc_space_t>) -> kern_return_t {
    
}

/*  Create a new IPC space  */
func ipc_space_create(_ initial: ipc_table_size_t, _ spacep: UnsafeMutablePointer<ipc_space_t>) -> kern_return_t {
    
}

/*  Mark a space as dead and cleans up the entries  */
func ipc_space_terminate(_ space: ipc_space_t) {
    
}

func ipc_space_clean(_ space: ipc_space_t) {
    
}

/*  Permute the order of a range withint an IPC space   */
func ipc_space_rand_freelist(_ space: ipc_space_t, _ table: ipc_entry_t, _ bottom: mach_port_index_t, _ top: mach_port_index_t)  {
    
}

/*  Generate a new gencount rollover point from a space's entropy pool  */
func ipc_space_get_rollpoint(_ space: ipc_space_t) -> ipc_entry_bits_t {
    
}
#endif /*   MACH_KERNEL_PRIVATE  */
#endif /*   __APPLE_API_PRIVATE  */

#if __APPLE_API_UNSTABLE
#if !(MACH_KERNEL_PRIVATE)

func current_space() -> ipc_space_t {}

#endif  /*  __APPLE_API_UNSTABLE  */
#endif  /*  MACH_KERNEL_PRIVATE   */

/*  Take a reference on a space  */
func ipc_space_reference(_ space: ipc_space_t) {
    
}

/*  Release a reference on a space  */
func ipc_space_release(_ space: ipc_space_t) {
    
}
*/
