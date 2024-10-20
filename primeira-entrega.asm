; USAR TECLADO PRA TEMPERATURA
; USAR CONTADOR PARA NUMERO DE VOLTAS EM VEZ DE VELOCIDADE

RS equ P1.3 
EN equ P1.2 
temp equ 02H

org 0000h
	LJMP MAIN

ORG 0040h              
arrayTeclas:
    DB 'X', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2', '1'

org 0100h
MAIN:
	mov temp, #55
	acall lcd_init
	mov A, #02h
	ACALL posicionaCursor 
	MOV A, #'T'
	ACALL sendCharacter	
	MOV A, #'E'
	ACALL sendCharacter
	MOV A, #'M'
	ACALL sendCharacter	
	MOV A, #'P'
	ACALL sendCharacter	
	MOV A, #'E'
	ACALL sendCharacter	
	MOV A, #'R'
	ACALL sendCharacter	
	MOV A, #'A'
	ACALL sendCharacter	
	MOV A, #'T'
	ACALL sendCharacter
	MOV A, #'U'
	ACALL sendCharacter	
	MOV A, #'R'
	ACALL sendCharacter	 
	MOV A, #'A'
	ACALL sendCharacter	
	MOV A, #43H
	ACALL posicionaCursor
	acall aguardaInput
	acall traduzTeclaPressionada
	acall displayTemperatura
	mov A, #'C'
	acall sendCharacter
	mov A, #47H
	acall posicionaCursor
	acall displayRps
	MOV A, #'R'
	ACALL sendCharacter	
	MOV A, #'P'
	ACALL sendCharacter	 
	MOV A, #'S'
	acall sendCharacter
	ACALL retornaCursor
	JMP $

aguardaInput:
    MOV R0, #0        
    CALL scanKeys     
    JB F0, finish    

    JMP aguardaInput        

finish:
	CLR F0
    ret         

scanKeys:
    ; scan row0
    SETB P0.3         
    CLR P0.0          
    CALL colScan      
    JB F0, return     

    ; scan row1
    SETB P0.0         
    CLR P0.1          
    CALL colScan      
    JB F0, return     

    ; scan row2
    SETB P0.1         
    CLR P0.2          
    CALL colScan      
    JB F0, return     

    ; scan row3
    SETB P0.2         
    CLR P0.3          
    CALL colScan      
    JB F0, return     

    RET                

return:
    RET               

colScan:
    JNB P0.4, gotKey  
    INC R0            
    JNB P0.5, gotKey  
    INC R0            
    JNB P0.6, gotKey  
    INC R0            
    RET               

gotKey:
    SETB F0           
    RET                

displayTemperatura:
	mov a, r3
	acall sendCharacter
	mov a, #30h
	acall sendCharacter
	;mov a, temp
	;mov b, #10
	;div ab
	;add a, #30h
	;acall sendCharacter
	;mov a, b
	;add a, #30h
	;ACALL sendCharacter
	ret 

displayRps:
	mov a, r5
	acall sendCharacter
	mov a, r6
	acall sendCharacter
	ret
	

; LE O INPUT DO KEYPAD EM *R0*
traduzTeclaPressionada:
    MOV DPTR, #arrayTeclas  
    MOV A, R0                
    MOVC A, @A + DPTR        
    MOV R3, A 

	subb a, #30h
	mov r4, a

	acall rotacoesPorSegundo
	acall hexaParaAscii
             
    RET

rotacoesPorSegundo:
	mov b, #05H
	mul AB

	add a, #05h
	mov r4, a
	ret

hexaParaAscii:

    MOV A, R4          ; Mova o valor de R4 para o acumulador A
    MOV B, #10         ; Coloque 10 em B para divisão
    DIV AB             ; Dividir A por B; A = quociente, B = resto
                        ; A agora contém o dígito mais significativo (5)
    ADD A, #30h        ; Converte 5 para ASCII ('5' = 35h)
    MOV R5, A          ; Armazena o primeiro dígito ASCII em R5

    ; Para obter o segundo dígito (0)
	MOV A, B
   	ADD A, #30H
	MOV R6, A        ; Armazena o segundo dígito ASCII em R6
    ret

lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereï¿½o da linha e coluna.

posicionaCursor:
	CLR RS	         ; clear RS - indicates that instruction is being sent to module
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	RET


;Retorna o cursor para primeira posiï¿½ï¿½o sem limpar o display
retornaCursor:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	      ; clear RS - indicates that instruction is being sent to module
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET

delay:
	MOV R1, #50
	DJNZ R1, $
	RET
