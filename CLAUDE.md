# WME Timesheet App — Project Context

## What this is
Timesheet and labour tracking web app for Watford ME Ltd (M&E contractor, Watford).
Single HTML file app (index.html) with Supabase database backend.
Part of the WME app suite — shares the same Supabase project as the Procurement App.

## Live URLs
- App: [to be set after Vercel deploy]
- GitHub: [to be set after repo creation]
- Supabase project: zzajwyyhyioaqtyyislc (shared with Procurement App)

## Credentials (in index.html)
- SUPABASE_URL: https://zzajwyyhyioaqtyyislc.supabase.co
- SUPABASE_ANON_KEY: [same as procurement app]
- ADMIN_EMAIL: jamesculloty@watfordme.co.uk

## Database (Supabase PostgreSQL — shared project)

### Shared tables (created by Procurement App)
- projects — project list with name, site, manager, status

### Timesheet tables
- employees — name, auth_email, role, rate_type, rate, employment_type
- time_entries — employee_id, project_name, entry_date, start_time, end_time, break_minutes, calculated_hours
- timesheets — employee_id, week_starting, status, total_hours, total_cost, approved_by

### Status flow
Draft → Submitted → Approved (also: Rejected → Draft)

### Rate types
- hourly: rate × hours worked
- daily: rate × days worked (count of unique dates with entries)
- salary: annual rate ÷ 52 (for cost allocation)

## Stack
- Vanilla HTML/CSS/JS — no framework, no build process
- Supabase JS v2 (unpkg CDN)
- Deployed as static file on Vercel
- Auto-deploys on every GitHub push to main branch

## Key conventions
- All code lives in one file: index.html
- WME brand colours: green #1D4A2A, gold #B8860B
- After every change: commit with a clear message and push to main
- Admin access controlled by ADMIN_EMAIL + employee.role
- Manager role can approve timesheets
- Week cycle: Mon–Fri, identified by Monday date

## Screens
1. scr-auth — Login/signup
2. scr-dash — Dashboard with week grid and stats
3. scr-log-day — Daily time entry (add/delete entries)
4. scr-week — Weekly overview with entry details
5. scr-submit — Submission confirmation
6. scr-history — Past timesheets with status
7. scr-approve — Manager approval screen
8. scr-admin — Employee management (admin/manager)
9. scr-no-employee — Shown when auth email not linked to employee

## Current status (March 2026)
- All screens built: auth, dashboard, daily log, week view, submit, history, approvals, admin
- Schema SQL ready to run in Supabase
- Needs: run schema, seed admin user, create GitHub repo, deploy to Vercel
- Future: CSV export, overtime rules, payroll integration

## Next features to build
1. CSV export of hours by project/employee/week
2. Overtime calculation rules
3. Holiday/absence tracking
4. Direct payroll export format
5. Cross-app nav linking to Procurement App
