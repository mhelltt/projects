# BigQuery Daily Inventory Data Pipeline

This was a simple data pipeline that I created for a job at an e-commerce company where we needed to use end-of-day inventory, but our warehouse management system did not have historical inventory capablities.

To achieve this as cost effectively as possible (nearly free), I used Google Cloud to run a nightly cron job on their Cloud Scheduler that would trigger a Pub/Sub link to run a python script on Google Functions that would pull JSON data from our Warhouse Management System's API, parse it, transform it, timestamp it, and upload into Google BigQuery using a servie account so that I could run SQL queries on it when needed.

![workflow graphic](https://github.com/mhelltt/projects/blob/main/big-query-daily-inventory/workflow.png)

## Google Cloud Functions
Google Cloud Functions is a serverless execution environment for building and connecting cloud services.

In order to run when the pub/sub is triggered, Google Cloud Functions requires:
```
requirements.txt
main.py
```

## BigQuery Table Preview
![bigquery preview graphic](https://github.com/mhelltt/projects/blob/main/big-query-daily-inventory/bigquery-preview.png)
Note: 'Timestamp' is actual upload time in UTC, 'DateTimeLocal' is a Us/Pacific datetime equivalent that is not actually UTC, for ease of querying
