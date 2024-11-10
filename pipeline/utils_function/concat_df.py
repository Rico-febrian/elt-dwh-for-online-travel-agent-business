import pandas as pd
import os

# Define root directory project
DIR_ROOT_PROJECT = os.getenv('DIR_ROOT_PROJECT')

def concat_df(df1, df2):
    """
    This function use to concat/merge DataFrames

    Parameters:
    - df1, df2: DataFrames

    Returns:
    - CSV file with concatenated DataFrames
    """
    concatenated_df = pd.concat([df1, df2], ignore_index=True)
    concatenated_df.to_csv(f'{DIR_ROOT_PROJECT}/pipeline_summary.csv', index = False)
