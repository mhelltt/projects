# projects

## [BigQuery Daily Inventory](https://github.com/mhelltt/projects/tree/main/BigQuery%20Daily%20Inventory)

This is a simple data pipeline that I created for an e-commerce company. The goal was to load end-of-day inventory records with timestamps from our warehouse management system (WMS) into a Google BigQuery table with timestamps because our WMS did not have historical inventory snapshot functionality.

To achieve this as cost effectively as possible (nearly free), I used Google Cloud Scheduler to run a cron job every night that would trigger a Pub/Sub link to run a python script on Google Cloud Functions. The python script pulls JSON data from our Warhouse Management System via REST API, parses it, transforms it, timestamps it, and uploads into a Google BigQuery table using a Google servie account.

This Google BigQuery table has been used for end-of-month accounting, ad-hoc inventory analysis, and sales data analysis.


![workflow graphic](https://github.com/mhelltt/projects/blob/main/BigQuery%20Daily%20Inventory/workflow.png)

## [Google Data Analytics Capstone](https://github.com/mhelltt/projects/tree/main/Google%20Data%20Analytics%20Capstone)

This R notebook was written to complete the Google Data Analytics Certificate Capstone Project. A FitBit dataset was provided, along with a couple hypothetical business tasks for a fictional company called "Bellabeats".

The final notebook with output and graphics can be viewed on kaggle:
https://www.kaggle.com/code/mhelltt/google-data-analytics-case-study
