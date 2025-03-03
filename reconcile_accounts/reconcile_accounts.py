
# Bibliotecas padrao
import csv
import uuid
from pathlib import Path

# Bibliotecas third-party
import numpy as np
import pandas as pd

def reconcile_acocunts(transactions1: list, transactions2: list) -> None:
    """
    Reconcilia transações entre dois arquivos.

    Parameters
    ----------
    transactions1 : list
        Lista de transações do arquivo 1.
    transactions2 : list
        Lista de transações do arquivo 2.

    Raises
    ------
    Exception
        Erro caso o tipo do argumento não seja list
    Exception
        Erro caso o tipo do argumento não seja list
    """

    # Verifica tipo do dado de entrada
    if not isinstance(transactions1, list):
        raise Exception("Parâmetro transactions1 deve ser do tipo 'list'")
    if not isinstance(transactions2, list):
        raise Exception("Parâmetro transactions2 deve ser do tipo 'list'")

    # Transforma listas em dataframes
    columns = ['Data', 'Departamento', 'Valor', 'Beneficiário']
    df_transactions1 = pd.DataFrame(columns=columns, data=transactions1)
    df_transactions2 = pd.DataFrame(columns=columns, data=transactions2)

    # Atribui identificadores únicos de linhas
    df_transactions1 = assign_uuid(df_transactions1)
    df_transactions2 = assign_uuid(df_transactions2)

    # Obtém status das transações
    df_t1 = find_data(df_transactions1, df_transactions2)
    df_t2 = find_data(df_transactions2, df_transactions1)

    # Salva dados em .csv
    save_data(df_t1, 'transadtions1_treated.csv')
    save_data(df_t2, 'transadtions2_treated.csv')

    # Retorno padrão da função
    return None

def assign_uuid(df: pd.DataFrame) -> pd.DataFrame:
    """
    Atribui número identifcador único de linha do dataframe de transações.

    Parameters
    ----------
    df : pd.DataFrame
        Dados de transações.

    Returns
    -------
    pd.DataFrame
        Dados de transações adicionados do identificador único de linha.
    """

    # Atribui identificadores únicos de linhas
    df['id'] = [str(uuid.uuid4()) for ii in range(len(df))]

    # Retorna dataframe com identificadores atribuídos
    return df

def find_data(df_left: pd.DataFrame, df_right: pd.DataFrame) -> pd.DataFrame:
    """
    Junta os dados de transações, elimina duplicatas criadas artificialmente
    e atribui status de transações encontradas ou não.

    Parameters
    ----------
    df_left : pd.DataFrame
        Dados de junção à esquerda.
    df_right : pd.DataFrame
        Dados de junção à direita.

    Returns
    -------
    pd.DataFrame
        Dados tratados com status de encontrados ou não.
    """

    # Copia transações originais
    df_left = df_left.copy(deep=True)
    df_right = df_right.copy(deep=True)

    # Unifica transações
    df_left = pd.merge(df_left,
                       df_right,
                       on=['Departamento', 'Valor', 'Beneficiário'],
                       how='left')

    # Ordena correspodências por índice e data_y
    df_left = df_left.sort_values(by=['id_x', 'Data_y'], ascending=True)

    # Reaiza deleção de correspondências duplicas em id_x
    df_left = df_left.drop_duplicates(subset=['id_x'], keep='first')

    # Renomeia coluna de data_x
    df_left = df_left.rename(columns={'Data_x':'Data'})

    # Trata valores nulos
    df_left = df_left.replace(['', np.nan], None)

    # Atribui se transação encontrada ou não
    df_left['Status'] = ''
    for ii, row in df_left.iterrows():
        if not row['Data_y']:
            df_left.loc[ii, 'Status'] = 'MISSING'
        else:
            df_left.loc[ii, 'Status'] = 'FOUND'

    # Retorna dados tratados
    return df_left[['Data', 'Departamento', 'Valor', 'Beneficiário', 'Status']]

def save_data(df: pd.DataFrame, file_name: str) -> None:

    df.to_csv(f"./{file_name}", sep=',', index=None, header=None)
    return None

if __name__ == '__main__':
    transactions1 = list(csv.reader(open('./transactions1.csv', encoding='utf-8')))
    transactions2 = list(csv.reader(open('./transactions2.csv', encoding='utf-8')))
    reconcile_acocunts(transactions1=transactions1,
                       transactions2=transactions2)
