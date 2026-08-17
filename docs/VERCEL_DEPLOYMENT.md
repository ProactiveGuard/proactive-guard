# Vercel Deployment Guide — Next.js Dashboard

## Overview
Deploy the Proactive Guard Next.js Command Center to Vercel.

**Repository:** `https://github.com/<your-org>/proactive-guard`
**Dashboard Root:** `dashboard/`
**Framework:** Next.js 14 (App Router)

---

## Prerequisites

- [ ] GitHub repository with `dashboard/` folder
- [ ] Vercel account (free tier sufficient)
- [ ] Supabase project URL and Anon Key
- [ ] Backend API URL (Render deployment URL)

---

## Required Environment Variables

Configure these in **Vercel Dashboard → Settings → Environment Variables**:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | `https://abcxyz.supabase.co` | ✅ |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbGciOiJIUzI1NiIs...` | ✅ |
| `NEXT_PUBLIC_API_BASE_URL` | Backend API base URL | `https://proactive-guard-api.onrender.com` | ✅ |
| `NEXT_PUBLIC_MAP_TILE_URL` | Map tile server (optional) | `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png` | ❌ |

**Note:** All variables prefixed with `NEXT_PUBLIC_` are exposed to the browser. Do NOT put secrets here.

---

## Deployment Steps

### Option 1: Vercel Dashboard (Recommended)

1. **Login to Vercel**
   - Go to https://vercel.com
   - Sign in with GitHub

2. **Import Project**
   - Click "Add New..." → "Project"
   - Select your GitHub repo: `proactive-guard`
   - Click "Import"

3. **Configure Project**
   - **Framework Preset:** Next.js (auto-detected)
   - **Root Directory:** `dashboard` ⚠️ **CRITICAL**
   - **Build Command:** `npm run build` (default)
   - **Output Directory:** `.next` (default)
   - **Install Command:** `npm install` (default)

4. **Environment Variables**
   - Expand "Environment Variables"
   - Add each variable from table above
   - Set **Environment**: Production, Preview, Development (all)

5. **Deploy**
   - Click "Deploy"
   - Wait 2-3 minutes for build

6. **Verify**
   - Visit deployed URL: `https://proactive-guard-<random>.vercel.app`
   - Check: Dashboard loads, incidents display, map renders

### Option 2: Vercel CLI

```bash
# Install CLI
npm i -g vercel

# Login
vercel login

# Deploy from dashboard folder
cd dashboard
vercel

# Follow prompts:
# ? Set up and deploy? Yes
# ? Which scope? <your-account>
# ? Link to existing project? No
# ? Project name: proactive-guard-dashboard
# ? Directory: ./dashboard
# ? Override settings? No

# Add environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add NEXT_PUBLIC_API_BASE_URL

# Deploy to production
vercel --prod
```

---

## Build Configuration Details

### `dashboard/package.json` (Verify Exists)
```json
{
  "name": "proactive-guard-dashboard",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.x",
    "react": "18.x",
    "react-dom": "18.x",
    "leaflet": "1.9.x",
    "react-leaflet": "4.x",
    "@supabase/supabase-js": "2.x",
    "swr": "2.x"
  },
  "devDependencies": {
    "typescript": "5.x",
    "@types/react": "18.x",
    "@types/node": "20.x",
    "tailwindcss": "3.x",
    "postcss": "8.x",
    "autoprefixer": "10.x"
  }
}
```

### `dashboard/next.config.js` (Verify Exists)
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
      {
        protocol: 'https',
        hostname: 'tile.openstreetmap.org',
      },
    ],
  },
  async rewrites() {
    return [
      {
        source: '/api/backend/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_BASE_URL}/:path*`,
      },
    ];
  },
};

module.exports = nextConfig;
```

### `dashboard/tailwind.config.js` (Verify Exists)
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

---

## Post-Deployment Verification

### Checklist
- [ ] Dashboard loads at `https://<project>.vercel.app`
- [ ] No console errors (F12 → Console)
- [ ] Incident list displays (fetch from Supabase)
- [ ] LiveMap renders with OpenStreetMap tiles
- [ ] Map markers appear for existing incidents
- [ ] Severity colors correct (Red/Orange/Yellow/Green)
- [ ] Click incident → detail page works
- [ ] Realtime updates: new incident appears without refresh
- [ ] Mobile responsive (resize browser)

### Test Realtime
1. Open dashboard in two browser tabs
2. In Supabase Dashboard → Table Editor → `incidents` → Insert row
3. Both tabs should show new incident within 1-2 seconds

### Test API Proxy (if configured)
```bash
# Should proxy to backend
curl https://<project>.vercel.app/api/backend/ping
```

---

## Updating Member 1 & Member 2 with Dashboard URL

After deployment, share:

| Member | What They Need | Where to Update |
|--------|----------------|-----------------|
| **Member 1 (Mobile)** | Dashboard URL for web view links | `mobile/lib/utils/constants.dart` — `dashboardBaseUrl` |
| **Member 2 (Dashboard)** | Self-reference (already have) | N/A |
| **Member 4 (Backend)** | Dashboard URL for CORS origins | `backend/app/core/config.py` — `CORS_ORIGINS` |
| **Member 6 (Integration)** | For QR codes, docs | `docs/QR_CODES.md` |

**Communication Template:**
```
🚀 Dashboard Deployed!
URL: https://proactive-guard-abc123.vercel.app

Member 1: Update constants.dart → dashboardBaseUrl
Member 4: Add to CORS_ORIGINS in config.py
Member 6: Update QR_CODES.md
```

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Build fails: "Module not found" | Missing deps | Check `package.json`, run `npm install` locally first |
| Build fails: TypeScript errors | Type errors | Run `npm run build` locally, fix errors |
| Map not loading | Tile URL blocked | Use `https://tile.openstreetmap.org` (HTTPS required) |
| Supabase connection failed | Wrong env vars | Verify `NEXT_PUBLIC_SUPABASE_URL` and `ANON_KEY` in Vercel |
| Realtime not working | RLS policies | Check Supabase: `ALTER PUBLICATION supabase_realtime ADD TABLE incidents;` |
| CORS errors on API calls | Backend CORS | Member 4: Add Vercel URL to `CORS_ORIGINS` |
| 404 on refresh (App Router) | Vercel config | Next.js 14 App Router works natively on Vercel |

---

## Custom Domain (Optional)

1. Vercel Dashboard → Project → Settings → Domains
2. Add domain: `dashboard.proactiveguard.in`
3. Configure DNS:
   - Type: CNAME
   - Name: `dashboard`
   - Value: `cname.vercel-dns.com`
4. SSL auto-provisioned

---

## Rollback

```bash
# Vercel CLI
vercel rollback <deployment-url>

# Or Dashboard: Deployments → Three dots → Promote to Production
```

---

## Costs
- **Vercel Free Tier:** 100GB bandwidth, unlimited personal projects
- **Pro Team:** $20/month for team features (not needed for SIH)

---

*Last Updated: Day 3 — Member 6*
*Version: 1.0*