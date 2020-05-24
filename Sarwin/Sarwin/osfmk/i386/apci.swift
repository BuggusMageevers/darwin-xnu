//
//  apci.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/22/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
 *  Advanced Programmable Interrupt Controller (APCI) is for use in intel
 *  multiprocessors.  This is a list of interrupts that are sent between
 *  processors.  The Local APIC performs two functions:
 *  #1 - Within the chip there is an APIC unit receives interrupts from the
 *  processor's interrupt pins.  It then sends these interrupts to the core for
 *  handling.
 *  #2 - In a multiple processor (MP) system, the APIC sends and receives inter-
 *  processor interrupts (IPI's) to and from other logical processors on the
 *  system bus.  IPI's are used to distribute interrupt messages among the
 *  processors, or perform system functions (e.g. booting or distributing work).
 *
 *  The I/O APIC is the external part of the Intel chipset used to receive
 *  external interrupts events from the system and then relay those interrupts
 *  to the Local APIC.  In MP systems, interrupts for distributing work to
 *  select processors or groups of processors on the system bus.
//
 *  Local APIC Interrupt Services:
 *      **Locally Connected I/O Devices**
 *      **Externally Connected I/O Devices**
 *      **Inter-processor Interupts**
 *      **APIC Timer Generated Interrupts**
 *      **Performance Monitoring Counter Interrupts**
 *      **Thermal Senor Interrupts**
 *      **APIC Internal Error Interrupts**
 *  **Local Interrup Sources** include the LINT0 and LINT1 pins, APIC timer,
 *  performance-monitoring counters, termal sensor, and internal APIC error
 *  detector.  Interrupts from these sources are received by the Local APIC and
 *  sent to the procesor core via an interrupt delivery protocol set up by a
 *  group of APIC registers called the **Local Vector Table** (LVT).  Delivery
 *  protocols for source can be set to each pin in the LVT.
 *  The Local APIC handles interrupt delivery of the remaining two sources
 *  (externally connected devices and IPI's) itself.
 *
 *  A given processor can utilize the APIC's **Interrupt Command Register**
 *  (ICR) to generate an IPI.  Writing to the ICR automatically generates and
 *  sends the IPI through the system bus (on Pentium 4 and Intel Xenon
 *  processors) or the APIC bus (on Pentium  and P6 family processors).  IPI's
 *  received by a processor are automatically handled by the receiving
 *  processor's Local APIC.
//
 *  The older Pentium an P6 family processors communicate through a 3-wire APIC
 *  bus while the new Pentium 4, Xenon, and onward have utilized the System Bus.
 *  For communication between the I/O APIC and Local APIC, a bridge is used
 *  (xAPIC and x2APIC architectures).  The bridge generates interrupt messages
 *  that go to the Local APIC(s) of a SP or MP system.
//
 *  Software interacts with the Local APIC by reading and writing to registers.
 *  The registers of the Local APIC are mapped to a 4-KByte region of the
 *  processor's physical address space.  The initial starting address is
 *  FEE0_000H.  The area of memory used must be designated as *strong
 *  uncacheable* (UC).  In an MP system the (including systems with Intel 64 and
 *  IA-32 bit processors), the Local APIC registers are mapped the same area.
 *  Local APIC registers may be remapped to separate/different 4-KByte memory
 *  regions.  Processors with the x2APIC may utilize xAPIC and x2APIC modes
 *  (x2APIC mode offers extened processor addressibility).  NOTE:  Pentium
 *  processors with an on-chip APIC, external bus cycles are produced.  DO NOT
 *  USE REGULAR SYSTEM MEMORY to map the APIC registers.  Behavior is either
 *  undefined or produces the invalid opcode exception (#UD).
 *
 *  Registers are 32, 64, or 256-bit widths aligned to 128-bit boundaries.  All
 *  32-bit registers should be accessed with 128-bit aligned 32-bit loads or
 *  stores.  FP/MMX/SSE access to an APIC register or access that touches bytes
 *  4-15 of any APIC register MAY CAUSE UNDEFINED BEHAVIOR OR RAISE EXCEPTIONS
 *  AND **SHOULD NOT BE DONE**.  Wider resgisters (64 and 256-bit) may be
 *  accessed via multiple 128-bit aligned 32-bit loads or stores.
 *
 *  **Local APIC Register Table**
 *  ___________________________________________________________________________
 * | FEE0_0000  | Reserved                                        |            |
 * | FEE0_0010  | Reserved                                        |            |
 * | FEE0_0020  | Local APIC ID Register                          | Read/Write |
 * | FEE0_0030  | Local APIC Version Register                     | Read Only  |
 * | FEE0_0040  | Reserved                                        |            |
 * | FEE0_0050  | Reserved                                        |            |
 * | FEE0_0060  | Reserved                                        |            |
 * | FEE0_0070  | Reserved                                        |            |
 * | FEE0_0080  | Task Priority Register (TPR)                    | Read/Write |
 * | FEE0_0090  | Arbitration Priority Register (APR) *1          | Read Only  |
 * | FEE0_00A0  | Processor Priority Register (PPR)               | Read Only  |
 * | FEE0_00B0  | EOI Resgister                                   | Write Only |
 * | FEE0_00C0  | Remote Read Register (RRR) *1                   | Read Only  |
 * | FEE0_00D0  | Logical Destination Register (LDR)              | Read/Write |
 * | FEE0_00E0  | Destination Format Register (DFR)               | Read/Write |
 * | FEE0_00F0  | Spurious Interrupt Vector Register              | Read/Write |
 * | FEE0_0100  | In-Service Register (ISR) bits 31-0             | Read Only  |
 * | FEE0_0110  | In-Service Register (ISR) bits 63-32            | Read Only  |
 * | FEE0_0120  | In-Service Register (ISR) bits 95-64            | Read Only  |
 * | FEE0_0130  | In-Service Register (ISR) bits 127-96           | Read Only  |
 * | FEE0_0140  | In-Service Register (ISR) bits 159-128          | Read Only  |
 * | FEE0_0150  | In-Service Register (ISR) bits 191-160          | Read Only  |
 * | FEE0_0160  | In-Service Register (ISR) bits 223-192          | Read Only  |
 * | FEE0_0170  | In-Service Register (ISR) bits 255-224          | Read Only  |
 * | FEE0_0180  | Trigger Mode Register (TMR) bits 31-0           | Read Only  |
 * | FEE0_0190  | Trigger Mode Register (TMR) bits 63-32          | Read Only  |
 * | FEE0_01A0  | Trigger Mode Register (TMR) bits 95-64          | Read Only  |
 * | FEE0_01B0  | Trigger Mode Register (TMR) bits 127-96         | Read Only  |
 * | FEE0_01C0  | Trigger Mode Register (TMR) bits 159-128        | Read Only  |
 * | FEE0_01D0  | Trigger Mode Register (TMR) bits 191-160        | Read Only  |
 * | FEE0_01E0  | Trigger Mode Register (TMR) bits 223-192        | Read Only  |
 * | FEE0_01F0  | Trigger Mode Register (TMR) bits 255-224        | Read Only  |
 * | FEE0_0200  | Interrup Request Register (IRR) bits 31-0       | Read Only  |
 * | FEE0_0210  | Interrup Request Register (IRR) bits 63-32      | Read Only  |
 * | FEE0_0220  | Interrup Request Register (IRR) bits 95-64      | Read Only  |
 * | FEE0_0230  | Interrup Request Register (IRR) bits 127-96     | Read Only  |
 * | FEE0_0240  | Interrup Request Register (IRR) bits 159-128    | Read Only  |
 * | FEE0_0250  | Interrup Request Register (IRR) bits 191-160    | Read Only  |
 * | FEE0_0260  | Interrup Request Register (IRR) bits 223-192    | Read Only  |
 * | FEE0_0270  | Interrup Request Register (IRR) bits 255-223    | Read Only  |
 * | FEE0_0280  | Error Status Register                           | Read Only  |
 * | FEE0_0290  | Reserved                                        |            |
 * | -FEE0_02E0 |                                                 |            |
 * | FEE0_02F0  | LVT CMCI Register                               | Read/Write |
 * | FEE0_0300  | Interrupt Command Register (ICR) bits 31-0      | Read/Write |
 * | FEE0_0310  | Interrupt Command Register (ICR) bits 63-32     | Read/Write |
 * | FEE0_0320  | LVT Timer Register                              | Read/Write |
 * | FEE0_0330  | LVT Thermal Sensor Register *2                  | Read/Write |
 * | FEE0_0340  | LVT Performance Monitoring Counters Register *3 | Read/Write |
 * | FEE0_0350  | LVT LINT0 Register                              | Read/Write |
 * | FEE0_0360  | LVT LINT1 Register                              | Read/Write |
 * | FEE0_0370  | LVT Error Register                              | Read/Write |
 * | FEE0_0380  | Initial Count Register (for Timer)              | Read/Write |
 * | FEE0_0390  | Current Count Register (for Timer)              | Read/Write |
 * | FEE0_03A0  | Reserved                                        |            |
 * | -FEE0_03D0 |                                                 |            |
 * | FEE0_03E0  | Divide Configuration Register (for Timer)       | Read/Write |
 * | FEE0_03F0  | Reserved                                        |            |
 *  ---------------------------------------------------------------------------
 *      *1 - NOT SUPPORTED on Pentium 4 and Xenon.  The Illegal Register Access
 *           bit (7) of the ESR will not be set when writing to these registers.
 *      *2 - Introduced in Pentium 4 and Xenon.  Implementation specific: the
 *           APIC register and associated function may not be present in future
 *           chip sets.
 *      *3 - Introduced in Pentium Pro.  Implementation specific: the APIC
 *           register and associated function may not be present in future chip
 *           sets.
 *
 *  Beginning with the P6 family of processors, the presence or absence of an
 *  on-chip Local APIC can be detected using the CPUID instruction.  Execute the
 *  CPUID instruction with a source operand of 1 in the EAX register.  Bit 9 of
 *  the CPUID feature flags returned by the EDX register the presence (set or 1)
 *  or absence (clear or 0).
 *
 *  Enable or disable the Local APIC using:
 *    Method 1:  Use the APIC global enable/disable flag in the IA32_APIC_BASE
 *      MSR.
 *    Method 2:  Use the APIC software enable/disable flag in the spurious-
 *      interrupt vector register
 *  In the Pentium processor, the APICEN pin (shared with the PICD1 pin) is
 *  used during power-up or reset to disable the Local APIC.
 *
 *  **APIC Status and Location** are contained in IA32_APIC_BASE MSR
 */

/*
 *  Input/Ouput Advanced Programmable Interrupt Controller (IOAPIC)
 */
enum IOAPIC: UInt32 {
   case start = 0xFEC0_0000
    case size = 0x0000_0020
    case redirectSelect = 0x0000_0000
    case redirectWindow = 0x0000_0010
}

/*
 *  Input/Output ?Atomic? (IOA)
 */
enum IOARedirect: UInt8 {
    case id = 0x00
    case idShift = 24
    case version = 0x01
    case versionMask = 0xFF     //  IOA_R_VERSION_MASK and IOA_R_VERSION_ME_MASK
                                //  consolidated to one mask
    case versionMEShift = 16
    case redirection = 0x10
}


