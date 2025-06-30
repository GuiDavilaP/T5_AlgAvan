# Makefile para o Problema da Mochila - Análise Comparativa

CXX = g++
CXXFLAGS = -std=c++17 -O3 -Wall -Wextra
TARGETS = simpleSolver probSolver generator

.PHONY: all clean test generate-tests test-analysis help clean-results \
        generate-items generate-weights generate-capacity \
        test-items test-weights test-capacity # Adicionados novos alvos de teste

all: $(TARGETS)

# Compila o solver simples
simpleSolver: src/simpleSolver.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# Compila o solver probabilístico 	
probSolver: src/probSolver.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# Compila o gerador de instâncias
generator: src/generator.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

# Gera instâncias de teste para análise (TODAS)
generate-tests: generator
	@echo "Gerando instâncias para análise comparativa..."
	./generator all

# Gera apenas um tipo específico de teste
generate-items: generator
	./generator items

generate-weights: generator
	./generator weights

generate-capacity: generator
	./generator capacity

# Executa análise completa (todos os conjuntos)
test-analysis: all
	@echo "Executando análise comparativa completa (via bash/test.sh)..."
	@chmod +x bash/test.sh
	./bash/test.sh

# Executa apenas o conjunto de testes de itens
test-items: all
	@echo "Executando análise para o conjunto 'items'..."
	@chmod +x bash/test.sh
	./bash/test.sh items # Passa o tipo de teste como argumento

# Executa apenas o conjunto de testes de pesos
test-weights: all
	@echo "Executando análise para o conjunto 'weights'..."
	@chmod +x bash/test.sh
	./bash/test.sh weights # Passa o tipo de teste como argumento

# Executa apenas o conjunto de testes de capacidade
test-capacity: all
	@echo "Executando análise para o conjunto 'capacity'..."
	@chmod +x bash/test.sh
	./bash/test.sh capacity # Passa o tipo de teste como argumento

# Visualiza resultados CSV (resumo rápido)
show-results:
	@echo "=== Resultados da Análise ==="
	@for csv in results/*.csv; do \
		if [ -f "$$csv" ]; then \
			echo "Arquivo: $$csv"; \
			total=$(tail -n +2 $$csv | wc -l); \
			correct=$(tail -n +2 $$csv | grep ',YES,' | wc -l); \
			echo "Total de instâncias: $$total"; \
			echo "Acertos: $$correct"; \
			if [ $$total -gt 0 ]; then \
				accuracy=$(echo "scale=2; $$correct * 100 / $$total" | bc -l); \
				echo "Taxa de acerto: $${accuracy}%"; \
			else \
				echo "Taxa de acerto: N/A (nenhuma instância)"; \
			fi; \
			echo; \
		fi \
	done

# Gera relatório em texto
report: 
	@if [ ! -d "results" ]; then echo "Execute 'make test-analysis' primeiro"; exit 1; fi
	@echo "=== RELATÓRIO DE ANÁLISE COMPARATIVA ===" > results/report.txt
	@echo "Gerado em: $(date)" >> results/report.txt
	@echo >> results/report.txt
	@for test_type in items weights capacity; do \
		csv_file="results/$${test_type}_results.csv"; \
		if [ -f "$$csv_file" ]; then \
			echo "CONJUNTO: $$test_type" >> results/report.txt; \
			echo "========================" >> results/report.txt; \
			total=$(tail -n +2 $$csv_file | wc -l); \
			correct=$(tail -n +2 $$csv_file | grep ",YES," | wc -l); \
			echo "Total de instâncias: $$total" >> results/report.txt; \
			echo "Resultados corretos: $$correct" >> results/report.txt; \
			if [ $$total -gt 0 ]; then \
				accuracy=$(echo "scale=2; $$correct * 100 / $$total" | bc -l); \
				echo "Taxa de acerto: $${accuracy}%"; \
			else \
				echo "Taxa de acerto: N/A"; \
			fi; \
			echo >> results/report.txt; \
		fi \
	done
	@echo "Relatório salvo em results/report.txt"

# Python virtual environment setup
setup-python:
	python3 -m venv venv
	@echo "Virtual environment created. Activate with: source venv/bin/activate"

install-python-deps: venv/bin/activate
	./venv/bin/pip install -r requirements.txt

# Generate plots from results
plot-results: install-python-deps
	@if [ ! -d "results" ]; then echo "No results found. Run 'make test-analysis' first."; exit 1; fi
	./venv/bin/python src/plotResults.py

venv/bin/activate:
	python3 -m venv venv
	./venv/bin/pip install --upgrade pip

.PHONY: setup-python install-python-deps plot-results

# Limpa arquivos compilados e resultados
clean:
	rm -f $(TARGETS)
	rm -rf data/ results/ plots/

# Limpa apenas executáveis
clean-bin:
	rm -f $(TARGETS)

# Limpa apenas resultados
clean-results:
	rm -rf results/

clean-plots:
	rm -rf plots/

# Mostra ajuda
help:
	@echo "=== ANÁLISE COMPARATIVA - PROBLEMA DA MOCHILA ==="
	@echo
	@echo "Comandos principais:"
	@echo " 	make test-analysis 	 - Executa análise completa (TODOS os conjuntos)"
	@echo " 	make generate-tests 	 - Gera TODAS as instâncias de teste"
	@echo
	@echo "Comandos para executar testes específicos:"
	@echo " 	make test-items 	 - Executa análise APENAS para o conjunto 'items'"
	@echo " 	make test-weights 	 - Executa análise APENAS para o conjunto 'weights'"
	@echo " 	make test-capacity 	 - Executa análise APENAS para o conjunto 'capacity'"
	@echo
	@echo "Comandos específicos para geração:"
	@echo " 	make generate-items 	 - Gera testes variando número de itens"
	@echo " 	make generate-weights 	 - Gera testes variando peso máximo"
	@echo " 	make generate-capacity - Gera testes variando capacidade"
	@echo
	@echo "Visualização de resultados:"
	@echo " 	make show-results 	 - Mostra resumo dos resultados"
	@echo " 	make report 	 	 - Gera relatório em texto"
	@echo " 	make plot-results 	 - Gera gráficos a partir dos resultados"
	@echo
	@echo "Limpeza:"
	@echo " 	make clean 	 	 - Remove tudo (executáveis, dados, resultados)"
	@echo " 	make clean-bin 	 - Remove apenas executáveis"
	@echo " 	make clean-results 	 - Remove apenas resultados"
	@echo " 	make clean-plots 	 - Remove apenas gráficos"
	@echo
	@echo "Estrutura dos testes:"
	@echo " 	- Teste 1 (items): Varia n de 1000 a 15000 itens"
	@echo " 	- Teste 2 (weights): n=1000, varia peso máximo de 200 a 10000"
	@echo " 	- Teste 3 (capacity): n=1000, maxWeight=200, varia fator de capacidade"
	@echo " 	  (Cada ponto de teste agora gera 5 instâncias aleatórias, e cada instância é testada 5 vezes)"
	@echo
	@echo "Resultados salvos em:"
	@echo " 	results/items_results.csv"
	@echo " 	results/weights_results.csv"
	@echo " 	results/capacity_results.csv"

# Testa com uma instância específica
test-file: all
	@if [ -z "$(FILE)" ]; then \
		echo "Uso: make test-file FILE=data/small_01.txt"; \
		exit 1; \
	fi
	@echo "Testando arquivo: $(FILE)"
	@echo "Conteúdo do arquivo:"
	@cat $(FILE)
	@echo
	@echo "Resultado Simple Solver:"
	@./simpleSolver < $(FILE)
	@echo "Resultado Prob Solver:"
	@./probSolver < $(FILE)
