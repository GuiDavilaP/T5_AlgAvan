import pandas as pd
import matplotlib.pyplot as plt
import os

def save_df_as_markdown_table(df, filename, title, output_dir):
    """
    Salva um DataFrame como uma tabela Markdown em um arquivo.
    """
    filepath = os.path.join(output_dir, filename)
    with open(filepath, 'w') as f:
        f.write(f"### {title}\n\n")
        f.write(df.to_markdown(index=False))
        f.write("\n")
    print(f"Tabela salva em: {filepath}")


def plot_results(df, x_col, title_prefix, output_dir):
    """
    Gera gráficos de tempo médio, optimalidade e speedup com barras de erro.
    Também gera tabelas Markdown dos dados agregados.
    """
    # Garante que o diretório de saída exista
    os.makedirs(output_dir, exist_ok=True)

    # Converte colunas para numérico, tratando 'N/A'
    df['Avg_Simple_Time'] = pd.to_numeric(df['Avg_Simple_Time'], errors='coerce')
    df['Avg_Prob_Time'] = pd.to_numeric(df['Avg_Prob_Time'], errors='coerce')
    df['Optimal_Percentage'] = pd.to_numeric(df['Optimal_Percentage'], errors='coerce')
    df['Avg_Time_Ratio'] = pd.to_numeric(df['Avg_Time_Ratio'], errors='coerce')

    # Agrupa os dados pelo valor do eixo X (ex: N, MaxWeight, CapacityFactor)
    # e calcula a média e o desvio padrão para cada grupo.
    # Isso é necessário porque temos múltiplas 'runs' para o mesmo ponto de teste.
    grouped_df = df.groupby(x_col).agg(
        avg_simple_time_mean=('Avg_Simple_Time', 'mean'),
        avg_simple_time_std=('Avg_Simple_Time', 'std'),
        avg_prob_time_mean=('Avg_Prob_Time', 'mean'),
        avg_prob_time_std=('Avg_Prob_Time', 'std'),
        optimal_percentage_mean=('Optimal_Percentage', 'mean'),
        optimal_percentage_std=('Optimal_Percentage', 'std'),
        avg_time_ratio_mean=('Avg_Time_Ratio', 'mean'),
        avg_time_ratio_std=('Avg_Time_Ratio', 'std')
    ).reset_index()

    # Ordena pelo eixo X para gráficos mais claros
    grouped_df = grouped_df.sort_values(by=x_col)

    # --- Preparação dos dados para a tabela ---
    table_df = grouped_df.copy()
    table_df.rename(columns={
        x_col: x_col.replace('_extracted', ''),
        'avg_simple_time_mean': 'Tempo Simple (s) Médio',
        'avg_simple_time_std': 'Tempo Simple (s) Std',
        'avg_prob_time_mean': 'Tempo Prob (s) Médio',
        'avg_prob_time_std': 'Tempo Prob (s) Std',
        'optimal_percentage_mean': 'Optimalidade (%) Média',
        'optimal_percentage_std': 'Optimalidade (%) Std',
        'avg_time_ratio_mean': 'Speedup (x) Médio',
        'avg_time_ratio_std': 'Speedup (x) Std'
    }, inplace=True)

    # Formata colunas numéricas para melhor visualização na tabela
    for col in table_df.columns:
        if 'Tempo' in col or 'Speedup' in col:
            table_df[col] = table_df[col].round(4)
        elif 'Optimalidade' in col:
            table_df[col] = table_df[col].round(2)

    # Salva a tabela Markdown
    table_filename = f'{title_prefix.lower().replace(" ", "_")}_results_table.md'
    table_title = f'Resultados Agregados para {title_prefix}'
    save_df_as_markdown_table(table_df, table_filename, table_title, output_dir)


    # --- Gráfico de Tempo Médio de Execução com Barras de Erro ---
    plt.figure(figsize=(12, 6))
    plt.errorbar(grouped_df[x_col], grouped_df['avg_simple_time_mean'], 
                 yerr=grouped_df['avg_simple_time_std'], fmt='-o', capsize=5, label='Simple Solver (Médio)')
    plt.errorbar(grouped_df[x_col], grouped_df['avg_prob_time_mean'], 
                 yerr=grouped_df['avg_prob_time_std'], fmt='-x', capsize=5, label='Prob Solver (Médio)')
    plt.xlabel(x_col.replace('_extracted', '')) # Remove '_extracted' do label do eixo
    plt.ylabel('Tempo de Execução Médio (s)')
    plt.title(f'{title_prefix} - Tempo de Execução Médio (com Desvio Padrão) vs. {x_col.replace("_extracted", "")}') # Remove '_extracted' do título
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'{title_prefix.lower().replace(" ", "_")}_avg_time_with_std_vs_{x_col.lower().replace("_extracted", "")}.png'))
    plt.close()

    # --- Gráfico de Porcentagem de Optimalidade Média (com Barras de Erro para variabilidade entre runs) ---
    plt.figure(figsize=(12, 6))
    plt.errorbar(grouped_df[x_col], grouped_df['optimal_percentage_mean'], 
                 yerr=grouped_df['optimal_percentage_std'], fmt='-o', capsize=5, color='green')
    plt.xlabel(x_col.replace('_extracted', '')) # Remove '_extracted' do label do eixo
    plt.ylabel('Porcentagem de Optimalidade Média (%)')
    plt.title(f'{title_prefix} - Optimalidade Média do Prob Solver (com Desvio Padrão) vs. {x_col.replace("_extracted", "")}') # Remove '_extracted' do título
    plt.ylim(0, 105) # Garante que o eixo Y vá de 0 a 100
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'{title_prefix.lower().replace(" ", "_")}_optimality_with_std_vs_{x_col.lower().replace("_extracted", "")}.png'))
    plt.close()

    # --- Gráfico de Speedup Médio com Barras de Erro ---
    plt.figure(figsize=(12, 6))
    plt.errorbar(grouped_df[x_col], grouped_df['avg_time_ratio_mean'], 
                 yerr=grouped_df['avg_time_ratio_std'], fmt='-o', capsize=5, color='purple')
    plt.xlabel(x_col.replace('_extracted', '')) # Remove '_extracted' do label do eixo
    plt.ylabel('Speedup Médio (Simple Time / Prob Time)')
    plt.title(f'{title_prefix} - Speedup Médio (com Desvio Padrão) vs. {x_col.replace("_extracted", "")}') # Remove '_extracted' do título
    plt.grid(True)
    plt.axhline(y=1, color='gray', linestyle='--', linewidth=0.8, label='Speedup = 1 (Mesmo Tempo)')
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'{title_prefix.lower().replace(" ", "_")}_speedup_with_std_vs_{x_col.lower().replace("_extracted", "")}.png'))
    plt.close()


if __name__ == "__main__":
    results_dir = 'results'
    plots_output_dir = 'plots'

    # Cria o diretório de saída para os gráficos
    os.makedirs(plots_output_dir, exist_ok=True)

    # --- Teste de Itens ---
    try:
        df_items = pd.read_csv(os.path.join(results_dir, 'items_results.csv'))
        # Para o teste de itens, o N está no nome da instância, precisamos extraí-lo
        df_items['N_extracted'] = df_items['Instance'].apply(lambda x: int(x.split('_')[2]))
        plot_results(df_items, 'N_extracted', 'Variação de Itens', plots_output_dir)
        print("Gráficos e tabelas para 'items' gerados com sucesso.")
    except FileNotFoundError:
        print("Arquivo 'items_results.csv' não encontrado. Execute 'make test-items' primeiro.")
    except Exception as e:
        print(f"Erro ao gerar gráficos e tabelas para 'items': {e}")

    # --- Teste de Pesos ---
    try:
        df_weights = pd.read_csv(os.path.join(results_dir, 'weights_results.csv'))
        # Para o teste de pesos, o MaxWeight está no nome da instância
        df_weights['MaxWeight_extracted'] = df_weights['Instance'].apply(lambda x: int(x.split('_')[2]))
        plot_results(df_weights, 'MaxWeight_extracted', 'Variação de Peso Máximo', plots_output_dir)
        print("Gráficos e tabelas para 'weights' gerados com sucesso.")
    except FileNotFoundError:
        print("Arquivo 'weights_results.csv' não encontrado. Execute 'make test-weights' primeiro.")
    except Exception as e:
        print(f"Erro ao gerar gráficos e tabelas para 'weights': {e}")

    # --- Teste de Capacidade ---
    try:
        df_capacity = pd.read_csv(os.path.join(results_dir, 'capacity_results.csv'))
        # Para o teste de capacidade, o CapacityFactor está no nome da instância
        df_capacity['CapacityFactor_extracted'] = df_capacity['Instance'].apply(lambda x: int(x.split('_')[2]))
        plot_results(df_capacity, 'CapacityFactor_extracted', 'Variação de Capacidade', plots_output_dir)
        print("Gráficos e tabelas para 'capacity' gerados com sucesso.")
    except FileNotFoundError:
        print("Arquivo 'capacity_results.csv' não encontrado. Execute 'make test-capacity' primeiro.")
    except Exception as e:
        print(f"Erro ao gerar gráficos e tabelas para 'capacity': {e}")

    print("\nProcesso de geração de gráficos e tabelas concluído. Verifique a pasta 'plots/'.")

