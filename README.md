# projects

## [BigQuery Daily Inventory](https://github.com/mhelltt/projects/tree/main/big-query-daily-inventory)

This was a simple data pipeline that I created for a job at an e-commerce company where we needed to use end-of-day inventory, but our warehouse management system did not have historical inventory capablities.

To achieve this as cost effectively as possible (nearly free), I used Google Cloud to run a nightly cron job on their Cloud Scheduler that would trigger a Pub/Sub link to run a python script on Google Functions that would pull JSON data from our Warhouse Management System's API, parse it, transform it, timestamp it, and upload into Google BigQuery using a servie account so that I could run SQL queries on it when needed.

![workflow graphic]([https://github.com/mhelltt/projects/blob/main/big-query-daily-inventory/workflow.png](https://github.com/mhelltt/projects/blob/main/BigQuery%20Daily%20Inventory/workflow.png))

## [Google Data Analytics Capstone](https://github.com/mhelltt/projects/tree/main/Google%20Data%20Analytics%20Capstone)

This R notebook was written to complete the Google Data Analytics Certificate Capstone Project. A FitBit dataset was provided, along with a couple hypothetical business tasks for a fictional company called "Bellabeats".

The final notebook with output and graphics can be viewed on kaggle:
https://www.kaggle.com/code/mhelltt/google-data-analytics-case-study
