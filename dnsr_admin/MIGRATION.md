# Database Migration Guide

## Removing User Phone and Status Fields

This guide explains how to migrate your DNSR database from v1.0.0 to v2.0.0.

---

## Overview

Version 2.0.0 removes the following fields from the `utilisateurs` table:
- `numero_telephone` (phone number)
- `status` (user status: ACTIVE/DEACTIVATED)
- `deactivated_at` (deactivation timestamp)

---

## Prerequisites

- Access to Supabase SQL Editor or PostgreSQL client
- Database backup (recommended)
- Admin privileges on the database

---

## Migration Steps

### Step 1: Backup Your Database

**Important**: Always backup before making schema changes!

```bash
# Using Supabase CLI
supabase db dump -f backup_$(date +%Y%m%d).sql

# Or using pg_dump
pg_dump -h your-db-host -U postgres -d your-database > backup_$(date +%Y%m%d).sql
```

### Step 2: Execute Schema Changes

Run the following SQL in Supabase SQL Editor:

```sql
-- Remove deprecated columns from utilisateurs table
ALTER TABLE utilisateurs 
DROP COLUMN IF EXISTS numero_telephone,
DROP COLUMN IF EXISTS status,
DROP COLUMN IF EXISTS deactivated_at;

-- Verify the changes
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'utilisateurs'
ORDER BY ordinal_position;
```

### Step 3: Update Row Level Security (RLS) Policies

If you had RLS policies referencing the removed fields, update them:

```sql
-- List existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'utilisateurs';

-- Example: Remove status-based policies (if any)
-- DROP POLICY IF EXISTS "Users can view active profiles" ON utilisateurs;
-- DROP POLICY IF EXISTS "Admins can deactivate users" ON utilisateurs;
```

### Step 4: Clean Up Functions and Triggers

Check for any database functions or triggers that reference the removed columns:

```sql
-- Find functions that might reference removed columns
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE pg_get_functiondef(p.oid) ILIKE ANY(ARRAY['%numero_telephone%', '%status%', '%deactivated_at%'])
AND n.nspname NOT IN ('pg_catalog', 'information_schema');

-- Update or remove functions as needed
-- Example:
-- CREATE OR REPLACE FUNCTION your_function()
-- ...
```

### Step 5: Verify Data Integrity

```sql
-- Check that the columns are removed
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'utilisateurs' 
AND column_name IN ('numero_telephone', 'status', 'deactivated_at');
-- Should return 0 rows

-- Verify remaining columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'utilisateurs'
ORDER BY ordinal_position;

-- Expected columns:
-- id (uuid)
-- nom (text)
-- prenom (text)
-- email (text)
-- role (text)
-- created_at (timestamp)
-- updated_at (timestamp)
```

---

## Application Deployment

After database migration, deploy the updated application:

### 1. Update Edge Functions

```bash
cd "DNSR report/dnsr_admin"
supabase functions deploy sendNotification
```

### 2. Deploy Web Application

```bash
# Build
flutter build web --release --no-web-resources-cdn

# Deploy to your hosting service
firebase deploy --only hosting
# or
netlify deploy --prod
```

---

## Rollback Plan

If you need to rollback the changes:

```sql
-- Restore from backup
psql -h your-db-host -U postgres -d your-database < backup_YYYYMMDD.sql

-- Or manually re-add columns
ALTER TABLE utilisateurs
ADD COLUMN numero_telephone TEXT,
ADD COLUMN status TEXT DEFAULT 'ACTIVE',
ADD COLUMN deactivated_at TIMESTAMP WITH TIME ZONE;
```

---

## Testing After Migration

### 1. Authentication Test

```dart
// Should work without status check
final user = await supabase.auth.signInWithPassword(
  email: 'admin@example.com',
  password: 'your_password',
);
```

### 2. User Query Test

```sql
-- Should work without removed columns
SELECT id, email, nom, prenom, role, created_at 
FROM utilisateurs 
WHERE role = 'ADMIN';
```

### 3. Application Tests

- ✅ Login as admin user
- ✅ View users page (no phone numbers displayed)
- ✅ Search users by email and name
- ✅ View user profile details
- ✅ Manage incidents normally
- ✅ Send notifications

---

## Common Issues

### Issue: "Column does not exist" errors

**Solution**: Ensure all application code is updated before running it against the migrated database.

### Issue: RLS policies failing

**Solution**: Check and update any RLS policies that referenced removed columns.

### Issue: Edge functions failing

**Solution**: Redeploy edge functions with `supabase functions deploy`

---

## Data Considerations

### What happens to existing data?

- **Phone numbers**: Permanently deleted. Export before migration if needed.
- **Status values**: Permanently deleted. All users are now treated equally.
- **Deactivation timestamps**: Permanently deleted. Export before migration if needed.

### Exporting data before migration

```sql
-- Export phone numbers
COPY (
  SELECT id, email, numero_telephone 
  FROM utilisateurs 
  WHERE numero_telephone IS NOT NULL
) TO '/tmp/phone_numbers_backup.csv' WITH CSV HEADER;

-- Export status information
COPY (
  SELECT id, email, status, deactivated_at 
  FROM utilisateurs
) TO '/tmp/user_status_backup.csv' WITH CSV HEADER;
```

---

## Support

If you encounter issues during migration:

1. Check the backup was successful before proceeding
2. Review error messages in Supabase logs
3. Verify all SQL commands completed successfully
4. Test with a small subset of data first (if possible)
5. Open an issue on GitHub if problems persist

---

## Migration Checklist

- [ ] Database backup created
- [ ] Schema changes applied
- [ ] RLS policies updated (if needed)
- [ ] Functions/triggers updated (if needed)
- [ ] Data integrity verified
- [ ] Edge functions deployed
- [ ] Application deployed
- [ ] Authentication tested
- [ ] User management tested
- [ ] All features working correctly
- [ ] Documentation updated
- [ ] Team notified of changes

---

**Last Updated**: October 31, 2025  
**Version**: 2.0.0
