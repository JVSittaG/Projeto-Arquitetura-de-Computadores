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
    mov A, #47H
	acall posicionaCursor
    acall displayRps
	MOV A, #'R'
	ACALL sendCharacter	
	MOV A, #'P'
	ACALL sendCharacter	 
	MOV A, #'S'
	ACALL sendCharacter
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
	acall motorERpsIniciais
	acall motor
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
	acall asciiParaDecimal
	acall motor
	JMP $

motorERpsIniciais:
	mov r1, #32h ;50 rotacoes por segundo (para usar no motor)
	mov r5, #35h ; digito 5 (para usar no display)
	mov r6, #30h ; digito 0 (para usar no display)
	ret

; loop infinito enquanto o input da matriz do teclado nao e encontrado
; caso seja, bit F0 e setado, limpo e retorna a stack pro fluxo principal
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
	mov a, r3 ; envia o digito da dezena para ser mostrado
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
	; array teclas funciona como uma lookup table,
	; o valor do input da matriz eh previamente registrado em r0
	; percorre ate o index desse input e seleciona o char correspondente
    MOV DPTR, #arrayTeclas  
    MOV A, R0                
    MOVC A, @A + DPTR        
    MOV R3, A 

	clr c
	subb a, #30h
	mov r4, a

	acall rotacoesPorSegundo
	acall hexaParaAscii
             
    RET

; a FAN tem velocidade maxima de 3000RPM
; (50 RPS)
; com base na temperatura maxima sendo 90c e 50 RPS,
; temos que a formula input * 5 + 5 = rps 
; ou seja, o minimo de rotacoes por segundo sendo 5, o maximo 50 baseados no input
rotacoesPorSegundo: 
	mov b, #05H
	mul AB

	add a, #05h
	mov r4, a
	ret

hexaParaAscii:
	;primeiro digito (menos significativo, unidades)
    MOV A, R4          
    MOV B, #10         
    DIV AB             
                        
    ADD A, #30h        
    MOV R5, A          
	
	;segundo digito (mais significativo, dezenas) utilizando o resto
	MOV A, B
   	ADD A, #30H
	MOV R6, A    
    ret

; como estamos lidando com digitos naturais (0 - 9), basta subtrair 30 para obtermos o decimal, sao iguais.
asciiParaDecimal:
    MOV A, R6      
    CLR C           ; limpa o carry para nao atrapalhar a subtracao
    SUBB A, #30H    
    MOV R2, A       ; armazena o valor do digito menos significativo

    MOV A, R5       
    CLR C           ; limpa o carry para nao atrapalhar a subtracao
    SUBB A, #30H    
    MOV B, #0AH     
    MUL AB          ; multiplica o digito mais significativo (dezena) por 10
    
    ADD A, R2    ; soma os valores calculados
    MOV R1, A
	RET
	

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

; sensor do motor e conectado por padrao no pino p3.5 (timer)
; a cada rotacao completa do motor, um pulso e gerado no pino 
; o timer no modo de contagem aumenta em 1 a cada pulso detectado
motor:
	MOV TMOD, #50H    ; inicializa timer de 16 bits
    MOV TL1, #0       ; seta o contador pra 0
    MOV R7, #0        ; limpa o registrador auxiliar para debugar e visualizar as contagens de rotacoes
    SETB TR1          

    SETB P3.0         ; inicia o motor no sentido horario
    CLR P3.1
	acall loop_motor
	ret
	          

loop_motor:
	MOV A, TL1        
    MOV R7, A         ; guarda contador no R7 pra facilitar visualizacao
	
	; fluxo para interromper o fluxo do motor apos atingir o numero desejado de retacoes
	mov 60h, r1  
    CJNE A, 60H, loop_motor ; compara valor decimal do r1 do numero maximo de RPS com o atual numero de rotacoes
    acall PARAR_MOTOR
    ret

; limpa os bits que sao setados na inicializacao do motor
PARAR_MOTOR:
    CLR P3.0
    CLR P3.1
	ret
