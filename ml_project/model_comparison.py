"""
Anemia Risk Classification — 8-Model Comparison
================================================
Trains and compares 8 machine-learning algorithms on the cleaned anemia
dataset, using the SAME preprocessing and train/test split as the original
single-model notebook (so results are directly comparable).

Outputs (written to ./comparison_results/):
  - model_comparison.csv         ranked metrics table
  - comparison_accuracy_f1.png   bar chart: accuracy vs macro-F1
  - confusion_matrices.png       3x3 grid of confusion matrices
  - per_class_f1.png             per-class F1 for the best model
  - best_model.pkl               the highest-scoring model (+ label_encoder, columns)
  - comparison_summary.txt       plain-text summary for the thesis

Run:  python model_comparison.py
"""

import os
import time
import warnings

import joblib
import numpy as np
import pandas as pd
import matplotlib

matplotlib.use("Agg")  # headless / no display
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report,
)

from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB
from sklearn.neural_network import MLPClassifier
from xgboost import XGBClassifier

warnings.filterwarnings("ignore")

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "anemia_master_clean.csv")
OUT = os.path.join(HERE, "comparison_results")
os.makedirs(OUT, exist_ok=True)

RANDOM_STATE = 42


# ----------------------------------------------------------------------
# 1) Load + preprocess (identical to the original notebook)
# ----------------------------------------------------------------------
def load_data():
    df = pd.read_csv(DATA)
    if "Anemia level.1" in df.columns:
        df = df.drop(columns=["Anemia level.1"])
    df = df.dropna(subset=["Anemia level"])

    X = df.drop("Anemia level", axis=1)
    y = df["Anemia level"]

    le = LabelEncoder()
    y = le.fit_transform(y)  # Mild=0, Moderate=1, Severe=2 (alphabetical)

    X = pd.get_dummies(X)
    X = X.fillna(0)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_STATE
    )
    return X, y, X_train, X_test, y_train, y_test, le


# ----------------------------------------------------------------------
# 2) The 8 models. Scale-sensitive models are wrapped in a StandardScaler
#    pipeline; tree/boosting/NB models are used directly.
# ----------------------------------------------------------------------
def build_models():
    return {
        "Random Forest": RandomForestClassifier(random_state=RANDOM_STATE),
        "XGBoost": XGBClassifier(
            random_state=RANDOM_STATE,
            eval_metric="mlogloss",
            n_estimators=200,
            verbosity=0,
        ),
        "Decision Tree": DecisionTreeClassifier(random_state=RANDOM_STATE),
        "Naive Bayes": GaussianNB(),
        "Logistic Regression": make_pipeline(
            StandardScaler(with_mean=False),
            LogisticRegression(max_iter=1000, random_state=RANDOM_STATE),
        ),
        "SVM": make_pipeline(
            StandardScaler(with_mean=False),
            SVC(random_state=RANDOM_STATE),
        ),
        "KNN": make_pipeline(
            StandardScaler(with_mean=False),
            KNeighborsClassifier(),
        ),
        "Neural Network (MLP)": make_pipeline(
            StandardScaler(with_mean=False),
            MLPClassifier(
                hidden_layer_sizes=(64, 32),
                max_iter=300,
                random_state=RANDOM_STATE,
            ),
        ),
    }


# ----------------------------------------------------------------------
# 3) Train + evaluate
# ----------------------------------------------------------------------
def main():
    print("Loading data...")
    X, y, X_train, X_test, y_train, y_test, le = load_data()
    classes = list(le.classes_)
    print(f"Dataset: {X.shape[0]} rows x {X.shape[1]} features | classes: {classes}")
    print(f"Train: {X_train.shape[0]} | Test: {X_test.shape[0]}\n")

    models = build_models()
    rows = []
    preds = {}

    for name, model in models.items():
        print(f"Training {name} ...", end=" ", flush=True)
        t0 = time.time()
        model.fit(X_train, y_train)
        train_s = time.time() - t0
        y_pred = model.predict(X_test)
        preds[name] = y_pred

        rows.append(
            {
                "Model": name,
                "Accuracy": accuracy_score(y_test, y_pred),
                "Precision (weighted)": precision_score(
                    y_test, y_pred, average="weighted", zero_division=0
                ),
                "Recall (weighted)": recall_score(
                    y_test, y_pred, average="weighted", zero_division=0
                ),
                "F1 (weighted)": f1_score(
                    y_test, y_pred, average="weighted", zero_division=0
                ),
                "F1 (macro)": f1_score(
                    y_test, y_pred, average="macro", zero_division=0
                ),
                "Train time (s)": round(train_s, 2),
            }
        )
        print(f"done in {train_s:.1f}s  (acc={rows[-1]['Accuracy']:.4f})")

    results = pd.DataFrame(rows).sort_values(
        "F1 (macro)", ascending=False
    ).reset_index(drop=True)
    results.insert(0, "Rank", range(1, len(results) + 1))

    # Save table
    csv_path = os.path.join(OUT, "model_comparison.csv")
    results.to_csv(csv_path, index=False)
    print("\n" + "=" * 70)
    print(results.to_string(index=False))
    print("=" * 70)

    best_name = results.iloc[0]["Model"]
    best_model = models[best_name]
    print(f"\nBest model (by macro-F1): {best_name}")

    # ------------------------------------------------------------------
    # 4) Charts
    # ------------------------------------------------------------------
    _chart_accuracy_f1(results)
    _chart_confusion_matrices(y_test, preds, classes)
    _chart_best_per_class_f1(y_test, preds[best_name], classes, best_name)

    # ------------------------------------------------------------------
    # 5) Save best model bundle (drop-in for the Flask API)
    # ------------------------------------------------------------------
    joblib.dump(best_model, os.path.join(OUT, "best_model.pkl"))
    joblib.dump(le, os.path.join(OUT, "label_encoder.pkl"))
    joblib.dump(list(X.columns), os.path.join(OUT, "model_columns.pkl"))

    # ------------------------------------------------------------------
    # 6) Text summary for the thesis
    # ------------------------------------------------------------------
    with open(os.path.join(OUT, "comparison_summary.txt"), "w", encoding="utf-8") as f:
        f.write("ANEMIA RISK CLASSIFICATION — 8-MODEL COMPARISON\n")
        f.write("=" * 55 + "\n\n")
        f.write(f"Dataset: {X.shape[0]} samples, {X.shape[1]} features\n")
        f.write(f"Classes: {classes}\n")
        f.write(f"Split: {X_train.shape[0]} train / {X_test.shape[0]} test "
                f"(80/20, random_state={RANDOM_STATE})\n\n")
        f.write(results.to_string(index=False))
        f.write(f"\n\nBest model (by macro-F1): {best_name}\n\n")
        f.write("Classification report (best model):\n")
        f.write(classification_report(
            y_test, preds[best_name], target_names=classes, zero_division=0))

    print(f"\nAll outputs saved to: {OUT}")


def _chart_accuracy_f1(results):
    fig, ax = plt.subplots(figsize=(11, 6))
    x = np.arange(len(results))
    w = 0.38
    ax.bar(x - w / 2, results["Accuracy"], w, label="Accuracy",
           color="#1565C0")
    ax.bar(x + w / 2, results["F1 (macro)"], w, label="F1 (macro)",
           color="#E53935")
    ax.set_xticks(x)
    ax.set_xticklabels(results["Model"], rotation=30, ha="right")
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("Score")
    ax.set_title("Model Comparison — Accuracy vs Macro-F1")
    ax.legend()
    for i, (a, fm) in enumerate(zip(results["Accuracy"], results["F1 (macro)"])):
        ax.text(i - w / 2, a + 0.01, f"{a:.2f}", ha="center", fontsize=8)
        ax.text(i + w / 2, fm + 0.01, f"{fm:.2f}", ha="center", fontsize=8)
    plt.tight_layout()
    plt.savefig(os.path.join(OUT, "comparison_accuracy_f1.png"), dpi=150)
    plt.close()


def _chart_confusion_matrices(y_test, preds, classes):
    n = len(preds)
    cols = 4
    rows = (n + cols - 1) // cols
    fig, axes = plt.subplots(rows, cols, figsize=(4 * cols, 3.4 * rows))
    axes = axes.flatten()
    for ax, (name, y_pred) in zip(axes, preds.items()):
        cm = confusion_matrix(y_test, y_pred)
        sns.heatmap(cm, annot=True, fmt="d", cmap="Blues", cbar=False,
                    xticklabels=classes, yticklabels=classes, ax=ax)
        ax.set_title(name, fontsize=10)
        ax.set_xlabel("Predicted")
        ax.set_ylabel("Actual")
    for ax in axes[n:]:
        ax.axis("off")
    plt.tight_layout()
    plt.savefig(os.path.join(OUT, "confusion_matrices.png"), dpi=150)
    plt.close()


def _chart_best_per_class_f1(y_test, y_pred, classes, best_name):
    f1s = f1_score(y_test, y_pred, average=None, zero_division=0)
    fig, ax = plt.subplots(figsize=(7, 5))
    colors = ["#26A69A", "#FFA726", "#E53935"][: len(classes)]
    ax.bar(classes, f1s, color=colors)
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("F1 score")
    ax.set_title(f"Per-Class F1 — {best_name}")
    for i, v in enumerate(f1s):
        ax.text(i, v + 0.01, f"{v:.2f}", ha="center")
    plt.tight_layout()
    plt.savefig(os.path.join(OUT, "per_class_f1.png"), dpi=150)
    plt.close()


if __name__ == "__main__":
    main()
