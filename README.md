# Projeto controladora de FAN

- Este programa faz parte de um projeto de Arquitetura de Computadores e simula uma controladora de fan no ambiente Edsim51 sendo totalmente escrito em Assembly 8051.

## Componentes do ambiente utilizados:
- Keypad
  - Escolhe a temperatura da CPU
- Display LCD
  - Mostra a temperatura
- Motor
  - Simula a rotação da FAN
- Led
  - Indicativo de segurança da temperatura da CPU

## Conceito

A ideia do controlador é ler uma temperatura qualquer, em celsius, e manipular o motor de acordo com seu valor. Durante esse processo, o display e o LED mostram alguns indicativos sobre o estado atual da CPU, como a temperatura atual e um indicativo de segurança, que com base nos processadores da AMD, o hardware opera de forma segura abaixo dos 95°.

## Passo a passo
O programa funciona na ordem seguinte:

1. Inicialização da LCD
2. Input da temperatura pelo keypad
3. Armazenamento final da temperatura em hexadecimal
4. Conversão do valor para a tabela ASCII
5. Amostragem dos digitos da temperatura no display LCD
6. Atualização da cor do LED se a temperatura é menor ou maior que 95°
7. Tradução da temperatura para número de voltas que o motor executa, que funciona de forma proporcional
8. Programa armazena o numero de voltas a partir de um contador, que simula as rotações em dado intervalo de tempo, contribuindo para o funcionamento da controladora
