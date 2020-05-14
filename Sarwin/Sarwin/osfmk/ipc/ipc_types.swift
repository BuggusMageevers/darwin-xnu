//
//  ipc_types.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/11/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

/*
 *  Define Basic IPC types available to callers.
 *  These are not intended to be used directly, but
 *  are used to define other types available through
 *  port.h and mach_types.h for in-kernel entities.
 */

import Foundation


typealias ipc_table_index_t = natural_t /*  index into tables   */
typealias ipc_table_elems_t = natural_t /*  size of tables      */
typealias ipc_entry_bits_t = natural_t
typealias ipc_entry_num_t = ipc_table_elems_t   /*  number of entries   */
typealias ipc_port_request_index_t = ipc_table_index_t

typealias ipc_entry_t = UnsafeMutablePointer<ipc_entry>?

typealias ipc_table_size_t = UnsafeMutablePointer<ipc_table_size>?
typealias ipc_port_request_t = UnsafeMutablePointer<ipc_port_request>?
typealias ipc_pset_t = UnsafeMutablePointer<ipc_pset>?
typealias ipc_kmsg_t = UnsafeMutablePointer<ipc_kmsg>?
typealias sync_qos_count_t = UInt8

func IE_NULL() { ipc_entry_t = nil }

func ITS_NULL() { ipc_table_size_t = nil }
func ITS_SIZE_NONE() { ipc_table_elems_t = -1 }
func IPR_NULL() { ipc_port_request_t = nil }
func IPS_NULL() { ipc_pset_t = nil }
func IKM_NULL() { ipc_kmsg_t = nil }

let mach_msg_continue_t: ((mach_msg_return_t) -> ())?   /*  After wakeup  */
func MACH_MSG_CONTINUE_NULL() { mach_msg_continue_t = nil }

let ipc_importance_elem_t: UnsafeMutablePointer<ipc_importance_elem>?
func IIE_NULL() { ipc_importance_elem_t = nil }

let ipc_importance_task_t: UnsafePointer<ipc_importance_task>?
func IIT_NULL() { ipc_importance_task_t = nil }

let ipc_importance_inherit_t: UnsafePointer<ipc_importance_inherit>?
func III_NULL() { ipc_importance_inherit_t = nil }
