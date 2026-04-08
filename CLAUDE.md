# WME Timesheet App — Project Context

## What this is
Timesheet and labour tracking web app for Watford ME Ltd (M&E contractor, Watford).
Single HTML file app (index.html) with Supabase database backend.
Part of the WME app suite — shares Supabase project and auth with all other WME apps.

## Live URLs
- App: https://timesheets.watfordme.co.uk (Vercel: wme-timesheet-app)
- GitHub: https://github.com/jamesculloty/WME-Timesheet-App
- Supabase project: zzajwyyhyioaqtyyislc (shared with all WME apps)

## Authentication
Uses the shared WMEAuth module loaded from https://apps.watfordme.co.uk/wme-auth.js
Cross-subdomain SSO via shared cookie on .watfordme.co.uk
Role-based access: all roles (operative, maintenance, office, manager, admin)
ADMIN_EMAIL: jamesculloty@watfordme.co.uk

## Database (Supabase PostgreSQL — shared project)

### Timesheet tables
- employees (8 records) — first_name, last_name, display_name (generated), auth_email, role, rate_type, rate, employment_type, active
- time_entries (2 records) — employee_id, project_name, entry_date, start_time, end_time, break_minutes, calculated_hours, notes
- timesheets — employee_id, week_starting, status, total_hours, total_cost, submitted_at, approved_by, approved_at, rejection_reason, notes

### Shared tables
- projects — shared with Procurement, Invoice Checker, CVR

### Status flow
Draft -> Submitted -> Approved (also: Rejected -> Draft)

### Rate types
- hourly: rate x hours worked
- daily: rate x days worked (count of unique dates with entries)
- salary: annual rate / 52 (for cost allocation)

### Employment types
employed, subcontractor, agency

### Roles (hierarchy: level 10-50)
operative (10), maintenance (20), office (30), manager (40), admin (50)

## Stack
- Vanilla HTML/CSS/JS — no framework, no build process
- Supabase JS v2 (unpkg CDN)
- WMEAuth shared auth module (apps.watfordme.co.uk)
- Deployed as static file on Vercel with custom domain
- Auto-deploys on every GitHub push to main branch

## Key conventions
- All code lives in one file: index.html
- WME brand colours: green #1D4A2A, gold #B8860B
- After every change: commit with a clear message and push to main
- Manager role can approve timesheets
- Week cycle: Mon-Fri, identified by Monday date
- App switcher bar rendered by WMEAuth.renderAppSwitcher()

## Screens
1. scr-auth — Login/signup (shared auth)
2. scr-dash — Dashboard with week grid and stats
3. scr-log-day — Daily time entry (add/delete entries)
4. scr-week — Weekly overview with entry details
5. scr-submit — Submission confirmation
6. scr-history — Past timesheets with status
7. scr-approve — Manager approval screen
8. scr-admin — Employee management + reports (admin/manager)
9. scr-no-employee — Auth email not linked to employee

## Current status (April 2026)
- All screens built and deployed with custom domain
- Shared auth (WMEAuth) integrated with app switcher bar
- Schema running in Supabase with RLS enabled
- 8 employees seeded, time entry and approval workflows functional

## Next features to build
1. CSV export of hours by project/employee/week
2. Overtime calculation rules
3. Holiday/absence tracking
4. Direct payroll export format
