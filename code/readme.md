# Downloading the traffic signs

## Anaconda

### The main processing is in a Jupyter Notebook, which we use within the Anaconda environment.

### Set up virtual environment (based on instructions found at https://www.geeksforgeeks.org/set-up-virtual-environment-for-python-using-anaconda/)
### Open Anaconda prompt (CMD.exe prompt)
conda create -n trafficsignproject python=3.8 anaconda
### Check success
conda info -e
### Activate
conda activate trafficsignproject

### Installations
conda install -n trafficsignproject certifi==2021.10.8 certifi==2021.10.8 charset-normalizer==2.0.11 idna==3.3 OWSLib==0.25.0 pyproj==3.3.0 python-dateutil==2.8.2 pytz==2021.3 PyYAML==6.0 requests==2.27.1 six==1.16.0 urllib3==1.26.8 owslib==0.24.1

### Use in Jupyter Notebooks
#### In Anaconda navigator, switch "applications on" to channel "trafficsignproject"
#### OR: open "Anaconda Prompt (trafficsignproject)", go to a directory above your data and launch jupyter notebook

### Deactivate
conda deactivate

### Delete
conda remove -n envname -all

## Standalone use

### For traditional command line use, follow instructions below

### create project dir
mkdir my_project

### goto dir
cd my_project

### create virtual environment:
python -m venv my_venv

### activate virtual environment
.\my_venv\Scripts\Activate.ps1

### install required libraries:
pip install -r .\requirements.txt

## Processing the data

The script "interesting signs.sps" was ran a single time to create a csv with the traffic sign code and it's meaning and importance to mapping in OSM.

Run the SPSS script "2 main processing.sps" to create a new CSV file for use in MapRoulette. Conversion to GeoJSON is requiered of course (and described in the script.