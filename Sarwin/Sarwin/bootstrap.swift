//
//  bootstrap.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/1/20.
//  Copyright © 2020 MyKo. All rights reserved.
//


//  MARK: - Bootstrap Declarations
protocol Bootstrap {
    static func recordStarupExtensionsFunction()
    static func loadSecurityExtensionsFunction()
    static func bootstrapRecordStartupExtensions()
    static func bootstrapLoadSecurityExtension()
    
    #if NO_KEXTD
    static func iORamDiskBSDRoot()
    #endif
}


//  MARK: - Kernel Component Kext Identifiers
enum sKernelComponentNames {
    case kernel
    case kpiBSD
    case kpiDSEP
    case kpiIOKit
    case kpiKasan
    case kpiLibraryKernel
    case kpiMachine
    case kpiPrivate
    case kpiUnsupported
    case ioKitNVRAMFamily
    case driverAppleNMI
    case ioKitIOSystemManagementFamily
    case ioKitApplePlatformFamily
}

