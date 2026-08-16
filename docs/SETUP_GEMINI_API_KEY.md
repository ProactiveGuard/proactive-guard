# Setting Your Own Gemini API Key (AI Summaries)

The backend uses Google Gemini to automatically write human-readable emergency
summaries for the police dashboard (see `backend/app/services/llm.py`).

You only need this if **you** run the backend (`app/main.py`) and you want real
AI-written summaries. The app still works without a key — it falls back to a
pre-written template summary.

## Step 1: Get a free API key

1. Go to Google AI Studio: https://aistudio.google.com/
2. Sign in with your Google account.
3. Click **Get API key** (top-left of the page).
4. Click **Create API key** → pick a project (or create one).
5. Copy the key string (it looks like `AIzaSy...`).

> Tip: you get one key per Google account. Only the person who **runs the
> backend** actually needs it — the Flutter app and dashboard talk to the
> backend over HTTP and never see the key.

## Step 2: Put the key in your local `.env`

In the `backend` folder:

1. Copy the template file:
   ```
   cd backend
   copy .env.example .env        (Windows)
   # or: cp .env.example .env    (Mac/Linux)
   ```
2. Open `.env` and paste your key:
   ```
   GEMINI_API_KEY=AIzaSy...your-key-here...
   ```
   (Optional: change `GEMINI_MODEL` if you want a different model.)
3. Save the file. Restart your backend server so it picks up the key.

## Step 3: Verify it works

From the `backend` folder, run:

```
py app\services\llm.py
```

You should see:

```
Gemini configured: True

--- AI SUMMARY GENERATOR ---
< a real, naturally-written emergency summary >
```

If it prints `Gemini configured: False`, the key wasn't picked up — check that
`.env` is in the `backend` folder and has no spaces around the `=`.

You can also start the server and send a test alert:

```
py -m uvicorn app.main:app --reload
```

Then POST telemetry (or press SOS from the app) and check that the incident's
`summary` is written by the AI.

## Important — keep the key out of Git

- The `.env` file is listed in `.gitignore` and **must never be committed**.
  If you commit it, your key is public and anyone can use your AI quota.
- The file `.env.example` (in the repo) is a template — it only contains empty
  placeholders and is safe to commit.
- If your key is ever committed by accident: regenerate it at
  https://aistudio.google.com/ and update your local `.env`.

## Troubleshooting

| Problem | Fix |
|---|---|
| `Gemini configured: False` | Key missing in `backend/.env` or the file is in the wrong folder. |
| Summary looks like a template | The API call failed (e.g. model unavailable, no internet) — check the terminal for errors. |
| `404 model ... no longer available` | The default `GEMINI_MODEL` was retired. Open AI Studio's model list and set a working model in `.env` (e.g. `GEMINI_MODEL=gemini-3.5-flash`). |
| Quota exhausted / rate limit | Free tier limits — wait a bit or share a second key. |
