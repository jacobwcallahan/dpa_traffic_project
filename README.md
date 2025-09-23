# Traffic Crash Severity Prediction 🚗📊

[![Python](https://img.shields.io/badge/Python-3.10-blue.svg)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-orange.svg)](https://scikit-learn.org/stable/)
[![XGBoost](https://img.shields.io/badge/XGBoost-Gradient--Boosting-green.svg)](https://xgboost.readthedocs.io/)

## Overview
This project investigates the **determinants of traffic crash severity** in Illinois (2013–2022).  
We analyzed **297,000+ crash records** and built machine learning models to predict whether a crash results in **Fatal, Injury, or Property Damage** outcomes.

- Cleaned and engineered a dataset with 85 features (dropped/merged missing-heavy variables, imputed road class & flow conditions).
- Explored correlations between crash severity and environmental/road factors.
- Built and compared multiple machine learning models:  
  **Logistic Regression, Naive Bayes, Random Forest, SVM, XGBoost**.
- Achieved a **Weighted F1 Score of 0.877** with XGBoost — the best performing model.

📄 Full report: [`report/DPA Final Report.pdf`](report/DPA%20Final%20Report.pdf)

---

## Data
- **Source**: Illinois Department of Transportation crash data (2013–2022).  
- **Size**: ~297k crash records after preprocessing.  
- **Features**: time, location, weather, lighting, road surface, traffic control devices, crash causes, injuries/fatalities.  

Key preprocessing:
- Removed features with >90% missing or “(UNK)” values.
- Engineered **TimeOfDay** (Morning, Afternoon, Evening, Night).
- Consolidated primary/secondary crash causes.
- One-hot encoded categorical variables for modeling.

---

## Exploratory Data Analysis (EDA)
Some findings:
- Most crashes occurred on **clear days with dry surfaces**, showing that **traffic density & driver behavior** outweigh weather.
- Evening rush hour (3–7 PM) had the highest crash incidence.
- Fatal crashes were disproportionately frequent at **night** and under poor **lighting/road conditions**.

<p align="center">
  <img src="results/crashes_by_time.png" width="400">
  <img src="results/weather_conditions.png" width="400">
</p>

---

## Modeling
| Model                  | Macro F1 | Weighted F1 | Notes |
|------------------------|----------|-------------|-------|
| Logistic Regression    | 0.29     | 0.69        | Baseline, underfit |
| Naive Bayes            | 0.47     | 0.76        | Simple, interpretable |
| Random Forest          | 0.40     | 0.85        | Strong baseline |
| SVM                    | 0.37     | 0.75        | Struggled with scale |
| **XGBoost**            | **0.58** | **0.877**   | Best performing |

Feature importance (XGBoost):
- Weather condition
- Road surface condition
- Lighting condition
- Time of day
- Number of injuries

<p align="center">
  <img src="results/feature_importance.png" width="500">
</p>

---

## My Role
This was a **team project**, and my contributions included:
- **Data preprocessing**: handled missing values, engineered categorical features, consolidated causes.
- **Feature selection**: correlation analysis, chi-square tests, and regularization-based feature reduction.
- **Model training & evaluation**: implemented Random Forest and XGBoost, tuned hyperparameters.
- **Reporting**: authored analysis sections on feature engineering, correlation, and ensemble model performance.

---

## Tech Stack
- **Languages**: Python, R
- **Libraries**: pandas, NumPy, scikit-learn, XGBoost, matplotlib, seaborn
- **Tools**: Git, Jupyter Notebooks

---

## Results & Takeaways
- Predictive analytics can inform **road safety policy & interventions**.
- Ensemble models (XGBoost, Random Forest) outperform simpler baselines.
- Class imbalance (rare fatal crashes) remains a challenge; oversampling helps but does not fully solve it.

---

## Next Steps
- Apply **time-series modeling** for crash forecasting.
- Explore **geospatial clustering** of high-risk zones.
- Integrate **real-time traffic & weather feeds** for live prediction.

---

## Repository Structure
traffic-crash-severity-ml/
│── data/ # sample/synthetic data
│── notebooks/ # preprocessing, EDA, modeling
│── src/ # Python scripts
│── report/ # final report PDF
│── results/ # plots, confusion matrices
│── README.md # project overview
