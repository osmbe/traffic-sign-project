import json
import requests
import pandas as pd
import logging

logger = logging.getLogger(__name__)

def _get_total_features_by_type(wfs_url, feature_type):
    response = requests.get(wfs_url, params={
     'service': 'WFS',
     'version': '2.0.0',
     'request': 'GetFeature',
     'typename': feature_type,
     'outputFormat': 'json',
     'count': 1
    })
    j = json.loads(response.content)
    return j['totalFeatures']

def _get_and_store_features(wfs_url, file_name, feature_type, max_features):
    response = requests.get(wfs_url, params={
     'service': 'WFS',
     'version': '2.0.0',
     'request': 'GetFeature',
     'typename': feature_type,
     'outputFormat': 'csv',
     'count': max_features
    })
    with open(file=file_name, encoding='UTF-8', mode='w', newline='') as csvfile:
        csvfile.write(response.content.decode('UTF-8'))

def fetch_all_features_by_type(wfs_url, feature_output_file, feature_type):
  pending_processing = True
  try_count = 0
  while pending_processing:
      try_count += 1
      total_features = _get_total_features_by_type(wfs_url, feature_type)
      logger.info("Starting fetching data from WFS service, total features %d and retry number %d.", total_features, try_count)
      _get_and_store_features(wfs_url, feature_output_file, feature_type, total_features)
      logger.info("WFS data stored in %d", feature_output_file)
      stored_features_df = pd.read_csv(feature_output_file)
      total_stored_features = len(stored_features_df.index)
      logger.debug("Stored %d features in the csv.", total_stored_features)
      pending_processing = total_stored_features < total_features