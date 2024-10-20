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
	mov p1, #01111111b
	JMP motor

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

	CLR RS		
	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CALL delay			
					

	SETB EN		
	CLR EN		
					

	SETB P1.7		

	SETB EN		
	CLR EN		 
				
	CALL delay		


	CLR P1.7		
	CLR P1.6		
	CLR P1.5	
	CLR P1.4		

	SETB EN		
	CLR EN		

	SETB P1.6		
	SETB P1.5		

	SETB EN		
	CLR EN		

	CALL delay		



	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	SETB P1.7		
	SETB P1.6		
	SETB P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay		
	RET


sendCharacter:
	SETB RS  		
	MOV C, ACC.7		
	MOV P1.7, C			
	MOV C, ACC.6		
	MOV P1.6, C			
	MOV C, ACC.5		
	MOV P1.5, C			
	MOV C, ACC.4		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	MOV C, ACC.3		
	MOV P1.7, C			
	MOV C, ACC.2		
	MOV P1.6, C			
	MOV C, ACC.1		
	MOV P1.5, C			
	MOV C, ACC.0		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	CALL delay			
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereï¿½o da linha e coluna.

posicionaCursor:
	CLR RS	         
	SETB P1.7		    
	MOV C, ACC.6		
	MOV P1.6, C			
	MOV C, ACC.5		
	MOV P1.5, C			
	MOV C, ACC.4		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	MOV C, ACC.3		
	MOV P1.7, C			
	MOV C, ACC.2		
	MOV P1.6, C			
	MOV C, ACC.1		
	MOV P1.5, C			
	MOV C, ACC.0		
	MOV P1.4, C			

	SETB EN			
	CLR EN			

	CALL delay			
	RET


;Retorna o cursor para primeira posiï¿½ï¿½o sem limpar o display
retornaCursor:
	CLR RS	      
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CLR P1.7		
	CLR P1.6		
	SETB P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay		
	RET


;Limpa o display
clearDisplay:
	CLR RS	      
	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	CLR P1.4		

	SETB EN		
	CLR EN		

	CLR P1.7		
	CLR P1.6		
	CLR P1.5		
	SETB P1.4		

	SETB EN		
	CLR EN		

	CALL delay		
	RET

delay:
	MOV R1, #50
	DJNZ R1, $
	RET

; ----------------

motor:
MOV TMOD, #50H   
SETB TR1   

 
 MOV DPL, #LOW(LEDcodes)   
     
 
 MOV DPH, #HIGH(LEDcodes) 
 
 CLR P3.4   
 CLR P3.3   

again: 
 CALL setDirection  
 MOV A, TL1   
 CJNE A, #10, skip  
 CALL clearTimer   
skip: 
 MOVC A, @A+DPTR   

 
 MOV C, F0   
 MOV ACC.7, C    

 
 MOV P1, A   
 
 JMP again   
 
setDirection: 
 PUSH ACC   
 PUSH 20H   
 CLR A    
 MOV 20H, #0   
 MOV C, P2.0    
 MOV ACC.0, C    
 MOV C, F0   
 MOV 0, C   
 
 CJNE A, 20H, changeDir 
 
 JMP finish2   
changeDir: 
 CLR P3.0   
 CLR P3.1  
CALL clearTimer  
MOV C, P2.0   
MOV F0, C   
MOV P3.0, C   
CPL C    
MOV P3.1, C   
finish2: 
POP 20H    
POP ACC    
RET    
clearTimer: 
CLR A    
CLR TR1    
MOV TL1, #0   
SETB TR1   
RET    
LEDcodes: 

DB 11000000B, 11111001B, 10100100B, 10110000B, 10011001B, 10010010B, 10000010B, 11111000B, 10000000B, 10010000B
