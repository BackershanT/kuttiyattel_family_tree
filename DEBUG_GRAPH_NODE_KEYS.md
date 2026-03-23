# 🔍 Debug Guide - Graph Node Keys Issue

## 🐛 **Issue:** "Unexpected null value" errors despite graph being built

---

## 🔧 **Enhanced Debug Logging Added**

### Console Output You'll See:

```
═══════════════════════════════════════════════════
TREE DATA LOADED
Total nodes in state: 7
Root person: Family Root (virtual_root)
Building graph...
  Added node: ID=virtual_root, Name=Family Root, GraphNode key=virtual_root
  Added node: ID=person_123, Name=John Smith, GraphNode key=person_123
  Added child: ID=person_456, Name=Sarah Johnson, GraphNode key=person_456
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=virtual_root, ID=virtual_root
  - Node 2: key=person_123, ID=person_123
  - Node 3: key=person_456, ID=person_456
  ...
═══════════════════════════════════════════════════
```

---

## 📊 **Possible Causes & Solutions**

### Cause 1: Node Keys Not Set Properly ✅ Most Likely
**Symptoms:**
- Graph shows nodes count
- But console shows "NULL" for node keys
- Repeated "Unexpected null value" errors

**Solution:**
✅ Check if `Node.Id()` constructor is setting keys properly
✅ Verify person IDs are not null
✅ May need to use different Node constructor

---

### Cause 2: Graph Library Issue
**Symptoms:**
- Node keys show as NULL in debug output
- GraphView can't read node identifiers

**Solution:**
✅ Check graphview package version
✅ May need to update or change library
✅ Consider alternative graph rendering approach

---

### Cause 3: Virtual Root Person
**Symptoms:**
- Root has ID 'virtual_root'
- System-generated root person
- Might not have proper data

**Solution:**
✅ Ensure virtual_root has valid person data
✅ Check TreeNodeData creation for virtual root

---

## 🎯 **How to Diagnose**

### Step 1: Check Console Output

Navigate to Family Tree screen and watch console:

**Good - Keys Set Properly:**
```
Building graph...
  Added node: ID=person_123, Name=John Smith, GraphNode key=person_123
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=person_123, ID=person_123
  - Node 2: key=person_456, ID=person_456
```
→ **Keys are set correctly** ✅

---

**Bad - Keys Are NULL:**
```
Building graph...
  Added node: ID=person_123, Name=John Smith, GraphNode key=NULL
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=NULL, ID=N/A
  - Node 2: key=NULL, ID=N/A
```
→ **Node.Id() constructor not working** ❌

---

### Step 2: Check Error Pattern

**If errors appear AFTER graph built:**
```
Graph built with 7 nodes
Node keys in graph:
  ...
[Then errors start]
Another exception was thrown: Unexpected null value.
```
→ **Builder callback accessing null keys**

---

## ✅ **Quick Fixes**

### Fix 1: Check Node Constructor
```dart
// Current code:
final graphNode = Node.Id(node.person.id);

// If this doesn't work, try:
final graphNode = Node();
graphNode.key = ValueKey(node.person.id);
```

---

### Fix 2: Verify Person IDs
```dart
// Add validation before creating node:
if (node.person.id == null || node.person.id.isEmpty) {
  print('ERROR: Person has null/empty ID!');
  return;
}
```

---

### Fix 3: Use Alternative Node Creation
```dart
// Instead of Node.Id(), use:
final graphNode = Node.root();
// Or create custom node with explicit key
```

---

## 🔍 **Debug Checklist**

Use this checklist to diagnose the issue:

- [ ] **Check "Added node" logs**: Do they show keys or NULL?
- [ ] **Check "Node keys in graph" list**: Are keys present?
- [ ] **Count matches**: Does graph.nodes.length match state.allNodes.length?
- [ ] **Virtual root present**: Is virtual_root in the graph?
- [ ] **Error timing**: Do errors start after graph build?
- [ ] **Library version**: Check graphview package version

---

## 📱 **Expected Behavior**

### When Working Correctly:

```
Building graph...
  Added node: ID=virtual_root, Name=Family Root, GraphNode key=virtual_root
  Added node: ID=person_001, Name=John Smith, GraphNode key=person_001
  Added child: ID=person_002, Name=Sarah Johnson, GraphNode key=person_002
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=virtual_root, ID=virtual_root
  - Node 2: key=person_001, ID=person_001
  - Node 3: key=person_002, ID=person_002
  ...
Tree displays without errors ✅
```

---

## 🎯 **Test Scenarios**

### Test 1: Check Node Creation
```
1. Navigate to tree screen
2. Watch console for "Added node" messages
3. Check if GraphNode key matches person ID
4. Should see actual IDs, not NULL
```
**Expected:** All nodes have proper keys ✅

---

### Test 2: Check Graph Building
```
1. Hot restart app
2. Navigate to tree screen
3. Wait for "Graph built with X nodes"
4. Check "Node keys in graph" list
```
**Expected:** All keys present and valid ✅

---

### Test 3: Check Rendering
```
1. After graph builds, check if tree displays
2. No "Unexpected null value" errors
3. Nodes render as cards
4. Can zoom and pan
```
**Expected:** Tree renders and interactive ✅

---

## 💡 **Advanced Debugging**

### The Node.Id() Constructor:

The graphview library's `Node.Id()` should create a node with a key:

```dart
// Expected behavior:
final node = Node.Id("person_123");
print(node.key.value); // Should print "person_123"

// If this doesn't work, the library might be broken
```

---

### Alternative Approach:

If Node.Id() doesn't work:

```dart
// Create node manually
final node = Node();
// Try to set key directly
// Note: This depends on library API
```

---

### Check Library Version:

In pubspec.yaml:
```yaml
dependencies:
  graphview: ^1.5.1  # Check if this version works
```

---

## 📊 **Console Output Examples**

### Example 1: Successful Build
```
═══════════════════════════════════════
TREE DATA LOADED
Total nodes in state: 7
Root person: Family Root (virtual_root)
Building graph...
  Added node: ID=virtual_root, Name=Family Root, GraphNode key=virtual_root
  Added node: ID=person_001, Name=John Smith, GraphNode key=person_001
  Added child: ID=person_002, Name=Sarah Johnson, GraphNode key=person_002
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=virtual_root, ID=virtual_root
  - Node 2: key=person_001, ID=person_001
  - Node 3: key=person_002, ID=person_002
  - Node 4: key=person_003, ID=person_003
  - Node 5: key=person_004, ID=person_004
  - Node 6: key=person_005, ID=person_005
  - Node 7: key=person_006, ID=person_006
═══════════════════════════════════════
```

---

### Example 2: Broken Node Keys
```
═══════════════════════════════════════
TREE DATA LOADED
Total nodes in state: 7
Root person: Family Root (virtual_root)
Building graph...
  Added node: ID=virtual_root, Name=Family Root, GraphNode key=NULL ❌
  Added node: ID=person_001, Name=John Smith, GraphNode key=NULL ❌
Graph built with 7 nodes
Node keys in graph:
  - Node 1: key=NULL, ID=N/A ❌
  - Node 2: key=NULL, ID=N/A ❌
═══════════════════════════════════════
[Then errors flood in]
```

---

## 🔧 **Code Locations**

### Files Modified:

**tree_graph_widget.dart:**
- Line 28-41: `_buildGraph()` method
- Line 43-73: `_addNodeAndChildren()` method with debug logging
- Line 120-135: Enhanced debug output

### What Each Log Shows:

1. **"TREE DATA LOADED"** - State received from bloc
2. **"Added node"** - Individual node creation with key
3. **"Graph built with X nodes"** - Graph construction complete
4. **"Node keys in graph"** - List of all node keys
5. **"Warning: Node has null key"** - Runtime null detection

---

## 📝 **Summary**

**Issue:** Graph builds but throws null errors  
**Debug Added:** Comprehensive logging of node creation and keys  
**Next Step:** Check console to see if node keys are NULL or valid  
**Common Cause:** Node.Id() constructor not setting keys properly  

---

*Debug Guide Created: March 22, 2026*  
*Files Modified:*
- *tree_graph_widget.dart (enhanced debug logging)*
*Status: 🔍 ENHANCED DEBUG MODE ACTIVE*
