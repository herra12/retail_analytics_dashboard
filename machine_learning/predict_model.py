# Make Predictions on Test Data
y_pred = model.predict(X_test) 

# Model Evaluation: Calculate Accuracy Score
from sklearn.metrics import accuracy_score
print("Accuracy :", accuracy_score(y_test, y_pred))

# Feature Importance Analysis: Identify Top Predictive Variables
import pandas as pd
feature_importance = pd.DataFrame({
    'feature': X.columns,
    'importance': model.feature_importances_
}).sort_values(by='importance', ascending=False)
feature_importance.head(10)

# Save Trained Model and Scaler for Future Use
import joblib
joblib.dump(model, "subscription_model.pkl")
joblib.dump(scaler, "scaler.pkl")


# Create Predictions DataFrame: Compare Predicted vs Actual Values
df_pred = X_test.copy()  
df_pred['subscription_pred'] = y_pred
df_pred['subscription_real'] = y_test  # ✅ correction ici

# Visualization: Compare Actual vs Predicted Subscription Status
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
plt.figure(figsize=(8,6))
sns.countplot(x='subscription_real', hue='subscription_pred', data=df_pred, palette='Set1')
plt.title("Comparaison des abonnements réels vs prédits")
plt.xlabel("Subscription Status Réel")
plt.ylabel("Nombre de clients")
plt.legend(title="Prédit")
plt.show()

# Confusion Matrix: Evaluate Classification Performance
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(6,4))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=model.classes_, yticklabels=model.classes_)
plt.xlabel("Prédit")
plt.ylabel("Réel")
plt.title("Matrice de confusion")
plt.show()


# Create Churn Flag: Identify At-Risk Customers Based on Spending
# Create a churn column
df['churn'] = df['total_amount'] < df['total_amount'].quantile(0.25)  # Bottom 25% of spenders = at risk
# Verification
print(df['churn'].value_counts())


