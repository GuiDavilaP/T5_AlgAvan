#!/bin/bash

# Script para análise comparativa dos solvers do problema da mochila

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Análise Comparativa - Problema da Mochila ===${NC}"

# Cria pasta results se não existir
mkdir -p results

# Função para medir tempo de execução e obter resultado
run_solver() {
    local solver=$1
    local input_file=$2
    local timeout_duration=$3
    
    local start_time=$(date +%s.%N)
    local result=$(timeout ${timeout_duration}s ./$solver < $input_file 2>/dev/null)
    local exit_code=$?
    local end_time=$(date +%s.%N)
    
    local runtime=$(echo "scale=4; $end_time - $start_time" | bc -l)
    # Garante que o tempo de execução não seja negativo para pequenas durações
    if (( $(echo "$runtime < 0" | bc -l) )); then
        runtime=0.0000
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo "$result,$runtime,SUCCESS"
    elif [ $exit_code -eq 124 ]; then
        echo "TIMEOUT,${timeout_duration},TIMEOUT"
    else
        echo "ERROR,0,ERROR"
    fi
}

# Função para extrair parâmetros do arquivo de instância
get_instance_params() {
    local file=$1
    local n=$(head -1 $file | cut -d' ' -f1)
    local capacity=$(head -1 $file | cut -d' ' -f2)
    
    # Calcula peso máximo da terceira linha
    local max_weight=$(tail -1 $file | tr ' ' '\n' | sort -n | tail -1)
    
    echo "$n,$capacity,$max_weight"
}

# Função para testar um conjunto de instâncias
test_set() {
    local test_type=$1
    local csv_file="results/${test_type}_results.csv"
    local timeout_duration=180 # Increased timeout to 3 minutes for larger instances
    local num_repetitions=5 # Number of times to run each solver for each instance
    
    echo -e "${YELLOW}Testando conjunto: $test_type${NC}"
    echo "DEBUG: Iniciando processamento para o conjunto: $test_type"

    # Verifica se a pasta de dados existe
    if [ ! -d "data/${test_type}" ]; then
        echo -e "${RED}ERRO: Diretório 'data/${test_type}/' não existe.${NC}"
        echo -e "${RED}Por favor, execute 'make generate-${test_type}' ou 'make generate-tests' primeiro.${NC}"
        # Updated CSV header
        echo "Instance,N,Capacity,MaxWeight,Avg_Simple_Result,Avg_Simple_Time,Avg_Prob_Result,Avg_Prob_Time,Optimal,Avg_Time_Ratio,Avg_Percentage_Diff" > $csv_file
        echo "N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,NO,N/A,N/A" >> $csv_file # No status columns
        return 1
    fi
    
    # Conta quantos arquivos existem com o padrão correto usando find para evitar problemas de glob
    local file_pattern="test_${test_type}_*_run*.txt" # Updated pattern for new naming convention
    local file_count=$(find "data/${test_type}" -name "$file_pattern" -type f | wc -l)
    if [ "$file_count" -eq 0 ]; then
        echo -e "${RED}ERRO: Nenhum arquivo '${file_pattern}' encontrado em 'data/${test_type}/'.${NC}"
        echo -e "${RED}Por favor, execute 'make generate-${test_type}' ou 'make generate-tests' primeiro.${NC}"
        # Updated CSV header
        echo "Instance,N,Capacity,MaxWeight,Avg_Simple_Result,Avg_Simple_Time,Avg_Prob_Result,Avg_Prob_Time,Optimal,Avg_Time_Ratio,Avg_Percentage_Diff" > $csv_file
        echo "N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A,NO,N/A,N/A" >> $csv_file # No status columns
        return 1
    fi
    
    echo "Encontrados $file_count arquivos de teste."

    # Cabeçalho do CSV atualizado para médias e sem colunas de status
    echo "Instance,N,Capacity,MaxWeight,Avg_Simple_Result,Avg_Simple_Time,Avg_Prob_Result,Avg_Prob_Time,Optimal,Avg_Time_Ratio,Avg_Percentage_Diff" > $csv_file
    
    # Processa cada instância do conjunto na subpasta correta usando find para robustez
    find "data/${test_type}" -name "$file_pattern" -type f | sort | while read file; do
        local instance_name=$(basename "$file" .txt)
        echo -n "  Processando $instance_name (${num_repetitions} repetições)... "
            
        # Extrai parâmetros da instância
        local params=$(get_instance_params "$file")
        local n=$(echo "$params" | cut -d',' -f1)
        local capacity=$(echo "$params" | cut -d',' -f2)
        local max_weight=$(echo "$params" | cut -d',' -f3)

        local sum_simple_result=0
        local sum_simple_time=0
        local sum_prob_result=0
        local sum_prob_time=0
        local sum_percentage_diff=0
        local count_diff_calc=0
        local simple_success_count=0
        local prob_success_count=0
        local all_simple_success="YES" # Flag para verificar se todas as repetições do simpleSolver foram SUCCESS
        local all_prob_success="YES"   # Flag para verificar se todas as repetições do probSolver foram SUCCESS
        
        # Loop para múltiplas repetições
        for (( rep=1; rep<=num_repetitions; rep++ )); do
            # Executa simple solver
            local simple_output=$(run_solver "simpleSolver" "$file" "$timeout_duration")
            local simple_result_rep=$(echo "$simple_output" | cut -d',' -f1)
            local simple_time_rep=$(echo "$simple_output" | cut -d',' -f2)
            local simple_status_rep=$(echo "$simple_output" | cut -d',' -f3)
            
            # Executa prob solver
            local prob_output=$(run_solver "probSolver" "$file" "$timeout_duration")
            local prob_result_rep=$(echo "$prob_output" | cut -d',' -f1)
            local prob_time_rep=$(echo "$prob_output" | cut -d',' -f2)
            local prob_status_rep=$(echo "$prob_output" | cut -d',' -f3)

            if [ "$simple_status_rep" = "SUCCESS" ]; then
                sum_simple_result=$(echo "scale=0; $sum_simple_result + $simple_result_rep" | bc -l)
                sum_simple_time=$(echo "scale=4; $sum_simple_time + $simple_time_rep" | bc -l)
                simple_success_count=$((simple_success_count + 1))
            else
                all_simple_success="NO" # Se uma falha, marca como NO
            fi

            if [ "$prob_status_rep" = "SUCCESS" ]; then
                sum_prob_result=$(echo "scale=0; $sum_prob_result + $prob_result_rep" | bc -l)
                sum_prob_time=$(echo "scale=4; $sum_prob_time + $prob_time_rep" | bc -l)
                prob_success_count=$((prob_success_count + 1))
            else
                all_prob_success="NO" # Se uma falha, marca como NO
            fi

            # Calcula diferença percentual para esta repetição se ambos SUCESSO e diferentes
            if [ "$simple_status_rep" = "SUCCESS" ] && [ "$prob_status_rep" = "SUCCESS" ] && [ "$simple_result_rep" != "$prob_result_rep" ] && (( $(echo "$simple_result_rep != 0" | bc -l) )); then
                local percentage_diff_rep=$(echo "scale=4; ($simple_result_rep - $prob_result_rep) / $simple_result_rep * 100" | bc -l 2>/dev/null || echo "N/A")
                if [ "$percentage_diff_rep" != "N/A" ]; then
                    sum_percentage_diff=$(echo "scale=4; $sum_percentage_diff + $percentage_diff_rep" | bc -l)
                    count_diff_calc=$((count_diff_calc + 1))
                fi
            fi
        done # End of repetitions loop

        # Calcula médias
        local avg_simple_result="N/A"
        local avg_simple_time="N/A"
        local avg_prob_result="N/A"
        local avg_prob_time="N/A"
        local avg_percentage_diff="N/A"
        local avg_time_ratio="N/A"
        local optimal_match="NO" # Renomeado de 'correct' para 'optimal_match'

        if [ "$simple_success_count" -gt 0 ]; then
            avg_simple_result=$(echo "scale=0; $sum_simple_result / $simple_success_count" | bc -l)
            avg_simple_time=$(echo "scale=4; $sum_simple_time / $simple_success_count" | bc -l)
        fi

        if [ "$prob_success_count" -gt 0 ]; then
            avg_prob_result=$(echo "scale=0; $sum_prob_result / $prob_success_count" | bc -l)
            avg_prob_time=$(echo "scale=4; $sum_prob_time / $prob_success_count" | bc -l)
        fi

        # Verifica se as médias são iguais para o status 'Optimal'
        # Considera "Optimal" apenas se ambos os solvers foram SUCCESS em TODAS as repetições
        if [ "$all_simple_success" = "YES" ] && [ "$all_prob_success" = "YES" ]; then
            if [ "$avg_simple_result" = "$avg_prob_result" ]; then
                optimal_match="YES"
                echo -e "${GREEN}OK (Médias Iguais)${NC}"
            else
                optimal_match="NO"
                echo -e "${RED}DIFFERENT (Médias)${NC}"
            fi
        else
            optimal_match="N/A" # Se houve timeout/erro em alguma repetição, não é "Optimal"
            echo -e "${RED}TIMEOUT/ERROR (Algum Solver)${NC}"
        fi

        # Calcula razão de tempo média
        if [ "$all_simple_success" = "YES" ] && [ "$all_prob_success" = "YES" ] && (( $(echo "$avg_prob_time > 0" | bc -l) )); then
            avg_time_ratio=$(echo "scale=4; $avg_simple_time / $avg_prob_time" | bc -l 2>/dev/null || echo "N/A")
        fi

        # Calcula diferença percentual média
        if [ "$count_diff_calc" -gt 0 ]; then
            avg_percentage_diff=$(echo "scale=2; $sum_percentage_diff / $count_diff_calc" | bc -l 2>/dev/null || echo "N/A")
        fi
            
        # Escreve linha no CSV (sem colunas de status individuais)
        echo "$instance_name,$n,$capacity,$max_weight,$avg_simple_result,$avg_simple_time,$avg_prob_result,$avg_prob_time,$optimal_match,$avg_time_ratio,$avg_percentage_diff" >> $csv_file
    done
    
    echo -e "${GREEN}Resultados salvos em: $csv_file${NC}"
    echo
    return 0 # Indica sucesso
}

# Compila os solvers se necessário
if [ ! -f "simpleSolver" ] || [ ! -f "probSolver" ]; then
    echo -e "${YELLOW}Compilando solvers...${NC}"
    # Use make to compile, which now handles src/ paths
    make simpleSolver probSolver
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao compilar solvers!${NC}"
        exit 1
    fi
fi

# Determine which test sets to run based on arguments
if [ -z "$1" ]; then # No argument provided, run all
    TEST_SETS_TO_RUN=("items" "weights" "capacity")
else # Argument provided, run only that test set
    TEST_SETS_TO_RUN=("$1")
fi

# Executa testes para cada conjunto
for test_type in "${TEST_SETS_TO_RUN[@]}"; do
    test_set "$test_type" || exit 1
done

# Gera relatório resumido
echo -e "${BLUE}=== Relatório Resumido ===${NC}"

# Loop através dos conjuntos que foram realmente testados
for test_type in "${TEST_SETS_TO_RUN[@]}"; do
    csv_file="results/${test_type}_results.csv"
    if [ -f "$csv_file" ]; then
        total=$(tail -n +2 "$csv_file" | wc -l)
        # Conta agora as linhas onde a coluna 'Optimal' é 'YES'
        optimal_matches=$(tail -n +2 "$csv_file" | grep ",YES," | wc -l) 
        accuracy=$(echo "scale=2; $optimal_matches * 100 / $total" | bc -l) # Usa optimal_matches

        echo "  Conjunto $test_type:"
        echo "  Total de instâncias: $total"
        echo "  Resultados Ótimos (médias iguais): $optimal_matches" # Texto atualizado
        echo "  Taxa de Optimalidade (médias iguais): ${accuracy}%" # Texto atualizado
        
        avg_simple=$(tail -n +2 "$csv_file" | cut -d',' -f6 | grep -v "N/A" | awk '{sum+=$1; count++} END {if(count>0) printf "%.4f", sum/count; else print "N/A"}') # Coluna ajustada
        avg_prob=$(tail -n +2 "$csv_file" | cut -d',' -f8 | grep -v "N/A" | awk '{sum+=$1; count++} END {if(count>0) printf "%.4f", sum/count; else print "N/A"}') # Coluna ajustada
        
        echo "  Tempo médio Simple Solver: ${avg_simple}s"
        echo "  Tempo médio Prob Solver: ${avg_prob}s"
        
        if [ "$avg_simple" != "N/A" ] && [ "$avg_prob" != "N/A" ] && (( $(echo "$avg_prob > 0" | bc -l) )); then
            speedup=$(echo "scale=2; $avg_simple / $avg_prob" | bc -l)
            echo "  Speedup médio: ${speedup}x"
        else
            echo "  Speedup médio: N/A"
        fi

        avg_percentage_diff=$(tail -n +2 "$csv_file" | cut -d',' -f11 | grep -v "N/A" | awk '{sum+=$1; count++} END {if(count>0) printf "%.2f", sum/count; else print "N/A"}') # Coluna ajustada
        echo "  Diferença percentual média (quando diferente): ${avg_percentage_diff}%"
        echo
    fi
done

echo -e "${GREEN}=== Análise concluída! ===${NC}"
echo -e "Arquivos de resultado:"
echo -e "  ${BLUE}results/items_results.csv${NC} - Variação no número de itens"
echo -e "  ${BLUE}results/weights_results.csv${NC} - Variação no peso máximo"
echo -e "  ${BLUE}results/capacity_results.csv${NC} - Variação na capacidade"
