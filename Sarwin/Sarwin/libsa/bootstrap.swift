//
//  bootstrap.swift
//  Translation:
//      libsa/bootstrap.cpp
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
/*********************************************************************
 * Kernel Component Kext Identifiers
 *
 * We could have each kernel resource kext automatically "load" as
 * it's created, but it's nicer to have them listed in kextstat in
 * the order of this list. We'll walk through this after setting up
 * all the boot kexts and have them load up.
 *********************************************************************/
enum sKernelComponentNames {
    // The kexts for these IDs must have a version matching 'osrelease'.
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
    
    static func __whereIs(address: UInt, segmentSizes: [UInt], segmentAddresses: [UInt], segmentCount count: Int8) {
        //  FIXME:  Add function body to __whereIs(_:_:_:_:)
    }
}

//  FIXME:  Shoulder be named "Platform Kernel Segments", or "Phylogenetic Likelihood Kernel Segments"?
let __platformKernalSegments = 12

enum PlatformKernalSegmentNames {
    case __TEXT
    case __TEXT_EXEC
    case __DATA
    case __DATA_CONST
    case __LINKEDIT
    case __PRELINK_TEXT
    case __PLK_TEXT_EXEC
    case __PRELINK_DATA
    case __PLK_DATA_CONST
    case __PLK_LLVM_COV
    case __PLK_LINKEDIT
    case __PRELINK_INFO
}


 // MARK: - KLDBootstrap Class
class KLDBootstrap {
    //  FIXME: kernel_section_t needs a real type
    typealias kernel_section_t = Int
    //  FIXME: OSReturn needs a real type
    typealias OSReturn = Int
    func bootstrapRecordStartupExtensions() {}
    func bootstrapLoadSecurityExtension() {}
    
    private func readStartupExtensions() {
        var prelinkInfoSection: kernel_section_t? = nil
        
        OSKextLog(nil,
                  kOSKextLogProfressLevel |
        kOSKextLogGeneralFlag | kOSKextLogDirectoryScanFlag |
        kOSKextLogKextBookkeepingFlag,
                  "Reading startup extensions.")
        
        /* If the prelink info segment has a nonzero size, we are prelinked
         * and won't have any individual kexts or mkexts to read.
         * Otherwise, we need to read kexts or the mkext from what the booter
         * has handed us.
         */
        prelinkInfoSection = getSection(byName: kPrelinkInfoSegment, kPrelinkInfoSection)
        if let section = prelinkInfoSection {
            if section.size > 0 {
                readPrelinkedExtension
            }
        }
    }
    private func readPrelinkExtension(prelinkInfoSection: kernel_section_t) {}
    private func readBooterExtensions() {}
    private func loadKernelComponentKexts() -> OSReturn {}
    private func funcloadKernelExternalComponents() {}
    private func readBuildtinPersonalities() {}
    private func loadSecurityExtensions() {}
    
    /*********************************************************************
     * Set the function pointers for the entry points into the bootstrap
     * segment upon C++ static constructor invocation.
     *********************************************************************/
    func KLDBootstrap() {
        if self != sBootstrapObject {
            panic("Attempt to access bootstrap segment.")
        }
        
        record_startup_extensions_function = 0
        load_security_extensions_function = 0
    }
    func _KLDBootstrap() {}
}

typealias sBootstrapObject = KLDBootstrap
