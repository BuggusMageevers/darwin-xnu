//
//  fp_reg.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/8/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
/******************************************************************************/
#if  MACH_KERNEL_PRIVATE
struct x86_fx_thread_state {
    let fx_control: UInt16          /*  control             */
    let fx_status: UInt16           /*  status              */
    let fx_tag: UInt8               /*  register tags       */
    let fx_bbz1: UInt8              /*  better be zero when calling fxrtstor    */
    let fx_opcode: UInt16
    enum BitLayout {
        case thirtyTwo(Bit32)
        case sixtyFour(Bit64)
        struct Bit32 {              /*  32-bit layout       */
            let fx_eip: UInt32      /*  eip instruction     */
            let fx_cs: UInt16       /*  cs instruction      */
            let fx_bbz2: UInt16     /*  better be zero when calling fxrtstor    */
            let fx_dp: UInt32       /*  data address        */
            let fx_ds: UInt16       /*  data segment        */
            let fx_bbz3: UInt16     /*  better be zero when calling fxrtstor    */
        }
        struct Bit64 {
            let fx_rip: UInt64      /*  instruction pointer */
            let fx_rdp: UInt64      /*  data pointer        */
        }
    }
    let fx_MXCSR: UInt32
    let fx_MXCSR_MASK: UInt32
    let fx_reg_word: [[UInt16]]     /*  STx/MMx registers, should an 8x8 array  */
    let fx_XMM_reg: [[UInt16]]      /*  XMM0-XMM15 on 64 bit processors, should be an 8x16 array    */
                                    /*  XMM0-XMM7 on 32 bit processors... unused storage reserved   */
    
    let fx_reserved: [UInt8]        /*  reserved by Intel for future * expansion, size 16*5    */
    let fp_valid: UInt32
    let fp_save_layout: UInt32
    let fx_pad: [UInt8]             /*  size of 8   */
}

struct xsave_header {
    let xstate_bv: UInt64
    let xcomp_bv: UInt64
    let xhrsvd: [UInt8]             /*  size of 48  */
}

struct reg128_t {
    let lo64: UInt64
    let hi64: UInt64
}
struct reg256_t {
    let lo128: reg128_t
    let hi128: reg128_t
}
struct reg512_t {
    let lo256: reg256_t
    let hi256: reg256_t
}

struct x86_avx_thread_state {
    let fp: x86_fx_thread_state
    let xh: xsave_header            /*  Offset 512, xsave header            */
    let x_YMM_Hi128: [reg128_t]     /*  Offset 576, high YMMs, size of 16   */
                                    /*  Offset 832, end                     */
}

struct x86_avx512_thread_state {
    let fp: x86_fx_thread_state
    let hx: xsave_header            /*  Offset 512, xsave header            */
    let x_YMM_Hi128: [reg128_t]     /*  Offset 576, high YMMs, size of 16   */
    
    let x_pad: [UInt64]             /*  Offset 832, unused AMD LWP, size of 16  */
    let x_BNDRegs: [UInt64]         /*  Offset 960, unused MPX, size of 8   */
    let x_BNDCTL: [UInt64]          /*  Offset 1024, unused MPX, size of 8  */
    
    let x_Opmask: [UInt64]          /*  Offset 1088, K0-K7, size of 8       */
    let x_ZMM_Hi256: [reg256_t]     /*  Offset 1152, ZMM0..15[511:256], size of 16  */
    let x_Hi16_ZMM: [reg512_t]      /*  Offset 1664, ZMM15..31[511:0], size of 16   */
                                    /*  Offset 2688, ed                     */
}

enum x86_ext_thread_state_t {
    case fx(x86_fx_thread_state)
    case avx(x86_avx_thread_state)
    case avx512(x86_avx512_thread_state)
}

let EVEX_PREFIX: UInt8 = 0x62  /*  AVX512's EVEX vector operation prefix       */
let VEX2_PREFIX: UInt8 = 0xC5  /*  VEX 2-byte prefix for Opmask instructions   */
let VEX3_PREFIX: UInt8 = 0xC4  /*  VEX 3-byte prefix for Opmask instructions   */

#endif  /*  MACH_KERNEL_PRIVATE  */
/******************************************************************************/

/*
 *  Control register
 */
let FPC_IE: UInt16 = 0x0001         /*  enable invalid operation exception      */
let FPC_IM: UInt16 = FPC_IE
let FPC_DE: UInt16 = 0x0002         /*  enable denormalized operation exception */
let FPC_DM: UInt16 = FPC_DE
let FPC_ZE: UInt16 = 0x0004         /*  enable zero-divide exception            */
let FPC_ZM: UInt16 = FPC_ZE
let FPC_OE: UInt16 = 0x0008         /*  enable overflox exception               */
let FPC_OM: UInt16 = FPC_OE
let FPC_UE: UInt16 = 0x0010         /*  enable underflow exception              */
let FPC_PE: UInt16 = 0x0020         /*  enable precision exception              */
let FPC_PC: UInt16 = 0x0300         /*  percision control:                      */
let FPC_PC_24: UInt16 = 0x0000      /*      24 bits                             */
let FPC_PC_53: UInt16 = 0x0200      /*      53 bits                             */
let FPC_PC_64: UInt16 = 0x0300      /*      64 bits                             */
let FPC_RC: UInt16 = 0x0c00         /*  rouding control:                        */
let FPC_RC_RN: UInt16 = 0x0000      /*      round to nearest or even            */
let FPC_RC_RD: UInt16 = 0x0400      /*      round down                          */
let FPC_RC_RU: UInt16 = 0x0800      /*      round up                            */
let FPC_RC_CHOP: UInt16 = 0x0c00    /*      chop                                */
let FPC_IC: UInt16 = 0x1000         /*  infinity control (obsolete)             */
let FPC_IC_PROJ: UInt16 = 0x0000    /*      projection infinity                 */
let FPC_IC_AFF: UInt16 = 0x1000     /*      affine infinity (std)               */

/*
 *  Status register
 */
let FPS_IE: UInt16 = 0x0001     /*  invalid operation       */
let FPS_DE: UInt16 = 0x0002     /*  denormalized operand    */
let FPS_ZE: UInt16 = 0x0004     /*  divide by zero          */
let FPS_OE: UInt16 = 0x0008     /*  overflow                */
let FPS_UE: UInt16 = 0x0010     /*  underflow               */
let FPS_PE: UInt16 = 0x0020     /*  precision               */
let FPS_SF: UInt16 = 0x0040     /*  stack flag              */
let FPS_ES: UInt16 = 0x0080     /*  error summary           */
let FPS_C0: UInt16 = 0x0100     /*  condition code bit 0    */
let FPS_C1: UInt16 = 0x0200     /*  condition code bit 1    */
let FPS_C2: UInt16 = 0x0400     /*  condition code bit 2    */
let FPS_TOS: UInt16 = 0x3800    /*  top-of-stack pointer    */
let FPS_TOS_SHIFT: UInt16 = 11
let FPS_C3: UInt16 = 0x4000     /*  condition code bit 3    */
let FPS_BUSY: UInt16 = 0x8000   /*  FPU busy                */

/*
 *  Kind of floating-point support provided by kernel.
 */
let FP_NO: UInt16 = 0       /*  no floating point                   */
let FP_SOFT: UInt16 = 1     /*  software FP emulator                */
let FP_287: UInt16 = 2      /*  80287                               */
let FP_387: UInt16 = 3      /*  08387                               */
let FPFXSR: UInt16 = 5      /*  fast save/resotre SIMD Extension    */
*/
