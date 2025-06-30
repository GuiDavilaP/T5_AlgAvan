#include <iostream>
#include <fstream>
#include <random>
#include <string>
#include <filesystem> // For std::filesystem::create_directory
#include <vector>

// Modified to accept a subfolder and a run_index for unique filenames
void generateInstance(int n, int maxWeight, int maxValue, int capacityFactor, const std::string& subfolder, const std::string& filename_prefix, int run_index) {
    // Ensure the subfolder exists
    std::filesystem::create_directory("data/" + subfolder);

    // Creates random number generator with a seed based on time and run_index
    // This ensures different random item sets for each run_index
    std::mt19937 gen(std::random_device{}() + run_index); 
    std::uniform_int_distribution<> weightDist(1, maxWeight);
    std::uniform_int_distribution<> valueDist(1, maxValue);

    // Calculates knapsack capacity (factor * average sum of weights)
    long long estimatedTotalWeight = (long long)n * (maxWeight + 1) / 2; // Use long long for larger values
    int capacity = (estimatedTotalWeight * capacityFactor) / 100;

    // Generates weights and values
    std::vector<int> weights(n);
    std::vector<int> values(n);

    for(int i = 0; i < n; i++) {
        weights[i] = weightDist(gen);
        values[i] = valueDist(gen);
    }

    // Writes file
    std::string full_path = "data/" + subfolder + "/" + filename_prefix + "_run" + std::to_string(run_index) + ".txt";
    std::ofstream file(full_path);
    if(!file.is_open()) {
        std::cerr << "Erro ao criar arquivo: " << full_path << std::endl;
        return;
    }

    // First line: n W
    file << n << " " << capacity << std::endl;

    // Second line: values
    for(int i = 0; i < n; i++) {
        file << values[i];
        if(i < n-1) file << " ";
    }
    file << std::endl;

    // Third line: weights
    for(int i = 0; i < n; i++) {
        file << weights[i];
        if(i < n-1) file << " ";
    }
    file << std::endl;

    file.close();

    std::cout << "Instância gerada: " << full_path << std::endl;
    std::cout << "  - Itens: " << n << std::endl;
    std::cout << "  - Capacidade: " << capacity << std::endl;
    std::cout << "  - Peso máximo: " << maxWeight << std::endl;
    std::cout << "  - Valor máximo: " << maxValue << std::endl;
    std::cout << std::endl;
}

// Modified to generate multiple instances per parameter set and use larger ranges
void generateTestSet(const std::string& testType, int num_instances_per_param) {
    std::cout << "=== Gerando conjunto de testes: " << testType << " ===" << std::endl;

    if(testType == "items") {
        // Test 1: Varying number of items (n) - Larger range
        std::vector<int> nValues = {1000, 2000, 3000, 4000, 5000};
        int fixedMaxWeight = 100;
        int fixedMaxValue = 150;
        int fixedCapacityFactor = 40;

        for(int i = 0; i < nValues.size(); i++) {
            for (int run = 1; run <= num_instances_per_param; ++run) {
                std::string filename_prefix = "test_items_" + std::to_string(nValues[i]); // Use actual N value in prefix
                generateInstance(nValues[i], fixedMaxWeight, fixedMaxValue, fixedCapacityFactor, "items", filename_prefix, run);
            }
        }
    }
    else if(testType == "weights") {
        // Test 2: Varying maximum weight (keeping n high) - Larger range
        int fixedN = 1000; // Increased fixed N
        std::vector<int> maxWeights = {200, 500, 1000, 2000, 3000, 4000};
        int fixedMaxValue = 150;
        int fixedCapacityFactor = 40;
        
        for(int i = 0; i < maxWeights.size(); i++) {
            for (int run = 1; run <= num_instances_per_param; ++run) {
                std::string filename_prefix = "test_weights_" + std::to_string(maxWeights[i]); // Use actual MaxWeight in prefix
                generateInstance(fixedN, maxWeights[i], fixedMaxValue, fixedCapacityFactor, "weights", filename_prefix, run);
            }
        }
    }
    else if(testType == "capacity") {
        // Test 3: Varying capacity (keeping n high) - Larger range
        int fixedN = 1000; // Increased fixed N
        int fixedMaxWeight = 200; // Increased fixed MaxWeight to make base capacity larger
        int fixedMaxValue = 150;
        std::vector<int> capacityFactors = {10, 20, 30, 40, 50, 60, 70, 80, 90};

        for(int i = 0; i < capacityFactors.size(); i++) {
            for (int run = 1; run <= num_instances_per_param; ++run) {
                std::string filename_prefix = "test_capacity_" + std::to_string(capacityFactors[i]); // Use actual CapacityFactor in prefix
                generateInstance(fixedN, fixedMaxWeight, fixedMaxValue, capacityFactors[i], "capacity", filename_prefix, run);
            }
        }
    }
    else {
        std::cout << "Tipo de teste inválido. Use: items, weights, capacity, ou all" << std::endl;
        return;
    }
    
    std::cout << "Conjunto " << testType << " gerado com sucesso!" << std::endl << std::endl;
}

int main(int argc, char* argv[]) {
    // Creates data folder if it doesn't exist
    std::filesystem::create_directory("data");
    
    std::string testType = "all";
    if(argc > 1) {
        testType = argv[1];
    }
    
    int num_instances_per_param = 5; // Default number of instances per parameter set

    std::cout << "=== Gerador de Instâncias para Análise de Performance ===" << std::endl;
    
    if(testType == "all") {
        generateTestSet("items", num_instances_per_param);
        generateTestSet("weights", num_instances_per_param);
        generateTestSet("capacity", num_instances_per_param);
    } else {
        generateTestSet(testType, num_instances_per_param);
    }
    
    std::cout << "=== Geração concluída! ===" << std::endl;
    std::cout << "Para executar testes:" << std::endl;
    std::cout << "  make test-analysis" << std::endl;
    std::cout << "  ./bash/test.sh" << std::endl;
    
    return 0;
}
