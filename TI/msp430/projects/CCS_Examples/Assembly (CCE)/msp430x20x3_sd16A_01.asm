;*******************************************************************************
;   MSP430F20x3 Demo - SD16A, Sample A1+ Continuously, Set P1.0 if > 0.3V
;
;   Description: A continuous single-ended sample is made on A1+ using internal
;   VREf. Unipolar output format used.
;   Inside of SD16 ISR, if A1 > 1/2VRef (0.3V), P1.0 set, else reset.
;   ACLK = n/a, MCLK = SMCLK = SD16CLK = default DCO
;
;                 MSP430F20x3
;              ------------------
;          /|\|              XIN|-
;           | |                 |
;           --|RST          XOUT|-
;             |                 |
;     Vin+ -->|A1+ P1.2         |
;             |A1- = VSS    P1.0|-->LED
;             |                 |
;
;   P.Thanigai
;   Texas Instruments Inc.
;   May 2007
;   Built with Code Composer Essentials Version: 2.0
;*******************************************************************************
 .cdecls C,LIST,  "msp430x20x3.h"
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0280h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 output
SetupSD16   mov.w   #SD16REFON+SD16SSEL_1,&SD16CTL  ; 1.2V ref, SMCLK
            mov.b   #SD16INCH_1,&SD16INCTL0       ; A1+/-
            mov.w   #SD16UNI+SD16IE,&SD16CCTL0    ; 256OSR, unipolar, inter
            mov.b   #SD16AE2,&SD16AE        ; P1.1 A1+, A1- = VSS
            bis.w   #SD16SC,&SD16CCTL0      ; Start conversion
                                            ;				
Mainloop    bis.w   #CPUOFF+GIE,SR          ; CPU off, enable interrupts
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
SD16_ISR;
;-------------------------------------------------------------------------------
            bic.b   #01h,&P1OUT             ;
            cmp.w   #07FFFh,&SD16MEM0       ; SD16MEM0 > 0.3V?, clears IFG
            jlo     Done                    ;
            bis.b   #01h,&P1OUT             ;
Done        reti                            ;		
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int05"                ; SD16 Vector
            .short  SD16_ISR                ;
            .end
