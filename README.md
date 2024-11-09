# Relatório Final

Nome: Willian Verenka
RA: 22.124.081-5
Nome: João Vitor Sitta Giopatto
RA: 22.123.054-3


# Introdução

Este relatório apresenta o desenvolvimento e os resultados do projeto realizado para a disciplina CE4411. Este programa faz parte de um projeto de Arquitetura de Computadores e simula uma controladora de fan no ambiente Edsim51, sendo totalmente escrito em Assembly 8051.


# Controlador de Ventilador com Interface LCD

## Descrição
Este projeto implementa uma simulação de um sistema de controle de ventilador baseado em temperatura, utilizando Assembly para o microcontrolador 8051. O programa permite que o usuário digite a temperatura desejada da CPU e, com base em uma equação que leva esse fator em conta, define uma taxa de rotações por segundo para a fan da CPU rodar, controlando assim a temperatura da CPU. Após a definição da RPS da fan, um motor é utilizado para simular como seria a atuação dessa fan com a velocidade calculada. Também é possível acompanhar o contador de quantidade de rotações feitas pelo motor no EDSIM51, tanto no acumulador quanto no R7, enquanto o motor está rodando. A interface com o usuário é feita através de um display LCD, onde o usuário receberá uma mensagem para digitar o valor da temperatura e, após a digitação, o valor da RPS da fan.

## Funcionalidades Principais

- Inicialização segura com a FAN em maxima performance
- Interface com teclado numérico para entrada de temperatura
- Display LCD para visualização de dados
- Controle proporcional da velocidade do ventilador
- Medição de rotações por segundo (RPS)
- Display de temperatura e velocidade de rotação

## Funcionamento

- Ao iniciar o programa, a controladora assume o modo de seguranca e performa em sua capacidade máxima.
![Animação](https://github.com/user-attachments/assets/60ef01d5-6d6d-4e3e-92a0-80a970ddb6ab)

- Após a inicialização, o usuário pode entrar com um input para simular o sensor de temperatura da CPU.

- O programa calculará a velocidade adequada da FAN de forma proporcional à temperatura inserida.

![2](https://github.com/user-attachments/assets/b607be80-ab3f-4b06-8d82-48c04d8c2243)


| Temperatura (°C) | RPS (Rotatações por segundo) | RPM (Rotações por minuto) |
| ------------- |:-------------:| -----:|
| 0°C | 05 RPS | 300 RPM |
| 10°C | 10 RPS | 600 RPM |
| 20°C | 15 RPS | 900 RPM |
| 30°C | 20 RPS | 1200 RPM |
| 40°C | 25 RPS | 1500 RPM |
| 50°C | 30 RPS | 1800 RPM |
| 60°C | 35 RPS | 2100 RPM |
| 70°C | 40 RPS | 2400 RPM |
| 80°C | 45 RPS | 2700 RPM |
| 90°C | 50 RPS | 3000 RPM |

- Quando o sistema é inicializado ou uma temperatura é escolhida, é possível observar o que seria o comportamento da fan no intervalo de um segundo no motor do edsim51.
- O motor completará o número de voltas correspondente ao RPS.

![3](https://github.com/user-attachments/assets/2d216612-3e72-4677-a30e-3c29fac1153a)

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
````


### 3. Controle do Motor

O motor funciona em apenas um sentido e ele é interrompido assim que completa N voltas, sendo N o número de rotações por segundo calculado previamente. Portanto, seria uma simulação que demonstraria o comportamento da FAN em um intervalo de um segundo em dada temperatura. Após completar todas as voltas, o motor é interrompido. OBS: recomenda-se que, ao entrar com a temperatura, reduza a update frequency para um valor entre 1 e 10 para que se possa enxergar as voltas do motor de forma adequada. É possível acompanhar esse contador pelo EDSIM51 tanto no acumulador como no R7 no momento em que o motor está rodando.

```assembly
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
```



 # Conclusão

Inicialmente, nossa ideia e plano para o projeto eram conseguir controlar, com o input do usuário no programa, a temperatura de uma CPU, alterando a quantidade de rotações por segundo de sua fan. Porém, tivemos dificuldades em realmente implementar essa funcionalidade. Portanto, resolvemos trabalhar com uma ideia de simulação de como seria esse processo. Outra dificuldade que encontramos foi a utilização do teclado numérico para obter dois números do usuário (um para a dezena e outro para a unidade) a fim de regular a velocidade da fan. Para contornar essa situação, resolvemos utilizar apenas um input do usuário para o programa, representando a dezena da temperatura da CPU. Uma possível melhoria seria tornar essa simulação mais complexa, considerando mais aspectos do hardware do computador, como, por exemplo, a inicialização do programa com a fan em velocidade máxima para simular o comportamento ao ligar o computador, entre outras possibilidades.





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
