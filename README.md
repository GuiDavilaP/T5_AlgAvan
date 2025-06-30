# **Análise Comparativa de Solvers para o Problema da Mochila Binária**

Este projeto tem como objetivo comparar o desempenho e a precisão de duas abordagens para resolver o Problema da Mochila Binária (Knapsack Problem): um solver de Programação Dinâmica "simples" e um solver de Programação Dinâmica "probabilístico" (que otimiza o espaço da tabela DP).

## **Estrutura do Projeto**

A estrutura do projeto é organizada da seguinte forma:

T5\_AlgAvan  
├─ bash/  
│  └─ test.sh             \# Script principal para execução dos testes e geração de relatórios.  
├─ Makefile                \# Arquivo para automatizar a compilação e execução dos testes.  
├─ inc/                    \# (Vazio, pode ser usado para arquivos de cabeçalho futuros)  
├─ results/                \# Pasta para armazenar os resultados dos testes (arquivos .csv e relatório.txt).  
└─ src/  
   ├─ generator.cpp       \# Código-fonte para gerar instâncias de teste do problema da mochila.  
   ├─ simpleSolver.cpp    \# Implementação do solver de Programação Dinâmica "simples".  
   └─ probSolver.cpp      \# Implementação do solver de Programação Dinâmica "probabilístico".

## **Tipos de Teste e Geração de Instâncias**

O generator.cpp é responsável por criar diferentes conjuntos de instâncias do Problema da Mochila para avaliar o desempenho dos solvers sob diversas condições. As instâncias são salvas na pasta data/ dentro de subpastas específicas para cada tipo de teste.

Para garantir uma análise estatisticamente robusta, especialmente para o algoritmo probabilístico, cada "ponto de teste" (ex: n=1000 para o teste de itens) agora gera **múltiplas instâncias aleatórias**. Além disso, cada uma dessas instâncias é executada **múltiplas vezes** pelos solvers para calcular médias de desempenho e precisão. Atualmente, configuramos para gerar **5 instâncias aleatórias por ponto de teste**, e cada instância é executada **5 vezes**.

### **1\. Variação do Número de Itens (items)**

* **O que é feito**: Neste teste, o número de itens (n) na mochila varia de instâncias moderadas (ex: 1000 itens) a instâncias muito maiores (ex: 15000 itens). Para cada valor de n, 5 instâncias aleatórias distintas são geradas.  
* **Capacidade**: A capacidade da mochila é ajustada proporcionalmente ao número de itens, mantendo um capacityFactor (fator de capacidade) fixo em 40%.  
* **Razão**: Esta faixa de n mais elevada visa desafiar o simpleSolver (cuja complexidade é O(nW)), potencialmente levando-o a atingir limites de tempo. Para o probSolver, espera-se que ele mantenha um bom desempenho e comece a mostrar seu comportamento de aproximação (taxa de acerto menor que 100%) em instâncias mais difíceis, enquanto ainda oferece um speedup significativo.

### **2\. Variação do Peso Máximo dos Itens (weights)**

* **O que é feito**: Neste teste, o número de itens (n) é mantido fixo em 1000 itens, enquanto o peso máximo possível para um único item (maxWeight) varia de 200 a 10000\. Para cada valor de maxWeight, 5 instâncias aleatórias distintas são geradas.  
* **Capacidade**: A capacidade é calculada com base no n fixo e no maxWeight que varia, usando o mesmo capacityFactor fixo. O aumento do maxWeight resulta em capacidades totais maiores.  
* **Razão**: Aumentar o maxWeight impacta diretamente a dimensão da capacidade (W) na complexidade O(nW) do simpleSolver, tornando-o mais lento. Para o probSolver, que usa Wmax no cálculo de Δi, esta variação é crucial para observar como a largura da sua faixa de busca se adapta e como isso afeta a precisão e o desempenho.

### **3\. Variação da Capacidade da Mochila (capacity)**

* **O que é feito**: Neste teste, o número de itens (n) é mantido fixo em 1000 e o peso máximo (maxWeight) em 200, enquanto o capacityFactor (fator de capacidade) varia de 10% a 90%. Para cada capacityFactor, 5 instâncias aleatórias distintas são geradas.  
* **Cálculo da Capacidade**: A capacidade é um valor calculado com base no peso total estimado dos itens. Com n=1000 e maxWeight=200, o estimatedTotalWeight é significativamente maior, resultando em capacidades absolutas maiores para o problema.  
* **Razão**: Manter n e maxWeight mais altos garante que a base da capacidade seja grande, e a variação do fator permite testar os solvers em diferentes cenários de "aperto" da mochila em uma escala maior. Isso pode revelar como a precisão do probSolver se comporta quando a capacidade é muito restritiva ou muito permissiva em relação ao peso total dos itens.

## **Objetivo da Comparação**

O objetivo principal desses testes é comparar o simpleSolver (implementação padrão de programação dinâmica) com o probSolver (implementação de programação dinâmica com otimização probabilística de espaço). A comparação será feita em termos de:

* **Precisão Média**: Verificar a diferença percentual média entre a solução do probSolver e a solução ótima do simpleSolver. Para algoritmos probabilísticos, o objetivo é uma aproximação de alta qualidade, não necessariamente uma exatidão de 100% em todas as execuções, especialmente em instâncias muito grandes.  
* **Tempo de Execução Médio**: Avaliar a eficiência média de cada solver sob as diversas variações de instâncias e repetições. Espera-se que o probSolver seja significativamente mais rápido, especialmente em instâncias onde o simpleSolver se torna inviável.  
* **Speedup Médio**: Calcular a razão de tempo médio entre o simpleSolver e o probSolver para quantificar o ganho de desempenho do solver probabilístico.

## **Como Executar os Testes**

Para compilar os solvers, gerar as instâncias de teste e executar a análise completa, siga os passos abaixo no terminal, na pasta raiz do projeto (T5\_AlgAvan):

1. **Executar a Análise Completa (Recomendado)**:  
   make test-analysis

   Este comando irá:  
   * Compilar simpleSolver, probSolver e generator.  
   * Gerar todas as instâncias de teste nas subpastas data/items, data/weights, data/capacity (com múltiplas instâncias aleatórias para cada ponto de teste e as novas faixas de tamanho).  
   * Executar o script bash/test.sh, que por sua vez rodará ambos os solvers em cada instância múltiplas vezes (5 repetições), calculará as médias e gerará arquivos .csv na pasta results/ para cada tipo de teste.  
   * Exibir um relatório resumido no terminal.  
2. **Gerar Apenas as Instâncias de Teste**:  
   make generate-tests

   Isso compilará o generator e criará as instâncias na pasta data/ (com a nova estrutura de múltiplas instâncias por ponto de teste e as novas faixas).  
3. **Visualizar Resultados Resumidos**:  
   make show-results

   Exibe um resumo dos resultados dos arquivos .csv gerados na pasta results/.  
4. **Gerar Relatório em Texto**:  
   make report

   Cria um arquivo results/report.txt com um relatório detalhado da análise.  
5. **Limpeza**:  
   make clean         \# Remove executáveis, pasta data/ e pasta results/  
   make clean-bin     \# Remove apenas os executáveis  
   make clean-results \# Remove apenas a pasta results/  
