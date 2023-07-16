from datetime import datetime, timedelta
import numpy as np
from os import environ

def get_process_date():
  date_format = '%Y-%m-%d'
  if environ.get('LAST_PROCESSED_DATE'):
    return np.datetime64(datetime.strptime(environ.get('LAST_PROCESSED_DATE'), date_format).date())
  return get_first_day_previous_month()

def get_first_day_current_month():
  return np.datetime64(datetime.today().replace(day=1).date())

def get_first_day_previous_month():
  last_day_previous_month = datetime.today().replace(day=1) - timedelta(days=1)
  return np.datetime64(last_day_previous_month.replace(day=1).date())
