import requests
import pandas as pd
from google.oauth2 import service_account
import pandas_gbq
import google.cloud.bigquery

def getItemQuantities(tenant_token, user_token, endpoint):
  pages = []
  ## payload can handle max PageSize of 10,000 skus
  payload = {
      "ModifiedAfterDateTimeUtc": "Beginning of time.",
      "ModifiedBeforeDateTimeUtc": "Now.",
      "PageNumber": 0,
      "PageSize": 10000,
      "TenantToken": tenant_token,
      "UserToken": user_token
  }

  headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
  }

  r = requests.post(endpoint, json=payload, headers=headers)

  page = r.json()["Items"]

  pages.append(page)

  num_skus = len(page)

  ## keep increasing the payload pageNumber until it returns a page with 0 results
  while num_skus > 0:
    payload["PageNumber"] += 1
    r = requests.post(endpoint, json=payload, headers=headers)
    page = r.json()["Items"]
    num_skus = len(page)
    if num_skus > 0:
      pages.append(page)

  skus_quantities = pd.DataFrame()

  for page in pages:
    df = pd.json_normalize(page)
    skus_quantities = pd.concat([skus_quantities, df], ignore_index=True)

  ## Add TimeStamp column in tz US/Pacific (-08:00) for time of data pull
  ### In BigQuery, this is actual UTC time
  skus_quantities.insert(0, 'TimeStamp', pd.to_datetime('now', utc=True).replace(microsecond=0).tz_convert('US/Pacific'))
  
  ## Add Datetime (local time) column
  ### In BigQuery this is Pacific time with a false UTC timezone for writing queries without haveing to convert timezones
  ### Google BigQuery would not allow for DATETIME upload in this format, only TIMESTAMP which is always UTC
  skus_quantities.insert(1, 'DateTimeLocal', pd.to_datetime('now', utc=True, format="%Y-%m-%dT%H:%M:%S.%f").replace(microsecond=0).tz_convert('US/Pacific').replace(tzinfo=None))

  ## Convert LastModifiedDateTimeUtc to tz Us/Pacific (-8:00) as well
  ## skus_quantities['LastModifiedDateTimeUtc'] = pd.DatetimeIndex(pd.to_datetime(skus_quantities['LastModifiedDateTimeUtc'], format="%Y-%m-%dT%H:%M:%S.%f", errors='coerce')).tz_convert('US/Pacific')
  del skus_quantities["LastModifiedDateTimeUtc"]

  ## skus_quantities.describe()
  ## skus_quantities.info()

  return skus_quantities

def main(context, data):
    tenant_token = '[TENANT_TOKEN]'
    user_token = '[USER_TOKEN]'
    endpoint = 'https://app.skuvault.com/api/inventory/getItemQuantities'
    
    res = getItemQuantities(tenant_token, user_token, endpoint)

    credentials = service_account.Credentials.from_service_account_info(
        {
        "type": "service_account",
        "project_id": "alain-dupetit",
        "private_key_id": "[PRIVATE_KEY_ID]",
        "private_key": "-----BEGIN PRIVATE KEY-----\[PRIVATE_KEY]\n-----END PRIVATE KEY-----\n",
        "client_email": "data-import@alain-dupetit.iam.gserviceaccount.com",
        "client_id": "[CLIENT_ID]",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/data-import%40alain-dupetit.iam.gserviceaccount.com"
        }
    )

    table_id = 'alain-dupetit.inventory.daily_inventory'
    project_id = 'alain-dupetit'

    pandas_gbq.to_gbq(res, table_id, project_id=project_id, if_exists='append', credentials=credentials)