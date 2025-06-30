# **Análise Comparativa de Solvers para o Problema da Mochila Binária**

Este projeto tem como objetivo principal comparar o desempenho e a precisão de duas abordagens para resolver o Problema da Mochila 0-1 (Knapsack Problem): um solver de Programação Dinâmica (PD) clássica e um solver de PD probabilística. O solver clássico (simpleSolver) garante a solução ótima, enquanto o solver probabilístico (probSolver) busca otimizar o tempo de execução limitando o espaço de estados da tabela de PD, com a expectativa de encontrar uma solução ótima ou muito próxima com alta probabilidade. O trabalho visa analisar o *trade-off* entre precisão e eficiência oferecido pela abordagem probabilística.

## **Estrutura do Projeto**

A estrutura do projeto é organizada da seguinte forma:

T5\_AlgAvan  
├─ Makefile                \# Arquivo para automatizar a compilação e execução dos testes.  
├─ README.md               \# Este arquivo.  
├─ bash/  
│  └─ test.sh             \# Script principal para execução dos testes e geração de relatórios.  
├─ data/                   \# Pasta para armazenar as instâncias de teste geradas.  
│  ├─ capacity/            \# Instâncias para o teste de variação de capacidade.  
│  ├─ items/               \# Instâncias para o teste de variação do número de itens.  
│  └─ weights/             \# Instâncias para o teste de variação do peso máximo.  
├─ obj/                    \# Pasta para armazenar arquivos objeto.  
├─ plots/                  \# Pasta para armazenar os gráficos e tabelas de resultados gerados.  
├─ requirements.txt        \# Lista de dependências Python.  
├─ results/                \# Pasta para armazenar os resultados dos testes (arquivos .csv e relatório.txt).  
│  ├─ capacity\_results.csv  
│  ├─ items\_results.csv  
│  └─ weights\_results.csv  
├─ src/  
│  ├─ generator.cpp       \# Código-fonte para gerar instâncias de teste do problema da mochila.  
│  ├─ simpleSolver.cpp    \# Implementação do solver de Programação Dinâmica "simples".  
│  ├─ probSolver.cpp      \# Implementação do solver de Programação Dinâmica "probabilístico".  
│  └─ plotResults.py      \# Script Python para gerar gráficos e tabelas a partir dos resultados.  
└─ venv/                   \# Ambiente virtual Python (recomendado).

## **Tipos de Teste e Geração de Instâncias**

O generator.cpp é responsável por criar diferentes conjuntos de instâncias do Problema da Mochila para avaliar o desempenho dos solvers sob diversas condições. As instâncias são salvas na pasta data/ dentro de subpastas específicas para cada tipo de teste.

Para garantir uma análise estatisticamente robusta, especialmente para o algoritmo probabilístico, cada "ponto de teste" (uma combinação específica de parâmetros) gera **5 instâncias aleatórias distintas**. Além disso, cada uma dessas instâncias é executada **5 vezes** por ambos os solvers para calcular médias de desempenho e precisão.

### **1\. Variação do Número de Itens (items)**

* **Parâmetros Variáveis:** O número de itens (n) varia em uma faixa de 1000 a 5000 itens, com incrementos definidos em 1000,2000,3000,4000,5000.  
* **Parâmetros Fixos:** O peso máximo de um item é fixado em 100, o valor máximo em 150, e o fator de capacidade em 40\.  
* **Objetivo da Variação:** Esta faixa de n mais elevada visa desafiar o simpleSolver, cuja complexidade de tempo é diretamente proporcional a ntimesW. Espera-se que o simpleSolver comece a atingir limites de tempo para os maiores valores de n. Para o probSolver, esta variação permite observar sua escalabilidade e se sua natureza de aproximação se manifesta (taxa de otimalidade menor que 100%) em instâncias com um número crescente de itens, enquanto ainda oferece um ganho de velocidade.

### **2\. Variação do Peso Máximo dos Itens (weights)**

* **Parâmetros Variáveis:** O peso máximo de um item (w\_max) varia em uma faixa de 200 a 4000, com incrementos definidos em 200,500,1000,2000,3000,4000.  
* **Parâmetros Fixos:** O número de itens (n) é fixado em 1000, o valor máximo em 150, e o fator de capacidade em 40\.  
* **Objetivo da Variação:** O aumento de w\_max impacta diretamente a capacidade total da mochila (W), que é um fator na complexidade O(nW) do simpleSolver. Isso deve tornar o simpleSolver mais lento. Para o probSolver, a variação de w\_max é crucial, pois Delta\_i depende diretamente de w\_max. Esta variação permite analisar como a largura da faixa de busca de probSolver se ajusta e como isso afeta sua precisão e desempenho.

### **3\. Variação da Capacidade da Mochila (capacity)**

* **Parâmetros Variáveis:** O fator de capacidade (capacityFactor) varia de 10 a 90, com incrementos definidos em 10,20,...,90.  
* **Parâmetros Fixos:** O número de itens (n) é fixado em 1000, o peso máximo em 200, e o valor máximo em 150\.  
* Cálculo da Capacidade: A capacidade da mochila (W) é calculada com base no número de itens (n), no peso máximo de um item (w\_max) e no capacityFactor. A fórmula utilizada no generator.cpp é:  
  W=(n×2wmax​+1​×100capacityFactor​)

  Esta abordagem garante que a capacidade seja uma proporção do peso total estimado de todos os itens, tornando o problema mais representativo.  
* **Objetivo da Variação:** Testar os solvers em diferentes cenários de "aperto" da mochila. Capacidades muito pequenas ou muito grandes podem simplificar o problema, enquanto capacidades intermediárias (tipicamente 40 do peso total estimado) tendem a ser mais desafiadoras. Esta variação em uma escala maior permite observar como a precisão e o desempenho do probSolver se comportam em diferentes regimes de capacidade.

## **Instalação de Dependências (Python)**

Para gerar os gráficos e tabelas de resultados, é necessário instalar as bibliotecas Python listadas em requirements.txt. Recomenda-se o uso de um ambiente virtual para gerenciar as dependências.

1. **Crie e ative um ambiente virtual (opcional, mas recomendado):**  
   python \-m venv venv  
   source venv/bin/activate  \# No Linux/macOS  
   .\\venv\\Scripts\\activate   \# No Windows (PowerShell)

2. **Instale as dependências:**  
   pip install \-r requirements.txt

## **Opções Principais do Makefile**

O Makefile automatiza as tarefas de compilação, geração de testes e execução da análise.

* **make all**: Compila todos os executáveis (simpleSolver, probSolver, generator).  
* **make generate-tests**: Compila o generator e gera todas as instâncias de teste nas subpastas data/items, data/weights, data/capacity.  
* **make test-analysis**: Compila todos os solvers e o gerador (se necessário), gera todas as instâncias de teste e executa a análise completa, salvando os resultados em results/.  
* **make test-items**: Executa a análise apenas para o conjunto de testes de variação de itens.  
* **make test-weights**: Executa a análise apenas para o conjunto de testes de variação de peso máximo.  
* **make test-capacity**: Executa a análise apenas para o conjunto de testes de variação de capacidade.  
* **make make-plots**: Executa o script Python src/plotResults.py para gerar os gráficos e tabelas de resultados na pasta plots/. Certifique-se de ter executado os testes (make test-analysis ou específicos) antes de usar este comando.  
* **make show-results**: Exibe um resumo dos resultados dos arquivos .csv no terminal.  
* **make report**: Gera um relatório detalhado em formato de texto (results/report.txt).  
* **make clean**: Remove todos os executáveis, a pasta data/ e a pasta results/.  
* **make clean-bin**: Remove apenas os executáveis.  
* **make clean-results**: Remove apenas a pasta results/.