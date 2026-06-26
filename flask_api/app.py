from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd

app = Flask(__name__)
CORS(app)

model = joblib.load("anemia_model.pkl")
label_encoder = joblib.load("label_encoder.pkl")
model_columns = joblib.load("model_columns.pkl")


def map_frontend_to_model(data: dict) -> dict:
    """
    Convert raw frontend payload (e.g., {"age_group": "29-50", "education": "primary"})
    into the one-hot encoded format the model expects.

    All model columns start at 0. We then set 1 for the appropriate one-hot column
    based on user answers.
    """
    # Initialize all columns to 0
    row = {col: 0 for col in model_columns}

    category = (data.get("category") or "").lower()

    # ---------- AGE GROUP ----------
    # Frontend uses '18-29', '29-50', '50+' (adults) or '1-6', '6-12+' (children)
    # Model uses '15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49'
    age_group = (data.get("age_group") or "").strip()
    age_map_adults = {
        "18-29": "Age in 5-year groups_25-29",   # midpoint
        "29-50": "Age in 5-year groups_35-39",
        "50+":   "Age in 5-year groups_45-49",
    }
    if age_group in age_map_adults:
        col = age_map_adults[age_group]
        if col in row:
            row[col] = 1

    # ---------- TYPE OF PLACE OF RESIDENCE ----------
    # Frontend collects 4 location fields (region/district/village/neighborhood)
    # but doesn't explicitly ask urban/rural. We infer from village/neighborhood:
    # if user gave a village name → Rural, otherwise → Urban
    village = (data.get("village") or "").strip()
    if village:
        if "Type of place of residence_Rural" in row:
            row["Type of place of residence_Rural"] = 1
    else:
        if "Type of place of residence_Urban" in row:
            row["Type of place of residence_Urban"] = 1

    # ---------- EDUCATION ----------
    # Frontend: 'no_education', 'primary', 'middle', 'secondary', 'university'
    # Model:    'No education', 'Primary', 'Secondary', 'Higher'
    education = (data.get("education") or "").strip().lower()
    education_map = {
        "no_education": "Highest educational level_No education",
        "primary":      "Highest educational level_Primary",
        "middle":       "Highest educational level_Secondary",
        "secondary":    "Highest educational level_Secondary",
        "university":   "Highest educational level_Higher",
    }
    if education in education_map:
        col = education_map[education]
        if col in row:
            row[col] = 1

    # ---------- WEALTH INDEX ----------
    # Frontend: 'poor', 'moderate', 'good'
    # Model:    'Poorest', 'Poorer', 'Middle', 'Richer', 'Richest'
    wealth = (data.get("wealth") or "").strip().lower()
    wealth_map = {
        "poor":     "Wealth index combined_Poorer",
        "moderate": "Wealth index combined_Middle",
        "good":     "Wealth index combined_Richer",
    }
    if wealth in wealth_map:
        col = wealth_map[wealth]
        if col in row:
            row[col] = 1

    # ---------- MOSQUITO NET ----------
    # Frontend: 'yes' / 'no'
    mosquito_net = (data.get("mosquito_net") or "").strip().lower()
    if mosquito_net == "yes":
        col = "Have mosquito bed net for sleeping (from household questionnaire)_Yes"
        if col in row:
            row[col] = 1
    elif mosquito_net == "no":
        col = "Have mosquito bed net for sleeping (from household questionnaire)_No"
        if col in row:
            row[col] = 1

    # ---------- SMOKING ----------
    smoking = (data.get("smoking") or "").strip().lower()
    if smoking == "yes":
        if "Smokes cigarettes_Yes" in row:
            row["Smokes cigarettes_Yes"] = 1
    elif smoking == "no":
        if "Smokes cigarettes_No" in row:
            row["Smokes cigarettes_No"] = 1

    # ---------- MARITAL STATUS ----------
    married = (data.get("married") or "").strip().lower()
    husband_present = (data.get("husband_present") or "").strip().lower()
    if married == "yes":
        if husband_present == "yes":
            col = "Current marital status_Married"
        else:
            col = "Current marital status_Living with partner"
    else:
        col = "Current marital status_Never in union"
    if col in row:
        row[col] = 1

    # ---------- BIRTHS IN LAST 5 YEARS ----------
    # Frontend: '0', '1', '2', '3', '4' (string)
    try:
        births = int(data.get("births_last_5_years") or 0)
        if "Births in last five years" in row:
            row["Births in last five years"] = births
    except (ValueError, TypeError):
        pass

    # ---------- AGE AT 1ST BIRTH ----------
    try:
        first_birth_age = int(data.get("first_birth_age") or 0)
        if "Age of respondent at 1st birth" in row:
            row["Age of respondent at 1st birth"] = first_birth_age
    except (ValueError, TypeError):
        pass

    # ---------- HEMOGLOBIN LEVEL ----------
    # Frontend sends: has_hemoglobin_test ('yes'/'no'), hemoglobin_value (e.g., '12.5' g/dL)
    # IMPORTANT: Training data stores hemoglobin with the decimal point removed
    # ("1 decimal" in column name = divide by 10). So 12.5 g/dL -> 125 stored.
    # We multiply user's input by 10 to match the model's expected scale.
    has_test = (data.get("has_hemoglobin_test") or "").strip().lower()
    if has_test == "yes":
        try:
            hb_value = float(data.get("hemoglobin_value") or 0)
            if hb_value > 0:
                hb_scaled = hb_value * 10  # 12.5 g/dL -> 125
                if "Hemoglobin level adjusted for altitude and smoking (g/dl - 1 decimal)" in row:
                    row["Hemoglobin level adjusted for altitude and smoking (g/dl - 1 decimal)"] = hb_scaled
                if "Hemoglobin level adjusted for altitude (g/dl - 1 decimal)" in row:
                    row["Hemoglobin level adjusted for altitude (g/dl - 1 decimal)"] = hb_scaled
        except (ValueError, TypeError):
            pass

    # ---------- CHILDREN'S QUESTIONS (map to fever/iron proxy if applicable) ----------
    # 'child_pale' or 'child_weak' or 'child_tired' implies child has been sick → use fever marker
    if category == "children":
        anyone_sick = any(
            (data.get(k) or "").strip().lower() == "yes"
            for k in ["child_pale", "child_weak_dizzy", "child_tired"]
        )
        if anyone_sick:
            if "Had fever in last two weeks_Yes" in row:
                row["Had fever in last two weeks_Yes"] = 1
        else:
            if "Had fever in last two weeks_No" in row:
                row["Had fever in last two weeks_No"] = 1

        # child_good_food → taking iron supplements proxy
        good_food = (data.get("child_good_food") or "").strip().lower()
        if good_food == "yes":
            col = "Taking iron pills, sprinkles or syrup_Yes"
        elif good_food == "no":
            col = "Taking iron pills, sprinkles or syrup_No"
        else:
            col = None
        if col and col in row:
            row[col] = 1

        # Source file marker for children
        if "source_file_children anemia.csv" in row:
            row["source_file_children anemia.csv"] = 1
    else:
        # Adult: women/men
        if "source_file_anemia_only_strict.csv" in row:
            row["source_file_anemia_only_strict.csv"] = 1

    # ---------- FATIGUE / DIZZINESS (asked to ALL categories) ----------
    # These symptoms are now collected for women, men, and children.
    # We use them as a proxy for the "had fever" feature in the model.
    fatigue_yes = (data.get("fatigue") or "").strip().lower() == "yes"
    dizziness_yes = (data.get("dizziness") or "").strip().lower() == "yes"
    symptoms_yes = fatigue_yes or dizziness_yes
    if symptoms_yes:
        # Only override if not already set (e.g., from child weak/pale check)
        if (row.get("Had fever in last two weeks_Yes", 0) == 0
                and row.get("Had fever in last two weeks_No", 0) == 0):
            if "Had fever in last two weeks_Yes" in row:
                row["Had fever in last two weeks_Yes"] = 1
        elif row.get("Had fever in last two weeks_Yes", 0) == 0:
            # If "No" was set but user reports symptoms, switch to Yes
            row["Had fever in last two weeks_No"] = 0
            if "Had fever in last two weeks_Yes" in row:
                row["Had fever in last two weeks_Yes"] = 1

    return row


def classify_by_who_thresholds(hb_value: float, category: str):
    """
    Hybrid Clinical Layer: When hemoglobin is provided, classify anemia using
    WHO clinical thresholds (the international gold standard for anemia diagnosis).
    This is more accurate than ML prediction when actual lab data is available.

    References:
        WHO. Hemoglobin concentrations for the diagnosis of anaemia and assessment
        of severity. World Health Organization, 2024 update.

    Returns:
        tuple: (prediction_number, prediction_label, confidence, method)
            - prediction_number: 0=Mild/Low, 1=Moderate, 2=Severe
            - prediction_label: 'Mild', 'Moderate', 'Severe'
            - confidence: float in [0, 1]; high (>0.92) for clinical-rule classifications
            - method: 'WHO Clinical Thresholds'
    """
    cat = (category or "women").lower()

    if cat == "children":
        # WHO for children 6-59 months
        if hb_value < 7.0:
            return 2, "Severe", 0.98, "WHO Clinical Thresholds"
        elif hb_value < 10.0:
            return 1, "Moderate", 0.95, "WHO Clinical Thresholds"
        elif hb_value < 11.0:
            return 0, "Mild", 0.92, "WHO Clinical Thresholds"
        else:
            # Normal range — represented as 'Mild' (lowest risk class)
            return 0, "Mild", 0.95, "WHO Clinical Thresholds"

    elif cat == "men":
        # WHO for adult men (15+)
        if hb_value < 8.0:
            return 2, "Severe", 0.98, "WHO Clinical Thresholds"
        elif hb_value < 11.0:
            return 1, "Moderate", 0.95, "WHO Clinical Thresholds"
        elif hb_value < 13.0:
            return 0, "Mild", 0.92, "WHO Clinical Thresholds"
        else:
            return 0, "Mild", 0.95, "WHO Clinical Thresholds"

    else:  # women (default)
        # WHO for non-pregnant women (15+)
        if hb_value < 8.0:
            return 2, "Severe", 0.98, "WHO Clinical Thresholds"
        elif hb_value < 11.0:
            return 1, "Moderate", 0.95, "WHO Clinical Thresholds"
        elif hb_value < 12.0:
            return 0, "Mild", 0.92, "WHO Clinical Thresholds"
        else:
            return 0, "Mild", 0.95, "WHO Clinical Thresholds"


@app.route("/")
def home():
    return "Anemia Prediction API is running"


@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        print(f"[Flask] Received payload: {data}")

        # ============================================================
        # HYBRID DECISION LAYER
        # ============================================================
        # Strategy:
        #   - If user provided a hemoglobin measurement -> apply WHO clinical
        #     thresholds (international gold-standard diagnostic criteria).
        #   - Otherwise -> fall back to the Random Forest ML model trained on
        #     demographic and clinical features.
        # This combines the deterministic accuracy of clinical rules (when lab
        # data is available) with the predictive power of ML (when it is not).
        # ============================================================

        has_test = (data.get("has_hemoglobin_test") or "").strip().lower()
        hb_value_raw = data.get("hemoglobin_value")

        if has_test == "yes" and hb_value_raw:
            try:
                hb_value = float(hb_value_raw)
                if hb_value > 0:
                    category = data.get("category") or "women"
                    pred_num, pred_label, conf, method = classify_by_who_thresholds(
                        hb_value, category
                    )
                    print(f"[Flask] {method}: Hb={hb_value} g/dL ({category}) -> "
                          f"{pred_label} (number={pred_num}, confidence={conf:.3f})")
                    return jsonify({
                        "prediction_number": pred_num,
                        "prediction_label": pred_label,
                        "confidence": conf,
                        "method": method,
                        "hemoglobin_value": hb_value
                    })
            except (ValueError, TypeError) as e:
                print(f"[Flask] Hb parse error: {e}, falling back to ML")

        # ============================================================
        # ML PREDICTION LAYER (used when no hemoglobin value)
        # ============================================================
        mapped = map_frontend_to_model(data)
        input_df = pd.DataFrame([mapped])[model_columns]

        prediction = model.predict(input_df)
        probabilities = model.predict_proba(input_df)
        confidence = float(probabilities[0][prediction[0]])
        predicted_label = label_encoder.inverse_transform(prediction)

        print(f"[Flask] ML Prediction: {predicted_label[0]} "
              f"(number={int(prediction[0])}, confidence={confidence:.3f})")

        return jsonify({
            "prediction_number": int(prediction[0]),
            "prediction_label": predicted_label[0],
            "confidence": confidence,
            "method": "Machine Learning (XGBoost + SMOTE)"
        })

    except Exception as e:
        print(f"[Flask] ERROR: {e}")
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    app.run(debug=True)
