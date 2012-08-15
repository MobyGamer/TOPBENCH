; -----------------------------------------------------------------------------
; DPMI.ASH      DPMI interface defines and constants              Version 2.15
;
; Too-Much-in-0ne-So-Don't-Get-Lost(tm) Revision 2 CPU/FPU Detection Library
; Copyright(c) 1996-2000 by B-coolWare.
; -----------------------------------------------------------------------------
; Covers DPMI specs 0.9 and 1.0. Strange, but Microsoft, the founder of DPMI
; specification, did not manage to implement v1.0 host in their new OSes, like
; Windows 95 OSR2 or Windows 98... NT 4.0? don't know...
;
; Memory model should already be defined!
;
; Compilation of this file is affected by:
;
; __dpmi_HandleErrors__:
;                          type: define
;                       purpose: enable compilation of DPMI error handler
;                        values: defined/not defined
;                       default: not defined
;
; MODEL (only if __dpmi_HandleErrors__ is defined):
;                          type: assembler directive
;                       purpose: defines memory model
;                        values: all that apply
;                       default: not defined
;

IFDEF   __dpmi_HandleErrors__   ; include handler code
        .CODE
        LOCALS  @@
        JUMPS
ENDIF

; DPMI interrupt no.

dpmiInt                 equ     31h

; DPMI call macro

dpmiCall        macro Fn
        mov     ax,Fn
        int     dpmiInt
IFDEF   __dpmi_HandleErrors__
        call    dpmiError
ENDIF
        endm

dpmiCallStruc   struc
        dc_edi  dd    ?
        dc_esi  dd    ?
        dc_ebp  dd    ?
        dc_res  dd    ?
        dc_ebx  dd    ?
        dc_edx  dd    ?
        dc_ecx  dd    ?
        dc_eax  dd    ?
        dc_flg  dw    ?
        dc_es   dw    ?
        dc_ds   dw    ?
        dc_fs   dw    ?
        dc_gs   dw    ?
        dc_ip   dw    ?
        dc_cs   dw    ?
        dc_sp   dw    ?
        dc_ss   dw    ?
        ends

; DPMI 1.0 error codes

; codes 0000-7FFFh are DOS errors passed in by DPMI host

dpmiUnsupportedFn       equ     8001h   ; unsupported function
dpmiWrongObjectState    equ     8002h   ; wrong object state for function
dpmiIntegrityEndangered equ     8003h   ; system integrity would be endangered
dpmiDeadlockDetected    equ     8004h   ; deadlock detected
dpmiSerializeRqCancel   equ     8005h   ; pending serialization request cancelled
dpmiOutOfIntResources   equ     8010h   ; out of internal resources
dpmiNoDescriptor        equ     8011h   ; no descriptor available
dpmiNoLinearMemory      equ     8012h   ; no linear memory available
dpmiNoPhysicalMemory    equ     8013h   ; no physical memory available
dpmiNoBackingStore      equ     8014h   ; no backing store available
dpmiNoCallback          equ     8015h   ; no callback available
dpmiNoHandle            equ     8016h   ; no handle available
dpmiMaxLockCountExceed  equ     8017h   ; maximum lock count exceeded
dpmiSharedMemSerExcl    equ     8018h   ; shared memory already serialized exclusively
dpmiSharedMemSerShared  equ     8019h   ; shared memory already serialized by another client
dpmiInvalidValue        equ     8021h   ; invalid value
dpmiInvalidSelector     equ     8022h   ; invalid selector
dpmiInvalidHandle       equ     8023h   ; invalid handle
dpmiInvalidCallback     equ     8024h   ; invalid callback
dpmiInvalidLinearAddr   equ     8025h   ; invalid linear address
dpmiRqNotSupported      equ     8026h   ; request not supported

;       DPMI 0.9 & 1.0 function abbrevs, marked as "! 1.0" are only available
;       under DPMI 1.0-compliant host.

; LDT management
dpmiAllocateLDTDesc     equ     0000h   ; allocate LDT descriptors
dpmiFreeLDTDesc         equ     0001h   ; free LDT descriptors
dpmiSegment2Desc        equ     0002h   ; convert segment to descriptor
dpmiGetNextSelInc       equ     0003h   ; get next selector increment value
dpmiReserved1           equ     0004h   ; reserved, should not be called
dpmiReserved2           equ     0005h   ; reserved, should not be called
dpmiGetSegmentBase      equ     0006h   ; get segment base address
dpmiSetSegmentBase      equ     0007h   ; set segment base address
dpmiSetSegmentLimit     equ     0008h   ; set segment limit
dpmiSetAccessRights     equ     0009h   ; set segment access rights
dpmiCreateCodeAlias     equ     000Ah   ; create code segment alias descriptor
dpmiGetDescriptor       equ     000Bh   ; get LDT descriptor
dpmiSetDescriptor       equ     000Ch   ; set LDT descriptor
dpmiAllocSpecific       equ     000Dh   ; allocate specific LDT descriptor
dpmiGetMultipleDesc     equ     000Eh   ; get multiple LDT descriptors ! 1.0
dpmiSetMultipleDesc     equ     000Fh   ; set multiple LDT descriptors ! 1.0

; DOS memory management
dpmiAllocDOSBlock       equ     0100h   ; allocate DOS memory block
dpmiFreeDOSBlock        equ     0101h   ; free DOS memory block
dpmiResizeDOSBlock      equ     0102h   ; resize DOS memory block

; Interrupt services
dpmiGetRMVector         equ     0200h   ; get real mode interrupt vector
dpmiSetRMVector         equ     0201h   ; set real mode interrupt vector
dpmiGetExceptionHnd     equ     0202h   ; get exception handler address
dpmiSetExceptionHnd     equ     0203h   ; set exception handler
dpmiGetPMVector         equ     0204h   ; get protected mode interrupt vector
dpmiSetPMVector         equ     0205h   ; set protected mode interrupt vector
dpmiGetPMExtendedExcHnd equ     0210h   ; get pm extended exception handler ! 1.0
dpmiGetRMExtendedExcHnd equ     0211h   ; get rm extended exception handler ! 1.0
dpmiSetPMExtendedExcHnd equ     0212h   ; set pm extended exception handler ! 1.0
dpmiSetRMExtendedExcHnd equ     0213h   ; set rm extended exception handler ! 1.0

; Translation services
dpmiSimulateRMInt       equ     0300h   ; simulate Real Mode interrupt
dpmiCallRMFRoutine      equ     0301h   ; call RM routine with RETF frame
dpmiCallRMIRoutine      equ     0302h   ; call RM routine with IRET frame
dpmiAllocRMCallBack     equ     0303h   ; allocate RM call-back address
dpmiFreeRMCallBack      equ     0304h   ; free RM call-back address
dpmiGetSaveRestAddr     equ     0305h   ; get Save/Restore addresses
dpmiGetRawModeSw        equ     0306h   ; get raw mode switch addresses

; Get Version
dpmiGetVersion          equ     0400h   ; get DPMI version
dpmiGetCapabilities     equ     0401h   ; get DPMI host capabilities ! 1.0

; Memory management
dpmiGetMemFree          equ     0500h   ; get free memory information
dpmiMemAlloc            equ     0501h   ; allocate memory block
dpmiMemFree             equ     0502h   ; free memory block
dpmiMemResize           equ     0503h   ; resize memory block
dpmiAllocLinearBlock    equ     0504h   ; allocate linear memory block ! 1.0
dpmiResizeLinearBlock   equ     0505h   ; resize linear memory block ! 1.0
dpmiGetPageAtts         equ     0506h   ; get page attributes ! 1.0
dpmiModifyPageAttrs     equ     0507h   ; modify page attributes ! 1.0
dpmiMapDeviceInMemBlk   equ     0508h   ; map device in memory block ! 1.0
dpmiMapConvMemInMemBlk  equ     0509h   ; map conventional memory in memory block ! 1.0
dpmiGetMemBlockAndSize  equ     050Ah   ; get memory block and size ! 1.0
dpmiGetMemoryInfo       equ     050Bh   ; get memory information ! 1.0

; Page locking services
dpmiLockLinearReg       equ     0600h   ; Lock linear region
dpmiUnlockLinearReg     equ     0601h   ; unlock linear region
dpmiMarkRMRegPageable   equ     0602h   ; mark real mode region as pageable
dpmiRelockRMRegion      equ     0603h   ; relock real mode region
dpmiGetPageSize         equ     0604    ; get page size

; Demand paging performance tuning services
dpmiReserved3           equ     0700h   ; reserved, should not be called
dpmiReserved4           equ     0701h   ; reserved, should not be called
dpmiMarkAsDPC           equ     0702h   ; mark pageable as demand paging candidate
dpmiDiscardPage         equ     0703h   ; discard page contents

; Physical address mapping
dpmiMapPhysical         equ     0800h   ; map physical address to linear address
dpmiFreeMapPhysical     equ     0801h   ; free physical address mapping ! 1.0

; Virtual interrupt state functions
dpmiGetDisableVIS       equ     0900h   ; get and disable VIS
dpmiGetEnableVIS        equ     0901h   ; get and enable VIS
dpmiGetVIS              equ     0902h   ; get VIS

; Get vendor specific API entry point
dpmiGetVendorAPI        equ     0A00h   ; get vendor specific API entry point

; Debug register support
dpmiSetWatchpoint       equ     0B00h   ; set debug watchpoint
dpmiClearWatchpoint     equ     0B01h   ; clear debug watchpoint
dpmiGetWatchState       equ     0B02h   ; get state of debug watchpoint
dpmiResetWatchPoint     equ     0B03h   ; reset debug watchpoint

; TSR support (1.0+)
dpmiInstTSRHndCallback  equ     0C00h   ; install resident handler init callback
dpmiTSR                 equ     0C01h   ; Terminate and Stay Resident

; Shared Memory management (1.0+)
dpmiAllocSharedMemory   equ     0D00h   ; allocate shared memory block
dpmiFreeSharedMemory    equ     0D01h   ; free shared memory block
dpmiSerializeSharedMem  equ     0D02h   ; serialize shared memory block
dpmiFreeSerialization   equ     0D03h   ; free serialization of memory block

; Coprocessor services (1.0+)
; also supported by 386-max's DPMI 0.9 host
dpmiGetFPUStatus        equ     0E00h   ; get coprocessor status
dpmiSetFPUEmulation     equ     0E01h   ; set FPU emulation type


IFDEF   __dpmi_HandleErrors__

dpmiErrorTable  label word
        dw      offset dpmiEOk
        dw      offset dpmiEWrongCall
        dw      offset dpmiEWrongObjectState
        dw      offset dpmiEIntegrityEndangered
        dw      offset dpmiEDeadlockDetected
        dw      offset dpmiESerializeRqCancel
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOutOfIntResources
        dw      offset dpmiENoDescriptor
        dw      offset dpmiENoLinearMemory
        dw      offset dpmiENoPhysicalMemory
        dw      offset dpmiENoBackingStore
        dw      offset dpmiENoCallback
        dw      offset dpmiENoHandle
        dw      offset dpmiEMaxLockCountExceed
        dw      offset dpmiESharedMemSerExcl
        dw      offset dpmiESharedMemSerShared
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEOk
        dw      offset dpmiEInvalidValue
        dw      offset dpmiEInvalidSelector
        dw      offset dpmiEInvalidHandle
        dw      offset dpmiEInvalidCallback
        dw      offset dpmiEInvalidLinearAddr
        dw      offset dpmiERqNotSupported

dpmiEOk:
        db      '$'
dpmiEWrongCall:
        db      'DPMI Error: Invalid Function Requested',13,10,'$'
dpmiEWrongObjectState:
        db      'DPMI Error: Wrong Object State For Called Function',13,10,'$'
dpmiEIntegrityEndangered:
        db      'DPMI Error: System Integrity Would Be Endangered',13,10,'$'
dpmiEDeadlockDetected:
        db      'DPMI Error: Deadlock Detected',13,10,'$'
dpmiESerializeRqCancel:
        db      'DPMI Error: Pending Serialization Request Cancelled',13,10,'$'
dpmiEOutOfIntResources:
        db      'DPMI Error: Out Of Internal DPMI Resources',13,10,'$'
dpmiENoDescriptor:
        db      'DPMI Error: Descriptor Unavailable',13,10,'$'
dpmiENoLinearMemory:
        db      'DPMI Error: Linear Memory Unavailable',13,10,'$'
dpmiENoPhysicalMemory:
        db      'DPMI Error: Physical Memory Unavailable',13,10,'$'
dpmiENoBackingStore:
        db      'DPMI Error: Backing Store Unavailable',13,10,'$'
dpmiENoCallback:
        db      'DPMI Error: Callback Unavailable',13,10,'$'
dpmiENoHandle:
        db      'DPMI Error: Handle Unavailable',13,10,'$'
dpmiEMaxLockCountExceed:
        db      'DPMI Error: Maximum Lock Count Exceeded',13,10,'$'
dpmiESharedMemSerExcl:
        db      'DPMI Error: Shared Memory Already Serialized Exclusively',13,10,'$'
dpmiESharedMemSerShared:
        db      'DPMI Error: Shared Memory Already Serialized Shared',13,10,'$'
dpmiEInvalidValue:
        db      'DPMI Error: Invalid Value Specified',13,10,'$'
dpmiEInvalidSelector:
        db      'DPMI Error: Invalid Selector Specified',13,10,'$'
dpmiEInvalidHandle:
        db      'DPMI Error: Invalid Handle Specified',13,10,'$'
dpmiEInvalidCallback:
        db      'DPMI Error: Invalid Callback Specified',13,10,'$'
dpmiEInvalidLinearAddr:
        db      'DPMI Error: Invalid Linear Address Specified',13,10,'$'
dpmiERqNotSupported:
        db      'DPMI Error: Request Not Supported',13,10,'$'

dpmiError       proc
        test    ax,ax
        jz      @@noError
        test    ax,8000h
        jz      @@noError       ; this is a DOS error, not DPMI
        push    dx bx
        mov     bx,ax
        and     bx,not 8000h
        shl     bx,1            ; get entry into error table
        mov     dx,dpmiErrorTable[bx]
        cmp     dx,offset dpmiEOk       ; unknown error or no error
        jz      @@noError
        mov     ah,9
        int     21h             ; print out the error description
        pop     bx dx
@@noError:
        ret
        endp

ENDIF   ;__dpmi_HandleErrors__
