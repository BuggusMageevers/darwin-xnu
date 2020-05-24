//
//  kern_return.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/3/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
typealias kern_return_t = Int32

/***********************************************************
enum KernelReturn: Int16 {
    let success
    let invalidAddress
    let protectionFailure
    let noSpace
    let invalidArgument
    let failure
    let resourceShortage
    let notReceiver
    let noAccess
    let memoryFailure
    let memoryError
    let alreadyInSet
    let notInSet
    let nameExists
    let aborted
    let invalidName
    let invalidTask
    let invalidRight
    let invalidValue
    let urefsOverflow  //  FIXME: userReferenceOverflow?
    let invalidCapability
    let rightExists
    let invalidHost
    let memorPresent
    let memoryDataMoved
    let memoryRestartCopy
    let invalidProcessorSet
    let policyLimit
    let invalidPolicy
    let invalidObject
    let alreadyWaiting
    let defaultSet
    let exceptionProtected
    let invalidLedger
    let invalidMemoryControl
    let invalidSecurity
    let notDepressed
    let terminated
    let lockSetDestroyed
    let lockUnstable
    let lockOwned
    let lockOwnedSelf
    let semaphoreDestroyed
    let rpcServerTerminated
    let rpcTerminateOrphan
    let rpcContinueOrphan
    let notSupported
    let nodeDown
    let notWaiting
    let operationTimedOut
    let codesignError
    let policyStatic
    let insufficientBufferSize
    let returnMax = 256
}
 */
//  FIXME:  Shoulde be an enum as above?
let KERN_SUCCESS: UInt32 = 0
let KERN_INVALID_ADDRESS: UInt32 = 1
let KERN_PROTECTION_FAILURE: UInt32 = 2
let KERN_NO_SPACE: UInt32 = 3
let KERN_INVALID_ARGUMENT: UInt32 = 4
let KERN_FAILURE: UInt32 = 5
let KERN_RESOURCE_SHORTAGE: UInt32 = 6
let KERN_NOT_RECEIVER: UInt32 = 7
let KERN_NO_ACCESS: UInt32 = 8
let KERN_MEMORY_FAILURE: UInt32 = 9
let KERN_MEMORY_ERROR: UInt32 = 10
let KERN_ALREADY_IN_SET: UInt32 = 11
let KERN_NOT_IN_SET: UInt32 = 12
let KERN_NAME_EXISTS: UInt32 = 13
let KERN_ABORTED: UInt32 = 14
let KERN_INVALID_NAME: UInt32 = 15
let KERN_INVALID_TASK: UInt32 = 16
let KERN_INVALID_RIGHT: UInt32 = 17
let KERN_INVALID_VALUE: UInt32 = 18
let KERN_UREFS_OVERFLOW: UInt32 = 19  //  FIXME: userReferenceOverflow?
let KERN_INVALID_CAPABILITY: UInt32 = 20
let KERN_RIGHT_EXISTS: UInt32 = 21
let KERN_INVALID_HOST: UInt32 = 22
let KERN_MEMORY_PRESENT: UInt32 = 23
let KERN_MEMORY_DATA_MOVED: UInt32 = 24
let KERN_MEMORY_RESTART_COPY: UInt32 = 25
let KERN_INVALID_PROCESSOR_SET: UInt32 = 26
let KERN_POLICY_LIMIT: UInt32 = 27
let KERN_INVALID_POLICY: UInt32 = 28
let KERN_INVALID_OBJECT: UInt32 = 29
let KERN_ALREADY_WAITING: UInt32 = 30
let KERN_DEFAULT_SET: UInt32 = 31
let KERN_EXCEPTION_PROTECTED: UInt32 = 32
let KERN_INVALID_LEDGER: UInt32 = 33
let KER_INVALID_MEMORY_CONTROL: UInt32 = 34
let KERN_INVALID_SECURITY: UInt32 = 35
let KERN_NOT_DEPRESSED: UInt32 = 36
let KERN_TERMINATED: UInt32 = 37
let KERN_LOCK_SET_DESTROYED: UInt32 = 38
let KERN_LOCK_UNSTABLE: UInt32 = 39
let KERN_LOCK_OWNED: UInt32 = 40
let KERN_LOCK_OWNED_SELF: UInt32 = 41
let KERN_SEMAPHORE_DESTROYED: UInt32 = 42
let KERN_RPC_SERVER_TERMINATED: UInt32 = 43
let KERN_RPC_TERMINATE_ORPHAN: UInt32 = 44
let KERN_RPC_CONTINUE_ORPHAN: UInt32 = 45
let KERN_NOT_SUPPORTED: UInt32 = 46
let KERN_NODE_DOWN: UInt32 = 47
let KERN_NOT_WAITING: UInt32 = 48
let KERN_OPERATION_TIMED_OUT: UInt32 = 49
let KERN_CODESIGN_ERROR: UInt32 = 50
let KERN_POLICY_STATIC: UInt32 = 51
let KERN_INSUFFICIENT_BUFFER_SIZE: UInt32 = 52
let returnMax: UInt32 = 0x100
/**********************************************************/
*/
