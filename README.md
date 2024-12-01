# How I Built a Data Warehouse & ELT Pipeline with DBT and Luigi

![ELT Design](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/assets/elt_pipeline_design_for_pactravel.png)

Hi there! Welcome to my learning logs.

**In this guide, I will share how I developed an ELT pipeline based on a designed dimensional model for an online travel agent (OTA) business , using a case study.**.

For the full story about the case study and how I designed the data warehouse, you can check out my article on Medium here: [full-story](https://medium.com/@ricofebrian731/learning-data-engineering-designing-a-data-warehouse-and-implementing-an-elt-with-dbt-and-luigi-404f357ef36c).

---
---

# Objective

**In this repository, I’ll focus specifically on how I developed the ELT pipeline, including:**

- Developing the ELT script
  
- Managing data transformations with DBT

- Orchestrating the pipeline with Luigi

- Automating the pipeline with Cron

---
---

# Pipeline Workflow

Before diving into the main discussion, take a look at the image below. This illustrates the workflow I followed to build this project.

![Pipeline workflow]()


- ## How the pipeline works

  - ### Extract Task
    The Extract task pulls raw data from the source database and saves it as CSV files. The output of this task is a set of CSV files containing raw data for each table from the source database.
  
  - ### Load Task
    The Load task takes the extracted data (CSV files) and loads it into two schemas in the warehouse database:
  
    - **Public Schema**: Stores the raw data exactly as it came from the source database.
  
    - **Staging Schema**: A processed version of the raw data from the public schema. In this schema, I set up a configuration to handle new or updated data from the source database and make sure there are no duplicates or conflicts.

- ## What’s the difference between the public and staging schemas?

  - The public schema is like a storage space for raw data, keeping an exact copy of what’s in the source database.

  - While the staging schema is like a “waiting room” for data. A temporary space where the data is cleaned and prepared before transformed and load it into a final schema. It ensures the data is accurate and ready for further processing

- ## Why use this workflow?

  This workflow ensures the pipeline remains reliable and well-organized. Some key benefits include:

  - **Raw Data Backup (Archive)**: The public schema keeps a backup of the original data in case it’s needed later.

  - **Flexibility for Downstream Users**: Different users can access data in its raw or processed form, depending on their needs.

  - **Protecting Source Data**: The pipeline reduces the risk of direct access to the source database, preventing unintentional changes.

  - **Preparation for Transformation**: The staging schema acts as a cleaning area, ensuring the data is conflict-free and ready for transformations.

---
---

# Dataset Overview

I used a dataset related to an online travel agent business. You can clone this repository to access the full dataset: [pactravel-dataset](https://github.com/Kurikulum-Sekolah-Pacmann/pactravel-dataset)

---
---

Before starting, take a look at the requirements and preparations below:

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

- ## Get the dataset

  Clone or download this repository to get the populated data for the source database.

  ```
  git lfs clone git@github.com:Kurikulum-Sekolah-Pacmann/pactravel-dataset.git
  ```

---

- ## Setup project environment

  Create and activate python environment to isolate project dependencies.
  
  ```
  python -m venv your_project_name         
  source your_project_name/bin/activate    # On Windows: your_project_name\Scripts\activate
  ```

---
  
- ## Set up the directory structure

  Set up your project directory structure to organize all project scripts.
  
  ```
  project/
  ├── helper/ ----------------- # To store SQL script to create db schema
  │   ├── dwh_schema/
  │   └── src_schema/
  ├── logs/ ------------------- # To store pipeline logs
  ├── pipeline/ --------------- # To store pipeline dependencies and develop the scripts 
  │   ├── elt_query/
  │   ├── utils_function/
  │   └── elt_dev_script.py
  ├── temp/ ------------------- # To store temporary data from ELT task 
  │   ├── data
  │   └── log
  │ --------------------------- # Root project to store the main scripts
  │ 
  ├── .env
  ├── main_pipeline.py 
  ├── pipeline.sh
  ├── docker-compose.yml
  └── requirements.txt
  ```

---

- ## Install _requirements.txt_**
  
  Install the dependencies from _requirements.txt_ in the created environment.
  
  ```
  pip install -r requirements.txt
  ```
  
> [!Note]
> You can install libraries as needed while developing the code. However, once completed, make sure to generate a requirements.txt file that lists all dependencies.

---

- ## Create _.env_ file

  Create .env file to store all credential information.
  
  ```
  touch .env
  ```

---

- ## Setup database
    
    - ### Create SQL queries

      **These queries are used to set up the schemas, tables, and their constraints _based on the data warehouse design_.**

      You can view the complete data warehouse design for this project in my Medium article: [Data Warehouse Design](https://medium.com/@ricofebrian731/learning-data-engineering-designing-a-data-warehouse-and-implementing-an-elt-with-dbt-and-luigi-404f357ef36c)

      - Source database
          
          - [Populated data source](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/helper/src_data/init.sql)

      - Warehouse database
          
          - [Public schema](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/helper/dwh_data/dwh-public_schema.sql)
          
          - [Staging schema](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/helper/dwh_data/dwh-staging_schema.sql)
          
          - [Final schema](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/helper/dwh_data/dwh-final_schema.sql)
          
          - [Snapshot schema](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/helper/dwh_data/dwh-snapshot_schema.sql)


    - ### Create and run a Docker Compose
    
      Create [_docker-compose.yml_](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/docker-compose.yaml) file to set up both the data source and data warehouse databases.
  
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

  - ### Connect the database to Dbeaver
    
    - Click **Database** > select **New Database Connection**

    - Select postgreSQL

    - Fill in the port, database, username, and password **as defined in your _.env_**

    - Click **Test Connection**

    - If no errors appear, the database connection is successful   

---

- ## Create utility functions

  **This utility function acts like a basic tool you can use repeatedly when building the pipeline script.**

  -  [Database connector](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/utils_function/db_connector.py)
      -  Function to connect python and the database    
  
  -  [Read SQL file](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/utils_function/read_sql.py)
      -  Function to read the SQL query files and return it as string so python can run it 
  
  - [Concat DataFrame summary - Optional](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/utils_function/concat_df.py)
      - Function to merge the summary data from ELT pipeline

  - [Copy log - Optional](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/utils_function/copy_log.py)
      - Function to copy temporary log into main log

  - [Delete temporary data - Optional](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/utils_function/delete_temp_data.py)
      - Function to delete all temporary data from ELT pipeline 

---

- ## Set up Sentry for alerting

  Set up a Sentry project to receive an e-mail notifications in case of any errors in the pipeline.

  - Open and signup to: [Sentry](https://www.sentry.io)
    
  - Create Project :

    - Select Platform : Python

    - Set Alert frequency : `On every new issue`

    - Create project name.

  - After create the project, **store the SENTRY DSN project key into the .env file**

---

> [!NOTE]
> Ensure that the required tools and packages are installed and the preparations are set up before starting the implementation!

---
---

Alright, let's get started!

# Developing The ELT Scripts
      
- ## Create EXTRACT and LOAD queries

  **These queries are used to extract and load data from the source database into the public and staging schemas in the warehouse database.**

  - [Extract query](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/tree/main/pipeline/src_query/extract)
    - This query used to:
      - Extract data from source database into data warehouse's public schema
  
  - [Load queries](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/tree/main/pipeline/src_query/load)
    - This query used to:
      - Load data from public to staging schema
      - Handle updated data in each table within staging schema

---

- ## Managing data transformations with DBT
  
    - ### Setup DBT
        
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
          After initiating the project, a new directory will be created in your root project directory, like this: [dbt directory](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/tree/main/pactravel_dbt)

      - Set the materialization strategy and timezone

        Update your dbt_project.yml file inside the DBT project directory to look like this: [dbt_project.yml](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pactravel_dbt/dbt_project.yml)
  
      - Set up the required packages

        Create a packages.yml file inside your DBT project directory and define the required packages: [packages.yml](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pactravel_dbt/packages.yml)

    - ### Build staging layer model
        
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
          
          **Create the source configuration first**, as it is used to reference the selected schema in your data warehouse. Check here for the [complete staging layer models](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/tree/main/pactravel_dbt/models/staging)

        - Create a date/time dimension using a seed file
    
            - Download the date dimension CSV file here: [dim_date.csv](https://drive.google.com/file/d/1D1HVjFBHotwC4cWSxBebZTBb62aMQs6d/view)
    
            - Place the file in the **seeds** directory of your DBT project
          
          You can also create the date/time dimension using dbt packages.
    
    - ### Build marts layer model
      
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
     
          **The core models configuration is used to create constraints and perform data quality testing.** Check here for the [complete marts layer models](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/tree/main/pactravel_dbt/models/marts/core)

    - ### Create Snapshot

      In this project, I used DBT snapshots **to track and store data changes over time**. These snapshots are based on the **Slowly Changing Dimension (SCD) strategy** defined during the data warehouse design. Check here for the [complete snapshot configuration](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/tree/main/pactravel_dbt/snapshots)

    - ### Test the DBT model

      After building the DBT model, you can test it by running the following DBT commands:

      ```
      dbt debug    # Checks the database connection and the current DBT environment
      ```

      ```
      dbt deps     # Install the DBT packages specified
      ```

      Then, **run these commands sequentially** to compile all the models:

      ```
      dbt seed     # loads the specified CSV files into your data warehouse
      ```
        
      ```
      dbt run      # Compiles all models and loads them into your data warehouse
      ```
        
      ```
      dbt test     # Runs tests and creates the constraints in your models
      ```

---
---
        
- ## Create ELT pipeline task

  **I developed each task separately to ensure everything functions properly.**

  - ### [EXTRACT Task](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/extract.py)
      
      - This task will pull data from the source database and save it into a CSV file.
      
      - Task outputs include:
          
          - CSV files for each extracted table
          - Task summary CSV
          - Log file

  - ### [LOAD Task](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/load.py)
      
      - This task reads data from each CSV file generated by the Extract task and loads it into the public and staging schemas in the warehouse database.
      
      - Task outputs include:
          
          - Task summary CSV     
          - Log file
    
  - ### [TRANSFORM Task](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline/transform.py)

      - This task executes a shell script to perform data transformations using DBT by converting DBT commands into a Python script.
      
      - This outputs include:
      
          - Task summary CSV
          - Log file
---

**For each task, I also set up logging and error handling to assist with debugging and resolving issues.**
  
  - ### Setting up logging & error handling
      
    ```
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
     
    ```
    # Create a summary of the task execution 
  
    # Define a summary
    summary_data = {
      'timestamp': [datetime.now()],
      'task': ['<CHANGE WITH YOUR TASK NAME>'],
      'status' : ['Success/Failed'],
      'execution_time': [execution_time]
    }
  
    # Convert the summary into DataFrames
    summary = pd.DataFrame(summary_data)
  
    # Convert and save DataFrame to CSV
    summary.to_csv(f"{YOUR TEMPORARY DATA DIRECTORY}/<YOUR SUMMARY FILENAME>", index = False)
    ```
  
---
---

# Orchestrating the pipeline with Luigi

> [!CAUTION]
>
> Luigi has some limitations you should be aware of when using it for data orchestration, such as:
>
> - History Task Retention (only 15 minutes by default)
> - Idempotency Requirement
> - No Built-in Scheduler
>
> For a detailed explanation, you can check the documentation: [Luigi Limitations](https://luigi.readthedocs.io/en/stable/design_and_limitations.html)

- ## Compile all task

  Compile all task into a single main script, like this: [main_elt_pipeline.py](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/main_elt_pipeline.py)

- ## Run the ELT pipeline

  Run the main script to test the pipeline end-to-end

  ```
  python3 YOUR_MAIN_PIPELINE_NAME.py
  ```

  **When developing the script, you can run Luigi tasks separately or execute all of them at once**
  ```
  # Running Tasks Separately

  # In your task script, run this:
  if __name__ == '__main__':
      luigi.build(<TASK NAME>()])
  ```

  ```
  # In your final task script, run this:
  if __name__ == '__main__':
      luigi.build([<TASK A>(),
                   <TASK B>(),
                   ..........
                   <UNTIL YOUR LAST TASK>()])
  ```

- ## Verify all outputs

  If your pipeline runs successfully, you can verify the output in DBeaver by checking the warehouse databas

- ## Monitoring log and task summary

  You can easily check and review the log files and summaries created in each task for any errors in your pipeline during development

  - Check the full logs here: [logs](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/tree/main/logs)

  - Check the full task summary here: [full_summary](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/pipeline_summary.csv)

---
---

# Automating the pipeline with Cron

Since Luigi doesn't have a built-in scheduler, you can automate the pipeline using Cron

- ## Set up schedulers
    
    - ### Create a cron job to automate pipeline execution.
  
      - Create shell script [elt_pipeline.sh](https://github.com/Rico-febrian/elt-dwh-for-online-travel-agent-business/blob/main/elt_pipeline.sh)
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

        Or you can run the shell script manually

        ```
        ./SHELL_SCRIPT_NAME.sh
        ```
  
---
---
  
# Performing tests on the Data Warehouse

After the Data Warehouse and ELT pipeline were successfully running, I conducted several test queries **to ensure the Data Warehouse could address the stakeholders' needs**. These queries were based on high-priority business metrics. Below are the queries and their results:

- ## Revenue and total bookings metrics
    
    - ### Total daily revenue and booking details
      ![Metric 1](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/metric_1.png)
       
- ## Average ticket price over time metrics
    
    - ### Average flight ticket price yearly
      ![Metric 2](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/metric_2.png)
    
    - ### Average hotel price yearly
      ![Metric 3](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/metric_3.png)

---
---

# Final Result

- ## Data Warehouse Lineage Graph
  ![DWH Lineage Graph](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/dbt_lineage_graph.png)

- ## Luigi DAG Graph
  ![Luigi DAG Graph](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/luigi_dag_graph.png)

- ## Pipeline Summary
  ![Pipeline Summary](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/success_summary.png)

- ## Pipeline Log
  ![Main Log](https://github.com/Rico-febrian/elt-dwh-for-online-travel-booking-business/blob/main/assets/success_log.png)

---
---

# Conclusion

Well, you’ve reached the end of this guide. In summary, I’ve shared my learning journey in data engineering, focusing on designing a dimensional model for a Data Warehouse and implementing the ELT process with DBT, orchestrated by Luigi, based on a case study in the online travel agent (OTA) business. 

**For the full article about this project you can check out my article on Medium here:** [full-story]().

Thank you for joining me on this learning experience. I hope you’ve gained valuable insights that will help you in your own data engineering journey. If you have any questions or need additional information, feel free to reach out. I’m open to any feedback or suggestions you may have.

**You can connect with me on:** 

- [My LinkedIn](www.linkedin.com/in/ricofebrian)
- [My Medium](https://medium.com/@ricofebrian731)
