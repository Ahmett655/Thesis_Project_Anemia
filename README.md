# Anemia Risk Assessment System

A Mobile-Based Machine Learning System for Early Anemia Risk Assessment in Low-Resource Settings.

This is a thesis project that predicts anemia risk (Mild / Moderate / Severe) from a short questionnaire using a Random Forest model.

## Architecture

```
Flutter (frontend) -> Node.js (backend) -> Flask (ML API) -> Random Forest -> MongoDB
```

## Repository Layout

| Folder | Description |
|---|---|
| `flutter_frontend/` | Flutter app (web + mobile responsive) — user-facing UI |
| `node_backend/` | Node.js + Express API — auth, persistence, calls Flask API |
| `flask_api/` | Flask service exposing the trained ML model at `/predict` |
| `ml_project/` | Jupyter notebook, cleaned dataset, and trained model artifacts |

## Running Locally

**1. MongoDB** — make sure `mongod` is running on `mongodb://localhost:27017`.

**2. Flask ML API** (port 5000)
```bash
cd flask_api
python app.py
```

**3. Node Backend** (port 3000)
```bash
cd node_backend
npm install
node server.js
```

**4. Flutter Frontend** (web on port 8080)
```bash
cd flutter_frontend
flutter pub get
flutter run -d chrome --web-port=8080
```

## Dataset & Model

- Source dataset cleaned to 12,472 rows x 77 features
- 3 classes: 0 = Mild, 1 = Moderate, 2 = Severe
- Random Forest classifier, ~95.8% accuracy
- Artifacts: `anemia_model.pkl`, `label_encoder.pkl`, `model_columns.pkl`
