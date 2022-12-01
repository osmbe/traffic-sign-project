import logging
import os
from fetch_signs import fetch_all_features_by_type
from utils import get_first_day_current_month
from sign_processing import extract_new_signs, save_geojson, upload_to_maproulette

logging.basicConfig(format='%(asctime)s | %(levelname)s: %(message)s', level=logging.NOTSET)

wfs_url = 'https://opendata.apps.mow.vlaanderen.be/opendata-geoserver/awv/wfs'
feature_type = "awv:Verkeersborden.Vlaanderen_Borden"
feature_file = "./python_output/feature_output.csv"
geojson_file = "./python_output/geojson_output.json"
maproulette_api_key = os.environ.get("API_KEY")
challenge_id = os.environ['CHALLENGE_ID']

if __name__== "__main__":
  process_date = get_first_day_current_month()
  logging.info("Processing new features after %s, updates will be published to challenge %d", process_date, challenge_id)
  fetch_all_features_by_type(wfs_url, feature_file, feature_type)
  signs_dataframe = extract_new_signs(feature_file, process_date)
  if signs_dataframe.empty:
    logging.info("No new features found.")
  else:
    save_geojson(signs_dataframe, geojson_file)
    upload_to_maproulette(maproulette_api_key, challenge_id, geojson_file)