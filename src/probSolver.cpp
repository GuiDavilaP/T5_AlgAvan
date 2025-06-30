#include <iostream>
#include <list>
#include <cassert>
#include <vector>
#include <cmath>
#include <algorithm> // Para std::shuffle e std::max
#include <random>    // Para std::random_device e std::mt19937

// Obtém itens selecionados (função auxiliar, não usada na main)
void showSelectedItems(int n, int capacity, int* weights, std::vector<std::vector<int>> dpTable){
    std::list<int> solutionItems;
    int currentJ = capacity; // Começa na capacidade final.

    // Regressivamente descobre itens selecionados em solução ótima.
    for (int i=n; i>0; i--){
        int itemID = i-1;
        // Se tabela foi alterada na linha i, então o item correspondente (i-1) foi usado.
        if(dpTable[i][currentJ] != dpTable[i-1][currentJ]){
            solutionItems.push_back(itemID);
            currentJ -= weights[itemID];
            if(currentJ == 0){
                break;
            }
        }
    }
    std::cout<<"Itens selecionados: ";
    for (int item : solutionItems){
        std::cout << item+1 << " <- ";
    }
    std::cout<<std::endl;
}

// Solver para problema da mochila binário usando programação dinâmica com otimização probabilística.
// Baseado no Algoritmo 1 de um artigo científico.
int knapsack(int n, int capacity, int values[], int weights[]){
    // Implementação da permutação aleatória (Linha 1 do Algoritmo 1)
    // Cria pares de valor-peso para facilitar a permutação
    std::vector<std::pair<int, int>> items(n);
    for (int k = 0; k < n; ++k) {
        items[k] = {values[k], weights[k]};
    }
    // Usa um gerador de números aleatórios para embaralhar os itens
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(items.begin(), items.end(), g); // Permuta aleatoriamente os itens

    // Atualiza os arrays originais com a ordem permutada
    for (int k = 0; k < n; ++k) {
        values[k] = items[k].first;
        weights[k] = items[k].second;
    }

    // Inicializa a tabela DP (Linha 2 do Algoritmo 1)
    // f[][j] = 0 para j >= 0. Valores negativos de j são tratados implicitamente.
    std::vector<std::vector<int>> dpTable(n+1, std::vector<int>(capacity+1, 0));
    int Wmax = 0;

    // Encontra o maior peso (Wmax) entre todos os itens
    for (int i=0; i<n; i++){
        if (weights[i] > Wmax)
            Wmax = weights[i];
    }

    // Loop principal sobre os itens (Linha 3 do Algoritmo 1)
    for (int i=1; i<=n; i++){
        int itemID = i-1; // Índice base 0 do item atual

        // Calcula μi e Δi (Linha 4 do Algoritmo 1)
        double Ui = (double)capacity * i / n; // Proporção da capacidade baseada no progresso
        // Δi = Õ(√i * wmax). A divisão por 'n' é uma adaptação para a escala da capacidade.
        int deltaI = std::round(std::sqrt(i) * Wmax);

        // Define o intervalo de capacidades [jStart, jEnd] a serem processadas (Linha 5 do Algoritmo 1)
        // Garante que jStart e jEnd estejam dentro dos limites válidos [0, capacity]
        int jStart = std::max(0, (int)(Ui - deltaI));
        int jEnd = std::min(capacity, (int)(Ui + deltaI));

        // Primeiro, copia valores da linha anterior para todas as posições.
        // Isso lida com o caso de não incluir o item atual.
        for (int j = 0; j <= capacity; j++) {
            dpTable[i][j] = dpTable[i-1][j];
        }

        // Processa apenas o intervalo probabilístico de capacidades
        for (int j = jStart; j <= jEnd; j++){
            // Valor se o item atual NÃO for incluído (já copiado de dpTable[i-1][j])
            int passItemVal = dpTable[i-1][j];

            // Se o peso do item atual cabe na "sub-capacidade" j.
            if(weights[itemID] <= j){
                int possiblePickPos = j - weights[itemID]; 
                // Valor se o item atual FOR incluído
                int pickItemVal = dpTable[i-1][possiblePickPos] + values[itemID];

                // Atualiza dpTable[i][j] com o valor máximo (Linha 6 do Algoritmo 1)
                if(pickItemVal > passItemVal)
                    dpTable[i][j] = pickItemVal;
            }
            // Se o item não cabe, dpTable[i][j] mantém o valor de dpTable[i-1][j] (já copiado)
        }
    }  
    
    // Retorna o valor máximo encontrado na última linha da tabela DP (Linha 7 do Algoritmo 1)
    int max_val_in_last_row = 0;
    for (int j = 0; j <= capacity; ++j) {
        if (dpTable[n][j] > max_val_in_last_row) {
            max_val_in_last_row = dpTable[n][j];
        }
    }
    return max_val_in_last_row;
}

int main(){
    int n, W;
    
    // Lê primeira linha: n W
    std::cin >> n >> W;
    
    // Aloca arrays dinâmicos
    int* values = new int[n];
    int* weights = new int[n];
    
    // Lê segunda linha: valores p1, ..., pn
    for(int i = 0; i < n; i++){
        std::cin >> values[i];
    }
    
    // Lê terceira linha: pesos w1, ..., wn
    for(int i = 0; i < n; i++){
        std::cin >> weights[i];
    }

    int result = knapsack(n, W, values, weights);
    std::cout << result << std::endl;
    
    // Libera memória
    delete[] values;
    delete[] weights;
    
    return 0;
}
