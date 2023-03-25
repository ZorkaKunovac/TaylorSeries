;Taylorova serija/red sa 4 uslova
; (x = x - x^3/3! + x^5/5! - x^7/7! ) 
; Formula funkcionise za svako x u rangu [0, pi/2]
; Upotreba registra
; S0 - ulazni operand i povratni rezultat
; S1 - 1/3! (invfact3)
; S2 - 1/5! (invfact5)
; S3 - 1/7! (invfact7)
; S4 - x * S1 (xdiv3!), zatim S4*S7 (x^2 * xdiv3!) (x3div3!)
; S5 - x * S2 (xdiv5!), zatim S5*S8 (x^4 * xdiv5!) (x5div5!)
; S6 - x * S3 (xdiv7!), zatim S6*S9 (x^6 * xdiv7!) (x7div7!)
; S7 - x ^ 2
; S8 - x ^ 4
; S9 - x ^ 6
; S10 - pomocni
; Izbjegava se dijeljenje racunanjem  1/3! , 1/5! itd. i koristenje konstanti pri mnozenju


			AREA Tylor_Se, CODE, READONLY
			EXPORT __main

__main

		LDR R0,=0xE00ED88
		LDR R1,[R0]
		
		ORR R1,R1, #(0xF<<20)
		STR R1,[R0]
		DSB
		ISB
		
		VLDR.F32 	S0,=1.04719
		BL			SinCalculator
		
STOP	B			STOP

SinCalculator

			VLDR.F32	S1,invfact3
			VLDR.F32	S2,invfact5
			VLDR.F32	S3,invfact7
			
			VMUL.F32	S4, S0, S1	;racuna xdiv3
			VMUL.F32	S7, S0, S0	;racuna x^2
			VMUL.F32	S4, S4, S7  ;racuna x3div3
			VMUL.F32	S5, S0, S2	;racuna xdiv5
			VMUL.F32	S8, S7, S7	;racuna x^4		
			VMUL.F32 	S9, S7, S8	;racuna x^6
			
			VMUL.F32 	S6, S0, S3	;racuna xdiv7			
			VMUL.F32	S5, S5, S8	;racuna x5div5			
			VMUL.F32	S6, S6, S9	;racuna x7div7
			
			VSUB.F32	S10, S0, S4 ;racuna x-x^3/3!
			VADD.F32	S10, S10,S5 ;racuna x-x^3/3! + x^5/5!
			VSUB.F32	S0, S10, S6 ;konacan rezultat
			
			BX LR

invfact3	DCD 	0x3E2AAAAA	;1/3!
invfact5	DCD		0x3C088888	;1/5!
invfact7	DCD		0x39500D00 	;1/7!
			
			
			
			
			
; Primjer faktorijela sa IT blokom	
;		MOV 	R0,#5
;		MOV		R1, #1
;		
;loop	CMP 	R0,#0
;		ITTT 	GT
;		MULGT	R1,R0,R1
;		SUBGT	R0,R0,#1
;		BGT		loop		




; PRIMJER REKURZIVNOG FAKTORIJELA
;		 MOV	R0,#8
;Fact	 CMP	R0,#1
;		 BLS    done 	;lower or same
;		 PUSH	{R0,LR}
;		 SUB	R0,R0,#1 ; n=n-1
;		 BL		Fact
;		 POP	{R1,LR}
;		 MUL	R0,R0,R1; R0 = n* Fact(n-1)
;		 BX		LR		 
;		 
;done	 MOV	R0,#1
;		 BX		LR
;		 ALIGN
;		 END