# 🔍 Debug Guide - Blank Family Tree

## 🐛 **Issue:** Family Tree screen appears blank

---

## 🔧 **Debug Logging Added**

### Console Output You'll See:

```
═══════════════════════════════════════════════════
TREE BLOC: Loading tree data...
Repository returned root: John Smith (person_123)
Tree loaded successfully:
  - Root: John Smith
  - Total nodes: 5
═══════════════════════════════════════════════════
═══════════════════════════════════════════════════
TREE DATA LOADED
Total nodes in state: 5
Root person: John Smith (person_123)
Building graph...
═══════════════════════════════════════════════════
```

---

## 📊 **Possible Causes & Solutions**

### Cause 1: No Persons in Database ✅ Most Common
**Symptoms:**
- Console shows: `No family tree data found!`
- Screen shows: Error message with retry button

**Solution:**
✅ Add persons first using "Add Person" FAB
✅ Then navigate to Family Tree

---

### Cause 2: Still Loading
**Symptoms:**
- Console shows: `TREE BLOC: Loading tree data...`
- Screen shows: Loading spinner

**Solution:**
✅ Wait 2-3 seconds for tree to build
✅ Should complete automatically

---

### Cause 3: Graph Not Building
**Symptoms:**
- Console shows: Tree data loaded
- Screen shows: Blank or empty

**Solution:**
✅ Check console for "Building graph..." message
✅ If not shown, hot restart app (press R)

---

### Cause 4: Database Connection Error
**Symptoms:**
- Console shows error message
- Screen shows error with retry button

**Solution:**
1. Check Supabase credentials
2. Verify internet connection
3. Click "Retry" button

---

## 🎯 **How to Diagnose**

### Step 1: Check Console Output

Navigate to Family Tree screen and watch console:

**Good - Data Loads:**
```
TREE BLOC: Loading tree data...
Repository returned root: [Name]
Tree loaded successfully:
  - Root: [Name]
  - Total nodes: X
TREE DATA LOADED
Total nodes in state: X
Building graph...
```
→ **Tree should display** ✅

---

**Bad - No Data:**
```
TREE BLOC: Loading tree data...
No family tree data found!
```
→ **Database is empty** → Add persons first!

---

**Error - Connection Issue:**
```
TREE BLOC: Loading tree data...
Tree loading error: [error details]
```
→ **Check Supabase configuration**

---

### Step 2: Check Screen Display

**If Loading Spinner Shows:**
```
┌──────────────────────┐
│                      │
│         ⏳           │
│      Loading...      │
│                      │
└──────────────────────┘
```
→ **Means:** Still building tree → Wait 2-3 seconds

---

**If Error Shows:**
```
┌──────────────────────┐
│                      │
│    ⚠️ Error          │
│                      │
│  No family tree data │
│       found          │
│                      │
│  [🔄 Retry Button]   │
└──────────────────────┘
```
→ **Means:** No persons in database → Add people first!

---

**If Blank Screen:**
```
┌──────────────────────┐
│                      │
│                      │
│     (empty white)    │
│                      │
│                      │
└──────────────────────┘
```
→ **Means:** Graph didn't build → Check console logs

---

## ✅ **Quick Fixes**

### Fix 1: Add Family Members First
```bash
# The tree needs persons to display:
1. Go back to home screen
2. Click blue "Add Person" FAB
3. Add at least 2-3 family members
4. Add relationships between them
5. THEN navigate to Family Tree
```

---

### Fix 2: Refresh Tree
```dart
// In Family Tree screen:
1. Click refresh icon (top right)
2. Or pull down to refresh
3. Tree will reload from database
```

---

### Fix 3: Hot Restart App
```bash
# In terminal:
Press 'R' (capital R for full restart)
Then navigate to Family Tree again
```

---

### Fix 4: Clear and Rebuild
```bash
# Stop app completely
# Then restart:
flutter run -d chrome
```

---

## 🔍 **Debug Checklist**

Use this checklist to diagnose the issue:

- [ ] **Check Console**: Navigate to tree screen, watch console
- [ ] **See "Loading" message?**: Tree bloc is working
- [ ] **See "Repository returned root"?**: Data fetched successfully
- [ ] **Node count > 0?**: Tree has data to display
- [ ] **See "Building graph..."?**: Graph visualization starting
- [ ] **Error Message?**: Check Supabase config
- [ ] **Blank Screen?**: Check if graph.nodes is empty

---

## 📱 **Expected Behavior**

### When Working Correctly:

```
Navigate to Family Tree
  ↓
TreeBloc loads data from Supabase
  ↓
Console: "Tree loaded successfully: 5 nodes"
  ↓
Graph builds with nodes and edges
  ↓
Interactive tree displays:
        ┌─────────┐
        │ Grandpa │
        └────┬────┘
             │
        ┌────┴────┐
        │         │
     ┌──┴──┐   ┌─┴─┐
     │Dad  │   │Mom│
     └──┬──┘   └───┘
        │
     ┌──┴──┐
     │ You │
     └─────┘
```

---

## 🎯 **Test Scenarios**

### Test 1: Empty Database
```
1. Fresh database with no persons
2. Navigate to Family Tree
3. Should show: "No family tree data found"
4. Console: "No family tree data found!"
```
**Expected:** Error message with retry button ✅

---

### Test 2: With Persons But No Relationships
```
1. Add 3-4 persons (no relationships)
2. Navigate to Family Tree
3. Should show one person as root
4. Others won't be connected
```
**Expected:** Tree with single node or disconnected nodes ✅

---

### Test 3: Complete Family Tree
```
1. Add grandparents, parents, children
2. Add parent-child relationships
3. Navigate to Family Tree
4. Should display hierarchical tree
```
**Expected:** Full tree visualization with connections ✅

---

## 💡 **Important Notes**

### Why Tree Might Be Blank:

1. **No Data**: Tree needs persons AND relationships
2. **Virtual Root**: System creates virtual root if no clear root person
3. **Loading State**: Takes 2-3 seconds to build graph
4. **Graph Build Failed**: Check console for errors

### What Tree Displays:

- ✅ **Root Person**: Usually oldest generation
- ✅ **Children**: Connected via parent-child relationships
- ✅ **Generations**: Organized hierarchically
- ✅ **Interactive**: Can zoom, pan, tap for details

---

## 📊 **Console Output Examples**

### Example 1: Successful Load
```
═══════════════════════════════════════════════════
TREE BLOC: Loading tree data...
Repository returned root: John Smith (person_001)
Tree loaded successfully:
  - Root: John Smith
  - Total nodes: 8
═══════════════════════════════════════════════════
═══════════════════════════════════════════════════
TREE DATA LOADED
Total nodes in state: 8
Root person: John Smith (person_001)
Building graph...
═══════════════════════════════════════════════════
```

---

### Example 2: Empty Database
```
═══════════════════════════════════════════════════
TREE BLOC: Loading tree data...
No family tree data found!
═══════════════════════════════════════════════════
```

---

### Example 3: Error
```
═══════════════════════════════════════════════════
TREE BLOC: Loading tree data...
Tree loading error: Network request failed
═══════════════════════════════════════════════════
```

---

## 🔧 **Advanced Debugging**

### Check Repository Method:

The tree is built by `TreeRepository.buildFamilyTree()`:

```dart
// This method:
1. Fetches all persons from Supabase
2. Finds root person (oldest generation)
3. Builds TreeNodeData hierarchy
4. Returns root node with children
```

If this returns null, tree will be blank.

---

### Check Graph Building:

The graph is built by `_buildGraph()` method:

```dart
// This method:
1. Creates Graph object
2. Adds nodes for each person
3. Adds edges for relationships
4. Calls setState() after build completes
```

If this fails, check console for errors.

---

## 📝 **Summary**

**Issue:** Family Tree appears blank  
**Debug Added:** Console logging in TreeBloc and TreeGraphWidget  
**Next Step:** Check console output when navigating to tree  
**Common Cause:** No persons in database yet  

---

*Debug Guide Created: March 22, 2026*  
*Files Modified:*
- *tree_bloc.dart (debug logging)*
- *tree_graph_widget.dart (debug logging)*
*Status: 🔍 DEBUG MODE ACTIVE*
