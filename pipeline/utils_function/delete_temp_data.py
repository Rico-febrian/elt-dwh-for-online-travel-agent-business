import os

def delete_temp(directory):
    """
    This function use to delete all temporary data/files from ELT pipeline

    Parameter:
        directory: path to the temporary data has been saved
    """
    try:
        
        # List all temporary data in the directory
        files = os.listdir(directory)
        
        # Iterate and delete each files
        for file in files:
            
            # Join temporary data path with file name
            file_path = os.path.join(directory, file)
            
            # Delete all files
            if os.path.isfile(file_path):
                os.remove(file_path)
                
    except Exception as e:
        print(f'An error occured: {e}')
