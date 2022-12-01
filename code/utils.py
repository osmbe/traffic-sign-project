from datetime import datetime, timedelta
import numpy as np

def get_first_day_current_month():
  input_dt = datetime.today().date()
  day_num = input_dt.strftime("%d")
  result = input_dt - timedelta(days=int(day_num) - 1)
  return np.datetime64(result)

def get_first_day_previous_month():
  input_dt = datetime.today().date()
  result = (input_dt - timedelta(days=input_dt.day)).replace(day=1)
  return np.datetime64(result)
