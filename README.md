# How I Build a Data Warehouse & ELT Pipeline with DTB and Luigi

Hi there! Welcome to my learning logs.

**In this guide, I will share how I developed an ELT pipeline for an e-travel booking business based on a case study**. For the full story about the case study and how I designed the data warehouse, you can check out my article on Medium here: [full-story](https://medium.com/@ricofebrian731/learning-data-engineering-designing-a-data-warehouse-and-building-an-elt-pipeline-for-e-commerce-1f6b77cdfc28).

**In this repository, I’ll focus specifically on how I developed the ELT pipeline, including:**
- Developing the ELT script
- Managing data transformations with DBT
- Orchestrating the pipeline with Luigi
- Automating the pipeline with Cron

---

# Dataset Overview
I used a dataset related to an e-travel booking business. You can clone this repository to access the full dataset: [pactravel-dataset]()

---

Alright, let's begin!, Here's the step-by-step guide:

# Requirements

- OS:
    - Linux
    - WSL (Windows Subsystem For Linux)
      
- Tools:
    - Dbeaver (using postgreSQL)
    - Docker
    - DBT
    - Cron
      
- Programming Language:
    - Python
    - SQL
      
- Python Libray:
    - Luigi
    - Pandas
    - Sentry-SDK
      
- Platforms:
    - Sentry

---

# Preparations

## - **Clone or download this repository to get the populated data for the source database**

  ```
  git lfs clone git@github.com:Kurikulum-Sekolah-Pacmann/dataset-olist.git
  ```

## - **Create and activate python environment to isolate project dependencies**
  
  ```
  python -m venv your_project_name         
  source your_project_name/bin/activate    # On Windows: your_project_name\Scripts\activate
  ```
  
## - **Set up a directory structure to organize all project scripts**
  
  ```
  project/
  ├── helper/ ------------- # To store SQL script to create db schema
  │   ├── dwh_schema/
  │   └── src_schema/
  ├── logs/ --------------- # To store pipeline logs
  ├── pipeline/ ----------- # To store pipeline dependencies and develop the scripts 
  │   ├── elt_query/
  │   ├── utils_function/
  │   └── elt_dev_script.py
  ├── temp/ ----------- # To store temporary data from ELT task 
  │   ├── data
  │   └── log
  │ ----------------------- # Root project to store the main scripts
  │ 
  ├── .env
  ├── main_pipeline.py 
  ├── pipeline.sh
  ├── docker-compose.yml
  └── requirements.txt
  ```

## - **Install _requirements.txt_ in the created environment**
  
  ```
  pip install -r requirements.txt
  ```
  
**Note: You can install libraries as needed while developing the code. However, once complete, make sure to generate a _requirements.txt_ file listing all dependencies**.

## - **Create _.env_ file to store all credential information**
  
  ```
  touch .env
  ```
  
## - **Set up a Sentry project to receive an e-mail notifications in case of any errors in the pipeline**
  - Open and signup to: https://www.sentry.io 
  - Create Project :
    - Select Platform : Python
    - Set Alert frequency : `On every new issue`
    - Create project name.
  - After create the project, **store the SENTRY DSN project key into the .env file**

---

# Developing The ELT Scripts

## - Setup database

  - Create a [_docker-compose.yml_](https://github.com/Rico-febrian/elt-dwh-pactravel/blob/main/docker-compose.yaml) file to set up both the data source and data warehouse databases
  
  - Store database credentials in _.env_ file  

    ```
    # Source
    SRC_POSTGRES_DB=[YOUR SOURCE DB NAME]
    SRC_POSTGRES_HOST=localhost
    SRC_POSTGRES_USER=[YOUR USERNAME]
    SRC_POSTGRES_PASSWORD=[YOUR PASSWORD]
    SRC_POSTGRES_PORT=[YOUR PORT]
    
    # DWH
    DWH_POSTGRES_DB=[YOUR DWH DB NAME] 
    DWH_POSTGRES_HOST=localhost
    DWH_POSTGRES_USER=[YOUR USERNAME]
    DWH_POSTGRES_PASSWORD=[YOUR PASSWORD]
    DWH_POSTGRES_PORT=[YOUR PORT]
    ```
 
  - Run the _docker-compose.yml_ file 

    ```
    docker-compose up -d
    ```

  - Connect the database to Dbeaver
    - Click **Database** > select **New Database Connection**
    - Select postgreSQL
    - Fill in the port, database, username, and password **as defined in your _.env_**
    - Click **Test Connection**
    - If no errors appear, the database connection is successful   

## - Create utility functions

  **This utility function acts like a basic tool you can use repeatedly when building the pipeline script.**

  -  [Database connector]()
      -  Function to connect python and the database    
  
  -  [Read SQL file]()
      -  Function to read the SQL query files and return it as string so python can run it 
  
  - [Concat DataFrame summary - Optional]()
      - Function to merge the summary data from ELT pipeline

  - [Copy log - Optional]()
      - Function to copy temporary log into main log

  - [Delete temporary data - Optional]()
      - Function to delete all temporary data from ELT pipeline 

## - Create SQL queries

**These queries are used to set up the schemas, tables, and their constraints _based on the data warehouse design_.**

You can view the complete data warehouse design for this project in my Medium article: [Data Warehouse Design]()

  - Source database
    - [init]()
      
  - Warehouse database
    - [Public schema]()
      
    - [Staging schema]()
      
    - [Final schema]()
      
    - [Snapshot schema]()
      
## - Create EXTRACT and LOAD queries 

**These queries are used to extract and load data from the source database into the public and staging schemas in the warehouse database.**

  - [Extract query]()
    - This query used to:
      - Extract data from source database into data warehouse's public schema
  
  - [Load queries]()
    - This query used to:
      - Load data from public to staging schema
      - Handle updated data in each table within staging schema

## - Managing data transformations with DBT

- Setup DBT
    - Install DBT 
      ```
      pip install dbt-[YOUR_SELECTED_DATABASE_NAME]
      ``` 
      
      In this project I'm using postgreSQL
    
      ```
      pip install dbt-postgres
      ```
    - Initiate DBT project

      ```
      dbt init
      ``` 
      ```
      host: localhost / [YOUR DATABASE HOSTNAME]
      port: [YOUR DB PORT]
      user: [YOUR DATABASE USERNAME]
      pass: [YOUR DATABASE PASSWORD]
      dbname: [YOUR DATABASE NAME]
      schema: [YOUR DATABASE SCHEMA NAME]
      threads (1 or more): [SET TO THE LOWEST VALUE IF YOUR PC SLOW] 
      ```
    After initiating the project, a new directory will be created in your root project directory, like this: [dbt](https://github.com/Rico-febrian/elt-dwh-pactravel/tree/main/pactravel_dbt)

- Create DBT model
  
    - Preparation
      
        - Set the materialization strategy and timezone
          
          Update your dbt_project.yml file inside the DBT project directory to look like this: [dbt_project.yml]()
  
        - Set up the required packages
          
          Create a packages.yml file inside your DBT project directory and define the required packages: [packages.yml]()
          
    - Build staging layer model
      
        - Create new directory

          **This directory will used to store all staging model configuration**
          ```
          # Change to the "models" directory in your DBT project directory
          cd [YOUR_DBT_PROJECT_DIR_NAME]/models/
          ```
          ```
          # Create "staging" directory
          mkdir staging
          ```

        - Create Jinja configuration files for the source and all staging models
            - First, set up the source configuration
            - Next, create all the staging models
           
           **NOTE: Create the source configuration first, as it is used to reference the selected schema in your data warehouse**

          Check here for the [complete staging layer configuration]()

        - Create a date/time dimension using a seed file
            - Download the date dimension CSV file here: [dim_date.csv](https://drive.google.com/file/d/1D1HVjFBHotwC4cWSxBebZTBb62aMQs6d/view)
            - Place the file in the **seeds** directory of your DBT project  

          **NOTE: You can also create the date/time dimension using packages.**

    - Build marts layer model
      
        - Create new directory

          **This directory will used to store all marts model configuration**
                 
          ```
          # Change to the "models" directory in your DBT project directory
          cd [YOUR_DBT_PROJECT_DIR_NAME]/models/
          ```
          ```
          # Create the "marts/core" directory
          mkdir marts; cd marts; mkdir core
          ```

        - Create Jinja configuration files for the core and all marts models
            - First, create all the marts models
            - Next, set up the core models configuration
     
          **NOTE: The core models configuration is used to create constraints and perform data quality testing.**

          Check here for the [complete marts layer configuration]()

    - Create Snapshot

      In this project, I used DBT snapshots **to track and store data changes over time**. These snapshots are based on the **Slowly Changing Dimension (SCD) strategy** defined during the data warehouse design. Check here for the [complete snapshot configuration]()

---

After completing the DBT model build, you can test it by running the following DBT commands:

```
dbt debug    # Checks the database connection and the current DBT environment
```

```
dbt deps     # Install the DBT packages specified
```

Then, run these commands sequentially to compile all the models:

```
dbt seed     # loads the specified CSV files into your data warehouse
```

```
dbt run      # Compiles all models and loads them into your data warehouse
```

```
dbt test     # Runs tests and creates the constraints in your models
```

        
## - Create ELT pipeline task

I developed each task separately to ensure everything function properly.

  - Common components in each task
    
    - Logging setup
        ```
        # Configure logging at the start of each task to assist with monitoring and debugging
  
        # Configure logging
        logging.basicConfig(filename = f'{<YOUR DIRECTORY TO STORE LOG>}/logs.log', 
                            level = logging.INFO, 
                            format = '%(asctime)s - %(levelname)s - %(message)s')
        
        # Record start time
        start_time = time.time()
        
        # Create a log message
        logging.info("START LOG")

        try: 
          ....................................
          # YOUR MAIN CODE/FUNCTION
          ...................................
          
        # If there is an error, catch and store to the log file
        except Exception:
            logging.error()  
            raise Exception()

        # Log completion
        logging.info('TASK SUCCESS/FAILED!')
        end_time = time.time()  # Record end time
        execution_time = end_time - start_time  # Calculate execution time
        logging.info("END LOG")
        ```
  
  - Task summary setup
      ```
      # This summary makes tracking and analyzing pipeline tasks easier than using logs  
      
      # Define a summary
      summary_data = {
          'timestamp': [datetime.now()],
          'task': ['<CHANGE WITH YOUR TASK NAME>'],
          'status' : ['Success'],
          'execution_time': [execution_time]
      }
      
      # Get summary dataframes
      summary = pd.DataFrame(summary_data)
      
      # Write DataFrame to CSV
      summary.to_csv(f"{YOUR TEMPORARY DATA DIRECTORY}/<YOUR SUMMARY FILENAME>", index = False)
      ```
  
- Main pipeline task
  
  - [Extract task]()
    - This task will **pulls data from the source database** and **loads it into the public schema** in the warehouse database
    - Task outputs include:
      - CSV files for each extracted table
      - Task summary CSV
      - Log file
        
  - [Load task]()
    - This task **reads data from each CSV file generated by the Extract task** and **loads it into the staging schema** in the warehouse database
    - Task outputs include:
      - Task summary CSV
      - Log file

  - [Transform task]()
    - This task **executes a shell script** to perform data transformations using DBT **by converting DBT commands into a Python script**
    - This outputs include:
      - Task summary CSV
      - Log file

---

# Orchestrating the pipeline with Luigi

**NOTE: Luigi has some limitations you should be aware of when using it for data orchestration, such as:**

- History Task Retention (only 15 minutes by default)
- Idempotency Requirement
- No Built-in Scheduler

For a detailed explanation, you can check the documentation: [Luigi Limitations]()

## - Compile all task

Compile all task into a single main script, like this: [main_elt_pipeline.py]()

## - Run the ELT pipeline

Run the main script to test the pipeline end-to-end
```
python3 YOUR_MAIN_PIPELINE_NAME.py
```

**NOTE: When developed the script you can run the Luigi task separately**
```
# In your task script, run this:
if __name__ == '__main__':
     luigi.build(<TASK NAME>()])
```

**Or you can execute all of them at once**
```
# In your final task script, run this:
if __name__ == '__main__':
     luigi.build([<TASK A>(),
                  <TASK B>(),
                  ..........
                  <UNTIL YOUR LAST TASK>()])
```

## - Verify all outputs
If your pipeline runs successfully, you can verify it in DBeaver by checking the warehouse database

## - Monitoring log and task summary
  
You can easily check and review the log files and summaries created in each task for any errors in your pipeline during development

- Error log

![Error log](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/assets/log_failed.png)

- Error task summary

![Error task summary](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/assets/summary_failed.png)

---

# Automating the pipeline with Cron

Since Luigi doesn't have a built-in scheduler, you can automate the pipeline using Cron

## - Set up schedulers

- Create a cron job to automate pipeline execution.
  
  - Create shell script [elt_pipeline.sh]()
    ```
    touch SHELL_SCRIPT_NAME.sh
    ```
    
    In SHELL_SCRIPT_NAME.sh, write this:
    ```
    #!/bin/bash
    
    # Virtual Environment Path
    VENV_PATH="/PATH/TO/YOUR/VIRTUAL/ENVIRONMENT/bin/activate"
    
    # Activate Virtual Environment
    source "$VENV_PATH"
    
    # Set Python script
    PYTHON_SCRIPT="/PATH/TO/YOUR/MAIN/PIPELINE/SCRIPT/main_elt_pipeline.py"
    
    # Run Python Script 
    python "$PYTHON_SCRIPT"
    ```

  - Make the script executable
    ```
    # In your shell script directory, run this
    chmod +x SHELL_SCRIPT_NAME.sh
    ```
  - Set up cron job
    ```
    # Open crontab
    crontab -e
    ```
    ```
    # In crontab editor

    # Set the schedule like this to run the pipeline EVERY HOUR
    0 * * * * /PATH/TO/YOUR/SHELL/SCRIPT/SHELL_SCRIPT_NAME.sh
    ```
  - Or you can run the shell script manually
    ```
    ./SHELL_SCRIPT_NAME.sh
    ```
  
  ---

# Final Result

## - Data Warehouse Lineage Graph
![DWH Lineage Graph]()

## - Testing Queries

- Revenue and total bookings metrics
    - Total daily revenue and booking details
      ![Metric 1]()
       
- Average ticket price over time metrics
    - Average flight ticket price yearly
      ![Metric 2]()
    
    - Average hotel price yearly
      ![Metric 3]()

## - Luigi DAG Graph

![Luigi DAG Graph](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/assets/dag_graph.png)

## - Pipeline Summary

![Luigi DAG Graph]()

## - Pipeline Log

![Luigi DAG Graph]()
