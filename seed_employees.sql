-- ============================================================
-- WME Timesheet App — Seed Data
-- Run after WME_timesheet_schema.sql
-- ============================================================

-- Admin user (matches Supabase auth email)
insert into employees (auth_email, first_name, last_name, role, rate_type, rate, employment_type)
values ('jamesculloty@watfordme.co.uk', 'James', 'Culloty', 'admin', 'salary', 0, 'employed')
on conflict (auth_email) do nothing;
