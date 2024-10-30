# Projeto controladora de FAN

- Este programa faz parte de um projeto de Arquitetura de Computadores e simula uma controladora de fan no ambiente Edsim51 sendo totalmente escrito em Assembly 8051.

# Controlador de Ventilador com Interface LCD

## Descrição
Este projeto implementa um sistema de controle de ventilador baseado em temperatura utilizando Assembly para o microcontrolador 8051. O sistema permite que o usuário insira uma temperatura através de um teclado numérico e, com base nesse valor, controla automaticamente as rotações de uma FAN. A interface com o usuário é feita através de um display LCD.

## Funcionalidades Principais
- Interface com teclado numérico para entrada de temperatura
- Display LCD para visualização de dados
- Controle proporcional da velocidade do ventilador
- Medição de rotações por segundo (RPS)
- Display de temperatura e velocidade de rotação

## Detalhes Técnicos Importantes

### 1. Cálculo de Rotações

Este trecho implementa a lógica de conversão entre temperatura e velocidade do ventilador. A velocidade varia de 5 RPS (mínimo) para 0 graus, até 50 RPS para 90 graus.
Os valores de RPS foram baseados em valores comum de RPM de FANS moderna. Multiplicando os valores por 60 (segundos), obtemos um intervalo de 300 e 3000 RPM.

Apesar da medida mais comum para esta métrica ser rotações por minuto, o programa utiliza rotações por segundo por sua simplicidade e pelas limitações de controle de motor no EDSIM51. Esse ponto é abordado com mais detalhe no tópico 3, sobre o controle de motor.

```assembly
; Cálculo de RPS baseado na temperatura
; Formula: input * 5 + 5 = rps 
; Velocidade máxima: 3000 RPM (50 RPS)
; Velocidade mínima: 5 RPS
rotacoesPorSegundo: 
    mov b, #05H
    mul AB
    add a, #05h
    mov r4, a
    ret
```


### 2. Controle de rotações

Após ser calculado o número de rotações, nós pegamos os valores dos digitos ascii e transformamos em decimal. É uma operação mais conveniente que uma conversão de hexa para decimal, já que como estamos tratando de digitos naturais (0-9 para dezena e 0-9 para unidade), basta subtrair 30 em hexadecimal e temos o numero de rotações armazenados para que possamos utilizar no controle do motor.

```assembly
asciiParaDecimal:
    MOV A, R6      
    CLR C           
    SUBB A, #30H    
    MOV R2, A       

    MOV A, R5       
    CLR C           
    SUBB A, #30H    
    MOV B, #0AH     
    MUL AB          
    
    ADD A, R2    
    MOV R1, A
	RET
````


### 3. Controle do Motor

O motor funciona em apenas um sentido e ele é interrompido assim que completa N voltas, sendo N o número de rotações por segundo calculado previamente. Portanto, seria uma simulação que demonstraria o comportamento da FAN em um intervalo de um segundo em dada temperatura. Após completar todas as voltas, o motor é interrompido. OBS: recomenda-se que, ao entrar com a temperatura, reduza a update frequency para um valor entre 1 e 10 para que se possa enxergar as voltas do motor de forma adequada. É possível acompanhar esse contador pelo EDSIM51 tanto no acumulador como no R7 no momento em que o motor está rodando.

```assembly
motor:
	MOV TMOD, #50H    
    MOV TL1, #0       
    MOV R7, #0        
    SETB TR1          

    SETB P3.0         
    CLR P3.1          

loop_motor:
	MOV A, TL1        
    MOV R7, A         ; guarda contador no R7 pra facilitar visualizacao
	
	mov 60h, r1  
    CJNE A, 60H, loop_motor ; compara valor do r1 do numero maximo de RPS com o atual numero de rotacoes
    jmp PARAR_MOTOR

PARAR_MOTOR:
    CLR P3.0
    CLR P3.1
	JMP $
```
 



## Características Técnicas
- Microcontrolador: 8051
- Display: LCD 16x2
- Entrada: Teclado Matricial 4x3
- Saída: Controle para motor DC
- Range de Temperatura: 0-9°C
- Range de Velocidade: 5-50 RPS (300-3000 RPM)

## Registradores Importantes
- R0: Armazena input do teclado
- R1: Valor decimal final para comparação
- R3: Caractere ASCII da temperatura
- R4: Valor numérico da temperatura
- R5/R6: Dígitos ASCII para display de RPS
- R7: Contador de rotações

## Hardware Necessário
- Microcontrolador 8051
- LCD 16x2
- Teclado Matricial 4x3
- Motor DC
- Alimentação adequada
