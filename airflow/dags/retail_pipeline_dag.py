"""Apache Airflow DAG used to automate the retail pipeline.
Pipeline steps:
1. Build features from raw data
2. Train the Machine Learning model
3. Predict customer subscription status (subscription_status)
This DAG enables automatic and reproducible workflow execution.
"""
