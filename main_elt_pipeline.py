import luigi
import pandas as pd
import sentry_sdk
import os

from pipeline.extract import Extract
from pipeline.load import Load
from pipeline.transform import Transform
from pipeline.utils_function.concat_df import concat_df
from pipeline.utils_function.copy_log import copy_log
from pipeline.utils_function.delete_temp_data import delete_temp

from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

# Define and read env variables
DIR_ROOT_PROJECT = os.getenv("DIR_ROOT_PROJECT")
DIR_TEMP_LOG = os.getenv("DIR_TEMP_LOG")
DIR_TEMP_DATA = os.getenv("DIR_TEMP_DATA")
DIR_LOG = os.getenv("DIR_LOG")
SENTRY_DSN = os.getenv("SENTRY_DSN")

# Configure Sentry to track the error
sentry_sdk.init(
    dsn = f"{SENTRY_DSN}"
)

# Execute selected function when the script is run

# Run the ELT pipeline
if __name__ == '__main__':
    luigi.build([Load(),
                 Extract(),
                 Transform()])
    
    # Create initial pipeline summary from extract summary
    extract_summary = pd.read_csv(f'{DIR_TEMP_DATA}/extract-summary.csv')
    extract_summary.to_csv(f'{DIR_ROOT_PROJECT}/pipeline_summary.csv', index=False)
    
    # Concat temp load summary to final summary
    concat_df(
        df1 = pd.read_csv(f'{DIR_ROOT_PROJECT}/pipeline_summary.csv'),
        df2 = pd.read_csv(f'{DIR_TEMP_DATA}/load-summary.csv')
    )
    
    # Concat temp load summary to final summary
    concat_df(
        df1 = pd.read_csv(f'{DIR_ROOT_PROJECT}/pipeline_summary.csv'),
        df2 = pd.read_csv(f'{DIR_TEMP_DATA}/transform-summary.csv')
    )
    
    # Append log from temp to final log
    copy_log(
        source_log = f'{DIR_TEMP_LOG}/logs.log',
        destination_log = f'{DIR_LOG}/logs.log'
    )
    
    # Delete temp data
    delete_temp(
        directory = f'{DIR_TEMP_DATA}'
    )
    
    # Delete temp log
    delete_temp(
        directory = f'{DIR_TEMP_LOG}'
    )
