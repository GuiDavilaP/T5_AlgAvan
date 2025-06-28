#include <iostream>
#include <list>
#include <cassert>
#include <vector>
#include <cmath>

// Obtêm itens selecionados
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

// Solver para prolema da mochila binário usando programação dinâmica.
int knapsack(int n, int capacity, int values[], int weights[]){
    std::vector<std::vector<int>> dpTable(n+1, std::vector<int>(capacity+1, 0));
    int Wmax = 0;

    // Acha maior peso (Wmax)
    for (int i=0; i<n; i++){
        if (weights[i] > Wmax)
            Wmax = weights[i];
    }

    // Calcula valor da solução ótima.
    for (int i=1; i<=n; i++){
        int itemID = i-1; // Indíce base 0.
        double Ui = (double)capacity * i / n; // Proporção da capacidade baseada no progresso
        int deltaI = std::round(std::sqrt(i) * Wmax / n); // Reduz delta para evitar overflow

        // Garante que j está dentro dos limites válidos [0, capacity]
        int jStart = std::max(0, (int)(Ui - deltaI));
        int jEnd = std::min(capacity, (int)(Ui + deltaI));

        // Primeiro, copia valores da linha anterior para posições não processadas
        for (int j = 0; j <= capacity; j++) {
            dpTable[i][j] = dpTable[i-1][j];
        }

        // Processa apenas o intervalo probabilístico
        for (int j = jStart; j <= jEnd; j++){
            int passItemVal = dpTable[i-1][j];

            // Se peso do item atual cabe na "sub-capacidade" j.
            if(weights[itemID] <= j){
                int possiblePickPos = j - weights[itemID]; 
                int pickItemVal = dpTable[i-1][possiblePickPos] + values[itemID];

                // Se adicionar item é melhor, atualiza valor.
                if(pickItemVal > passItemVal)
                    dpTable[i][j] = pickItemVal;
            }
        }
    }  
    //showSelectedItems(n, capacity, weights, dpTable);
    return dpTable[n][capacity];
}

int main(){
    int values[] = {3,3,4};
    int weights[] = {2,3,6};
    int W = 5;
    int n = sizeof(values) / sizeof(int);

    int result = knapsack(n, W, values, weights);
    std::cout << result << std::endl;
}