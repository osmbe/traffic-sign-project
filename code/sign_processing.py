import numpy as np
import pandas as pd
import pyproj
from pandas_geojson import to_geojson, write_geojson
from pyproj import Transformer
import maproulette
import json
import logging

traffic_signs_info = "./find-interesting-signs/road_signs_cleaned.csv"

logger = logging.getLogger(__name__)
transformer = Transformer.from_crs("epsg:31370", "epsg:4326", always_xy=True)

def convertCoords(row):
    # Transform columns based on locatie_x (longitude) and locatie_y (latitude).
    longitude ,latitude = transformer.transform(row['locatie_x'],row['locatie_y'])
    return pd.Series({'longitude': longitude,'latitude': latitude})

def extract_new_signs(feature_file, process_date):
  feature_df = pd.read_csv(feature_file)
  logger.info("%s contains %d features", feature_file, len(feature_df))
  feature_df['date'] = pd.to_datetime(feature_df['datum_plaatsing'], errors = 'coerce', format='%d/%m/%Y')
  filter_mask = feature_df['date'].notna() \
      & (feature_df["date"] > process_date) \
      & (feature_df['date'] < (pd.Timestamp.today() + pd.Timedelta('1D')))
  filtered_df = feature_df[filter_mask].reset_index(drop=True)
  logger.info("%d features after filtering by date greater than %s.", len(filtered_df), process_date)
  if filtered_df.empty:
    return filtered_df
  # Convert coordinates
  filtered_df[['longitude','latitude']] = filtered_df.apply(convertCoords,axis=1)
  # Update parameters to add zone if the sign code starts with Z.
  filtered_df['parameters'] = filtered_df.apply(lambda row: f"zone,{row['parameters']}" if row['bordcode'].startswith('Z') else row['parameters'], axis=1)
  # Removed Z if the bordcode starts with a Z, remove all /s and store it in traffic_sign_code column.
  filtered_df['traffic_sign_code'] = filtered_df.apply(lambda row: (f"{row['bordcode'][1:]}" if row['bordcode'].startswith('Z') else row['bordcode']).replace("/", ""), axis=1)
  # Replace strings from FID
  filtered_df['id'] = filtered_df['FID'].str.replace('Verkeersborden.Vlaanderen_Borden.','')
  filtered_df.drop(columns=['FID'])
  sign_metadata = pd.read_csv(traffic_signs_info, sep=";", encoding = "ISO-8859-1")
  # Rename bordcode to traffic_sign_code.
  sign_metadata = sign_metadata.rename(columns={"bordcode": "traffic_sign_code"})
  # Join both datasets by the traffic_sign_code doing a left join.
  joined_df = filtered_df.merge(sign_metadata, on='traffic_sign_code', how='left')
  # Remove NaN parameters and name
  joined_df[['parameters', 'name']] = joined_df[['parameters','name']].fillna('')
  # Group the features by pole identifier.
  grouped_df = joined_df.groupby('id_aanzicht', as_index=False).agg({
     'opinion': 'max', 
     'traffic_sign_code': ' | '.join,
     'latitude': 'max',
     'longitude': 'max',
     'parameters': lambda x : '|'.join(y for y in x if y != ''),
     'name': lambda x : '|'.join(y for y in x if y != ''),
     'datum_plaatsing': 'max',
     'id': 'max'})
  grouped_df = grouped_df[grouped_df['opinion'] > 0]
  logger.debug("Found %d signs after grouping by pole identifier.", len(grouped_df))
  # Rename columns as per the geojson requirements
  return grouped_df.rename(columns = {
    "parameters": "extra_text",
    "datum_plaatsing": "date_installed",
    "name": "traffic_sign_description"
  })[['id', 'traffic_sign_code', 'extra_text', 'traffic_sign_description', 'date_installed', 'longitude', 'latitude']]

def save_geojson(signs_df, geojson_file):
  logger.info("Store signs data frame to geojson file %s", geojson_file)
  geo_json = to_geojson(df=signs_df, lat='latitude', lon='longitude',
                 properties=['id','traffic_sign_code','extra_text','traffic_sign_description', 'date_installed' ])
  write_geojson(geo_json, filename=geojson_file) 

def upload_to_maproulette(api_key, challenge_id, geojson_file):
  logger.info("Uploading geojson content to maproulette challenge %s", challenge_id)
  # Create a configuration object for MapRoulette using your API key:
  config = maproulette.Configuration(api_key=api_key)
  # Create an API objects with the above config object:
  api = maproulette.Challenge(config)
  # Provide a GeoJSON of the task data:
  with open(geojson_file, "r") as data_file:
      data = json.loads(data_file.read())
  # Printing response:
  logger.info("Server response: %s", json.dumps(api.add_tasks_to_challenge(data, challenge_id)))
