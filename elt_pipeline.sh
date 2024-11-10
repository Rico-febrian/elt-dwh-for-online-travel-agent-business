#!/bin/bash

echo "========== Start Orchestration Process =========="

# Virtual Environment Path
VENV_PATH="/home/ricofebrian/data-warehouse-labs/exercise/exercise-3/elt-pactravel/bin/activate"

# Activate Virtual Environment
source "$VENV_PATH"

# Set Python script
PYTHON_SCRIPT="/home/ricofebrian/data-warehouse-labs/exercise/exercise-3/main_elt_pipeline.py"

# Run Python Script 
python "$PYTHON_SCRIPT"

echo "========== End of Orchestration Process =========="
