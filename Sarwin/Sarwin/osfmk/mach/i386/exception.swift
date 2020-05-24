//
//  exception.swift
//  Sarwin
//
//  Created by Myles La Verne Schultz on 5/7/20.
//  Copyright © 2020 MyKo. All rights reserved.
//

import Foundation


/*
/***************************************************************/
//  FIXME:  Should be an enum?

/*
 *  No machine dependent types for the 80386
 */
let EXC_TYPES_COUNT: UInt8 = 14 /* incl. illegal exception 0 */

/*
 *  Codes and subcodes for 80386 exceptions.
 */
let EXCEPTION_CODE_MAX:UInt8 = 2    /* currently code and subcode */

/*
 *  EXC_BAD_INSTRUCTION
 */
let EXC_I386_INVOP: UInt8 = 1

/*
 *  EXC_ARITHMETIC
 */
let EXC_I386_DIV: UInt8 = 1
let EXC_I386_INTO: UInt8 = 2
let EXC_I386_NOEXT: UInt8 = 3
let EXC_I386_EXTOVR: UInt8 = 4
let EXC_I386_EXTERR: UInt8 = 5
let EXC_I386_EMERR: UInt8 = 6
let EXC_I386_BOUND: UInt8 = 7
let EXC_I386_SSEEXTERR: UInt8 = 8

/*
 *  EXC_SOFTWARE
 *  Note: 0x10000-0x10003 in use for unix signal
 */

/*
 *  EXC_BAD_ACCESS
 */

/*
 *  EXC_BREAKPOINT
 */

let EXC_I386_SGL: UInt8 = 1
let EXC_I386_I386: UInt8 = 2

let EXC_I386_DIVERR: UInt8 = 0      /*  divide by 0 error               */
let EXC_I386_SGLSTP: UInt8 = 1      /*  single step                     */
let EXC_I386_NMIFLT: UInt8 = 2      /*  NMI                             */
let EXC_I386_BPTFLT: UInt8 = 3      /*  breakpoint fault                */
let EXC_I386_INTOFLT: UInt8 = 4     /*  INTO overflow fault             */
let EXC_I386_BOUNDFLT: UInt8 = 5    /*  BOUND instruction fault         */
let EXC_I386_INVOPFLT: UInt8 = 6    /*  invalid opcode fault            */
let EXC_I386_NOEXTFLT: UInt8 = 7    /*  extension not available fault   */
let EXC_I386_DBLFLT: UInt8 = 8      /*  double fault                    */
let EXC_I386_EXTOVRFLT: UInt8 = 9   /*  extension overrun fault         */
let EXC_I386_INVTSSFLT: UInt8 = 10  /*  invalid TSS fault               */
let EXC_I386_SGNPFLT: UInt8 = 11    /*  segment not present fault       */
let EXC_I386_STKFLT: UInt8 = 12     /*  stack fault                     */
let EXC_I386_GPFLT: UInt = 13       /*  general protection fault        */
let EXC_I386_PGFLT: UInt8 = 14      /*  page fault                      */
let EXC_I386_EXTERRFLT: UInt8 = 16  /*  extension error fault           */
let EXC_I386_ALIGNFLT: UInt8 = 17   /*  alignment fault                 */
let EXC_I386_ENDPERR: UInt8 = 33    /*  emulated extension error fault  */
let EXC_I386_ENDEXTFLT: UInt8 = 32  /*  emulated ext no present         */


/*
 *  machine dependent exception masks
 */
let EXC_MASK_MACHINE: UInt8 = 0
*/
