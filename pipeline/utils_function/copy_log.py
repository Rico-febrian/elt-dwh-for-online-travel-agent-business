def copy_log(source_log, destination_log):
    """
    This function use to copy the temporary log to the main log in root directory

    Parameters:
        - source_log: path to the temporary log 
        - destination_file: path to the main log

    Returns:
        - Updated main log
    """
    try:
        with open(source_log, 'r') as temp_log:
            with open(destination_log, 'a') as main_log:
                
                # Read the temporary log and write it to the main log
                main_log.write(temp_log.read())
                
    except Exception as e:
        print(f"An error occurred: {e}")