# Test MySQL Connection and List All Tables in retail_db

import mysql.connector

# 1️⃣ Connection to MySQL database
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root123",
    database="retail_db"
)
cursor = conn.cursor()

# 2️⃣ Test database connection
cursor.execute("SELECT DATABASE();")
print("Database:", cursor.fetchone())

# 3️⃣ List all tables from information_schema
cursor.execute("""
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema='retail_db';
""")
tables = cursor.fetchall()
print("Tables:", tables)

# 4️⃣ Close connection after all operations
cursor.close()
conn.close()


# Load Customer Features from MySQL into Pandas DataFrame

import pandas as pd
from sqlalchemy import create_engine

# Create SQLAlchemy engine for MySQL
engine = create_engine("mysql+pymysql://root:root123@localhost/retail_db")

# Read table directly into a DataFrame
df = pd.read_sql("SELECT * FROM ml_customer_features;", engine)
print(df.head())


# Data Quality Check: Info, Missing Values, and Preview
print(df.info())
print(df.isnull().sum())
print(df.head())


# Feature Scaling: Standardize Numerical Columns

numerical_cols = ['total_orders', 'total_amount', 'avg_rating']
categorical_cols = ['gender', 'frequency', 'city']
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
df[numerical_cols] = scaler.fit_transform(df[numerical_cols]) 
print(df[numerical_cols])

# One-Hot Encoding: Convert Categorical Variables to Numerical
df_encoded = pd.get_dummies(
    df, 
    columns = categorical_cols, 
    drop_first=True,
    dtype=int
)
df_encoded


# Split Features and Target Variable for Machine Learning
X = df_encoded.drop(columns=['subscription_status'])
y = df_encoded['subscription_status']


# Encode Target Variable: Convert Subscription Status to Numerical Labels
from sklearn.preprocessing import LabelEncoder
le = LabelEncoder()
y = le.fit_transform(y)


# Train-Test Split: Divide Data into Training and Testing Sets
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# Train Random Forest Model for Subscription Prediction
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier(
    n_estimators=200,
    random_state=42
)
model.fit(X_train, y_train)




