-- ============================================================
-- WME Timesheet App — Supabase Schema
-- Run in the EXISTING Supabase project (zzajwyyhyioaqtyyislc)
-- This adds tables alongside the existing vendors/projects/po_log
-- ============================================================

-- ── EMPLOYEES ────────────────────────────────────────────────
create table if not exists employees (
  id               uuid primary key default gen_random_uuid(),
  auth_email       text unique,
  first_name       text not null,
  last_name        text not null,
  display_name     text generated always as (first_name || ' ' || last_name) stored,
  role             text not null default 'operative'
                   check (role in ('operative','office','manager','admin')),
  rate_type        text not null default 'hourly'
                   check (rate_type in ('hourly','daily','salary')),
  rate             numeric(10,2) not null default 0,
  employment_type  text not null default 'employed'
                   check (employment_type in ('employed','subcontractor','agency')),
  active           boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- ── TIME ENTRIES ─────────────────────────────────────────────
create table if not exists time_entries (
  id               uuid primary key default gen_random_uuid(),
  employee_id      uuid not null references employees(id),
  project_name     text not null references projects(name) on update cascade,
  entry_date       date not null,
  start_time       time not null,
  end_time         time not null,
  break_minutes    integer not null default 30,
  calculated_hours numeric(5,2),
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint end_after_start check (end_time > start_time),
  constraint break_non_negative check (break_minutes >= 0)
);

-- ── TIMESHEETS ───────────────────────────────────────────────
create table if not exists timesheets (
  id               uuid primary key default gen_random_uuid(),
  employee_id      uuid not null references employees(id),
  week_starting    date not null,
  status           text not null default 'Draft'
                   check (status in ('Draft','Submitted','Approved','Rejected')),
  total_hours      numeric(6,2) default 0,
  total_cost       numeric(10,2) default 0,
  submitted_at     timestamptz,
  approved_by      uuid references employees(id),
  approved_at      timestamptz,
  rejection_reason text,
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint one_per_week unique (employee_id, week_starting)
);

-- ── INDEXES ──────────────────────────────────────────────────
create index if not exists idx_time_entries_employee_date
  on time_entries (employee_id, entry_date);

create index if not exists idx_timesheets_employee_week
  on timesheets (employee_id, week_starting);

create index if not exists idx_timesheets_status
  on timesheets (status);

-- ── TRIGGER: Calculate hours on time_entries ─────────────────
create or replace function calc_entry_hours()
returns trigger language plpgsql as $$
begin
  new.calculated_hours := round(
    ((extract(epoch from new.end_time) - extract(epoch from new.start_time)) / 3600.0)
    - (new.break_minutes / 60.0), 2
  );
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_calc_hours on time_entries;
create trigger trg_calc_hours
  before insert or update on time_entries
  for each row execute function calc_entry_hours();

-- ── TRIGGER: touch_updated_at (reuse if exists, create if not)
-- The procurement schema already created this function.
-- This DO block creates it only if it doesn't exist yet.
do $$
begin
  if not exists (
    select 1 from pg_proc where proname = 'touch_updated_at'
  ) then
    execute $fn$
      create function touch_updated_at()
      returns trigger language plpgsql as $t$
      begin
        new.updated_at := now();
        return new;
      end;
      $t$;
    $fn$;
  end if;
end;
$$;

drop trigger if exists trg_touch_employees on employees;
create trigger trg_touch_employees
  before update on employees
  for each row execute function touch_updated_at();

drop trigger if exists trg_touch_timesheets on timesheets;
create trigger trg_touch_timesheets
  before update on timesheets
  for each row execute function touch_updated_at();

-- ── ROW LEVEL SECURITY ──────────────────────────────────────
alter table employees    enable row level security;
alter table time_entries enable row level security;
alter table timesheets   enable row level security;

-- Employees: read/insert/update for authenticated
create policy "auth read employees"   on employees    for select using (auth.role() = 'authenticated');
create policy "auth insert employee"  on employees    for insert with check (auth.role() = 'authenticated');
create policy "auth update employee"  on employees    for update using (auth.role() = 'authenticated');

-- Time entries: read/insert/update/delete for authenticated
create policy "auth read entries"     on time_entries  for select using (auth.role() = 'authenticated');
create policy "auth insert entry"     on time_entries  for insert with check (auth.role() = 'authenticated');
create policy "auth update entry"     on time_entries  for update using (auth.role() = 'authenticated');
create policy "auth delete entry"     on time_entries  for delete using (auth.role() = 'authenticated');

-- Timesheets: read/insert/update for authenticated
create policy "auth read timesheets"  on timesheets    for select using (auth.role() = 'authenticated');
create policy "auth insert timesheet" on timesheets    for insert with check (auth.role() = 'authenticated');
create policy "auth update timesheet" on timesheets    for update using (auth.role() = 'authenticated');
