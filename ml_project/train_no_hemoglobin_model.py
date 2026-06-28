"""
No-Hemoglobin model (honest confidence when no lab value is given)
==================================================================
When the user does NOT provide a hemoglobin measurement, predicting with the
full model (which is dominated by the hemoglobin feature) produces misleading
99.9% confidence built on an imputed value. This script trains a SEPARATE
XGBoost+SMOTE model that never sees hemoglobin, so its confidence genuinely
reflects demographic/symptom-based uncertainty.

Saves (to ml_project AND the Flask api dir):
  anemia_model_nohb.pkl, model_columns_nohb.pkl   (label_encoder is shared)

Run:  python train_no_hemoglobin_model.py
"""

import os
import joblib
import pandas as pd
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score, classification_report
from xgboost import XGBClassifier

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "anemia_master_clean.csv")
FLASK_DIR = r"C:/Users/BEC/Desktop/anemia_api"
RANDOM_STATE = 42

HB_COLS = [
    "Hemoglobin level adjusted for altitude and smoking (g/dl - 1 decimal)",
    "Hemoglobin level adjusted for altitude (g/dl - 1 decimal)",
]


def main():
    df = pd.read_csv(DATA)
    if "Anemia level.1" in df.columns:
        df = df.drop(columns=["Anemia level.1"])
    df = df.dropna(subset=["Anemia level"])

    le = LabelEncoder()
    y = le.fit_transform(df["Anemia level"])
    X = pd.get_dummies(df.drop("Anemia level", axis=1)).fillna(0)

    # Drop the hemoglobin features entirely.
    drop = [c for c in HB_COLS if c in X.columns]
    X = X.drop(columns=drop)
    print(f"Dropped hemoglobin columns: {drop}")
    print(f"No-Hb feature count: {X.shape[1]}")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_STATE
    )

    X_res, y_res = SMOTE(random_state=RANDOM_STATE).fit_resample(X_train, y_train)
    model = XGBClassifier(
        random_state=RANDOM_STATE,
        eval_metric="mlogloss",
        n_estimators=300,
        max_depth=6,
        learning_rate=0.1,
        verbosity=0,
    )
    model.fit(X_res, y_res)

    y_pred = model.predict(X_test)
    print(f"\n[No-Hb model] accuracy={accuracy_score(y_test, y_pred):.4f}  "
          f"macro-F1={f1_score(y_test, y_pred, average='macro'):.4f}")
    print(classification_report(y_test, y_pred,
                                target_names=list(le.classes_), zero_division=0))

    # Typical confidence sanity check
    import numpy as np
    proba = model.predict_proba(X_test)
    print(f"Mean top-class confidence: {np.max(proba, axis=1).mean():.3f} "
          f"(full-Hb model is ~0.99 — this should be noticeably lower)")

    for d in (HERE, FLASK_DIR):
        joblib.dump(model, os.path.join(d, "anemia_model_nohb.pkl"))
        joblib.dump(list(X.columns), os.path.join(d, "model_columns_nohb.pkl"))
        joblib.dump(le, os.path.join(d, "label_encoder.pkl"))
    print(f"\nSaved no-Hb model to:\n  {HERE}\n  {FLASK_DIR}")


if __name__ == "__main__":
    main()
