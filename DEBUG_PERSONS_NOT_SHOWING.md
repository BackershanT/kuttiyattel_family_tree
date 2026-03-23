# 🔍 Debug Guide - Persons Not Showing

## 🐛 **Issue:** Family Members screen shows no persons

---

## 🔧 **Debug Steps Added**

### Console Output:
Now when persons are loaded, you'll see in console:

```
═══════════════════════════════════════════════════════
PERSONS LOADED: 5 persons
  - John Smith (Male) - DOB: 1990-01-15
  - Sarah Johnson (Female) - DOB: 1985-03-20
  - Michael Brown (Male) - DOB: 1978-07-10
  - Emma Davis (Female) - DOB: 1995-11-05
  - James Wilson (Male) - DOB: 1982-09-25
═══════════════════════════════════════════════════════
```

---

## 📊 **Possible Causes & Solutions**

### Cause 1: No Data in Database
**Symptoms:**
- Console shows: `PERSONS LOADED: 0 persons`
- Screen shows: "No family members yet"

**Solution:**
✅ Add your first person using the blue "Add Person" FAB button

---

### Cause 2: Still Loading
**Symptoms:**
- Screen shows loading spinner
- No console output yet

**Solution:**
✅ Wait for data to load from Supabase
✅ Should complete within 2-3 seconds

---

### Cause 3: Database Connection Error
**Symptoms:**
- Console shows error message
- Screen shows error with "Retry" button
- Persons not loading

**Solution:**
1. Check Supabase credentials in `.env` file
2. Verify internet connection
3. Check Supabase project is active
4. Click "Retry" button

---

### Cause 4: Supabase Table Missing
**Symptoms:**
- Error: "relation 'persons' does not exist"
- Can't load persons

**Solution:**
1. Go to Supabase dashboard
2. Run SQL from `database_schema.sql`
3. Create the `persons` table
4. Restart app

---

## 🎯 **How to Diagnose**

### Step 1: Check Console
Look at your terminal/console output when app starts:

```bash
# Good - Data loaded:
PERSONS LOADED: 3 persons
  - Name1 (Gender) - DOB: date
  ...

# Bad - No data:
PERSONS LOADED: 0 persons

# Error - Database issue:
Error: Failed to load persons: ...
```

---

### Step 2: Check Screen Display

**If Empty State Shows:**
```
┌──────────────────────┐
│                      │
│    👥 (icon)         │
│                      │
│  No family members   │
│       yet            │
│                      │
│  Tap + to add your   │
│ first family member  │
│                      │
└──────────────────────┘
```
→ **Means:** Database is working but empty → Add a person!

---

**If Loading Spinner Shows:**
```
┌──────────────────────┐
│                      │
│         ⏳           │
│      Loading...      │
│                      │
└──────────────────────┘
```
→ **Means:** Still fetching from database → Wait or check connection

---

**If Error Shows:**
```
┌──────────────────────┐
│                      │
│    ⚠️ Error          │
│                      │
│  [error message]     │
│                      │
│  [🔄 Retry Button]   │
└──────────────────────┘
```
→ **Means:** Database connection failed → Check Supabase config

---

## ✅ **Quick Fixes**

### Fix 1: Add Test Person
```bash
# Use the Add Person form to add someone:
1. Click blue "Add Person" FAB
2. Fill in name
3. Select gender
4. Pick date of birth
5. Click Save
6. Should appear in list immediately
```

---

### Fix 2: Reload Data
```dart
// Pull down on the list to refresh
// OR
// Click reload button if error shown
```

---

### Fix 3: Check Environment Variables
```bash
# Verify .env file exists and has correct values:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

### Fix 4: Verify Database Schema
```sql
-- Run this in Supabase SQL Editor to check if table exists:
SELECT * FROM persons LIMIT 10;

-- If error, run the schema creation SQL from database_schema.sql
```

---

## 🔍 **Debug Checklist**

Use this checklist to diagnose the issue:

- [ ] **Check Console**: Open terminal, look for debug prints
- [ ] **Check Output**: See "PERSONS LOADED: X persons"
- [ ] **Count > 0?**: If yes → Data exists, should display
- [ ] **Count = 0?**: If yes → Database is empty, add person
- [ ] **Error Message?**: If yes → Check Supabase connection
- [ ] **Loading Forever?**: Check internet connection
- [ ] **Screen Blank?**: Hot restart app (press R)

---

## 📱 **Expected Behavior**

### When Working Correctly:

```
App Starts
  ↓
Load Persons from Supabase
  ↓
Console: "PERSONS LOADED: 5 persons"
  ↓
List displays with cards:
┌─────────────────────┐
│ 👤 John Smith       │
│    Male • Jan 1990  │
├─────────────────────┤
│ 👤 Sarah Johnson    │
│  Female • Mar 1985  │
└─────────────────────┘
```

---

## 🎯 **Test Scenarios**

### Test 1: Fresh Install
```
1. Clear app data / reinstall
2. Launch app
3. Should see "No family members yet"
4. Add first person
5. List should show that person
```

---

### Test 2: With Existing Data
```
1. App already has persons added
2. Restart app
3. Console should show count
4. List should display all persons
```

---

### Test 3: Network Issue
```
1. Turn off WiFi/mobile data
2. Launch app
3. Should show error or loading forever
4. Turn internet back on
5. Pull to refresh
6. Should load successfully
```

---

## 💡 **Tips**

### For Development:
✅ Keep console/terminal visible while testing  
✅ Watch for debug print statements  
✅ Check both browser console AND terminal  
✅ Use hot restart (R) if UI stuck  

### For Production:
✅ Remove debug prints before release  
✅ Add proper error handling  
✅ Show user-friendly messages  
✅ Implement offline mode  

---

## 📝 **Summary**

**Issue:** Persons not showing in Family Members screen  
**Debug Added:** Console print showing loaded persons  
**Next Step:** Check console output to diagnose  
**Expected:** Should see count and list of persons  

---

*Debug Guide Created: March 22, 2026*  
*File: person_list_screen.dart*  
*Status: 🔍 DEBUG MODE ACTIVE*
