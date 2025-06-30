#include <iostream>
#include <list>
#include <cassert>
#include <vector>

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

    // Calcula valor da solução ótima.
    for (int i=1; i<=n; i++){
        int itemID = i-1; // Indíce base 0.
       
        for (int j=1; j<=capacity; j++){
            int passItemVal = dpTable[i-1][j];

            // Se peso do item atual cabe na "sub-capacidade" j.
            if(weights[itemID] <= j){
                int possiblePickPos = j-weights[itemID]; 
                int pickItemVal = dpTable[i-1][possiblePickPos] + values[itemID];

                // Se adicionar item não é útil mantém valor.
                if(passItemVal >= pickItemVal)
                    dpTable[i][j] = passItemVal;
                else
                    dpTable[i][j] = pickItemVal;
            }
            else
                dpTable[i][j] = passItemVal;
        }
    }  
    //showSelectedItems(n, capacity, weights, dpTable);
    return dpTable[n][capacity];
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