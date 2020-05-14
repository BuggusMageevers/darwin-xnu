//
//  ipc_space.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/13/20.
//  Copyright © 2020 MyKo. All rights reserved.
//
/*
 *  Definitions for IPC spaces of capabilities
 */

import Foundation


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
