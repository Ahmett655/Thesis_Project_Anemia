"""
Final production model: XGBoost + SMOTE
=======================================
The 8-model comparison showed XGBoost is the strongest classifier. The dataset
is imbalanced (Severe = 404 vs Mild/Moderate in the thousands), so we apply
SMOTE to the TRAINING set only (never the test set) to improve Severe recall,
then train XGBoost and save it in the format the Flask API expects:
  anemia_model.pkl, label_encoder.pkl, model_columns.pkl

It also prints a before/after comparison so the thesis can show the effect of
SMOTE on the minority (Severe) class.

Run:  python train_final_xgboost_smote.py
"""

import os
import shutil

import joblib
import pandas as pd
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    recall_score,
    classification_report,
)
from xgboost import XGBClassifier

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "anemia_master_clean.csv")
# Where the Flask API loads its model from:
FLASK_DIR = r"C:/Users/BEC/Desktop/anemia_api"
RANDOM_STATE = 42


def load():
    df = pd.read_csv(DATA)
    if "Anemia level.1" in df.columns:
        df = df.drop(columns=["Anemia level.1"])
    df = df.dropna(subset=["Anemia level"])
    X = pd.get_dummies(df.drop("Anemia level", axis=1)).fillna(0)
    le = LabelEncoder()
    y = le.fit_transform(df["Anemia level"])
    return X, y, le


def train_xgb(X_train, y_train):
    m = XGBClassifier(
        random_state=RANDOM_STATE,
        eval_metric="mlogloss",
        n_estimators=300,
        max_depth=6,
        learning_rate=0.1,
        verbosity=0,
    )
    m.fit(X_train, y_train)
    return m


def report(tag, model, X_test, y_test, classes):
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    f1m = f1_score(y_test, y_pred, average="macro", zero_division=0)
    # Severe is the last class alphabetically (Mild, Moderate, Severe) -> index 2
    severe_idx = list(classes).index("Severe")
    rec = recall_score(y_test, y_pred, average=None, zero_division=0)[severe_idx]
    print(f"\n[{tag}] accuracy={acc:.4f}  macro-F1={f1m:.4f}  "
          f"Severe recall={rec:.4f}")
    print(classification_report(y_test, y_pred, target_names=classes,
                                zero_division=0))
    return acc, f1m, rec


def main():
    X, y, le = load()
    classes = list(le.classes_)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_STATE
    )
    print(f"Dataset: {X.shape[0]} x {X.shape[1]} | classes: {classes}")
    print(f"Train class counts: {dict(pd.Series(y_train).value_counts())}")

    # ---- Baseline: XGBoost WITHOUT SMOTE ----
    base = train_xgb(X_train, y_train)
    report("XGBoost (no SMOTE)", base, X_test, y_test, classes)

    # ---- SMOTE on training set only ----
    sm = SMOTE(random_state=RANDOM_STATE)
    X_res, y_res = sm.fit_resample(X_train, y_train)
    print(f"\nAfter SMOTE, train class counts: "
          f"{dict(pd.Series(y_res).value_counts())}")

    final = train_xgb(X_res, y_res)
    report("XGBoost + SMOTE", final, X_test, y_test, classes)

    # ---- Save the SMOTE model in the Flask format ----
    for d in (HERE, FLASK_DIR):
        os.makedirs(d, exist_ok=True)
        joblib.dump(final, os.path.join(d, "anemia_model.pkl"))
        joblib.dump(le, os.path.join(d, "label_encoder.pkl"))
        joblib.dump(list(X.columns), os.path.join(d, "model_columns.pkl"))
    print(f"\nSaved XGBoost+SMOTE model to:\n  {HERE}\n  {FLASK_DIR}")


if __name__ == "__main__":
    main()
