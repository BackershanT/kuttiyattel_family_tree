# 🚀 PHASE 3 QUICK REFERENCE GUIDE

## 📋 What's New in Phase 3

### **New Screens**
- ✅ Add Person Screen - Complete form with photo upload
- ✅ Edit Person Screen - Update data & delete persons
- ✅ Person Details Screen - Beautiful profile view
- ✅ Search Screen - Real-time filtering
- ✅ Enhanced Person List - Swipe to delete

### **New Widgets**
- `GenderSelector` - Segmented button (Male/Female/Other)
- `DatePickerWidget` - Birth date picker
- `PhotoUploadWidget` - Camera/Gallery upload to Supabase
- `PersonFormWidget` - Reusable complete form

### **New Features**
1. **Photo Upload**
   - Take photo or pick from gallery
   - Upload to Supabase Storage
   - Cached display in avatars

2. **Swipe Actions**
   - Swipe left on list item → Delete confirmation

3. **Real-time Search**
   - Type to filter by name
   - 300ms debounce for performance

4. **Enhanced UI**
   - Gender-based colors (Blue/Pink/Purple)
   - Gradient backgrounds
   - Material 3 design

---

## ⚡ Quick Start

### **1. Install Dependencies**
```bash
flutter pub get
```

### **2. Set Up Supabase Storage**

In Supabase Dashboard:
1. Go to **Storage**
2. Create bucket: `person-photos`
3. Make it **public**
4. Add policies:

```sql
-- Allow uploads
CREATE POLICY "Allow authenticated users to upload photos"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'person-photos');

-- Allow reads
CREATE POLICY "Allow authenticated users to read photos"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'person-photos');
```

### **3. Run the App**
```bash
flutter run
```

---

## 🎯 Feature Testing Guide

### **Add Person**
1. Tap **+ Add Person** FAB
2. Fill form:
   - Name (required, min 2 chars)
   - Gender (segmented button)
   - Birth date (optional)
   - Photo (tap avatar)
3. Tap **Save**
4. Confirm in dialog
5. Success! → Back to list

### **Edit Person**
1. Tap person card → Details
2. Tap **Edit** icon
3. Modify fields
4. Tap **Save Changes**
5. Confirm

### **Delete Person**
**Method 1:** Swipe left on list item  
**Method 2:** Details screen → Delete icon

### **Search**
1. Tap **Search** icon
2. Type name
3. Results filter automatically
4. Tap result → View details

### **View Details**
1. Tap any person card
2. See beautiful profile with:
   - Large photo
   - Name, gender badge
   - Birth date
   - Edit/Delete buttons

---

## 🗂️ File Structure

```
lib/features/persons/
├── presentation/
│   ├── screens/
│   │   ├── add_person_screen.dart      ⭐ NEW
│   │   ├── edit_person_screen.dart     ⭐ NEW
│   │   ├── person_details_screen.dart  ⭐ NEW
│   │   ├── search_screen.dart          ⭐ NEW
│   │   └── person_list_screen.dart     ⭐ ENHANCED
│   │
│   └── widgets/
│       ├── widgets.dart                ⭐ NEW (export)
│       ├── gender_selector_widget.dart ⭐ NEW
│       ├── date_picker_widget.dart     ⭐ NEW
│       ├── photo_upload_widget.dart    ⭐ NEW
│       └── person_form_widget.dart     ⭐ NEW
│
└── data/
    └── repositories/
        └── person_repository.dart      ✏️ UPDATED

lib/features/relationships/
└── data/
    └── repositories/
        └── relationship_repository.dart ⭐ NEW
```

---

## 🔧 Technical Details

### **BLoC Events**
```dart
AddPersonEvent(name, gender, dob, photoUrl)
UpdatePersonEvent(id, name, gender, dob, photoUrl)
DeletePersonEvent(id)
SearchPersonsEvent(query)
```

### **Repository Methods**
```dart
// PersonRepository
getAllPersons()
getPersonById(id)
addPerson(name, gender, dob, photoUrl)
updatePerson(id, name, gender, dob, photoUrl)
deletePerson(id)
searchPersons(query)

// RelationshipRepository
getAllRelationships()
getRelationshipsByParentId(parentId)
getRelationshipsByChildId(childId)
addRelationship(parentId, childId)
deleteRelationship(id)
deleteRelationshipByPair(parentId, childId)
```

### **Routes**
```dart
'/'                    → Person List
'/add-person'          → Add Person
'/search'              → Search
'/tree'                → Tree Visualization
'/edit-person/:id'     → Edit Person
'/person-details/:id'  → Person Details
```

---

## 🎨 Design System

### **Gender Colors**
```dart
Male:   Colors.blue.shade50
Female: Colors.pink.shade50
Other:  Colors.purple.shade50
```

### **UI Components**
- Cards: Elevation 2, Radius 12
- Avatars: Radius 30
- Gradients: Left to right (gender color → white)
- Badges: Rounded, gender-colored

---

## 🐛 Common Issues & Solutions

### **Photo Upload Fails**
**Problem:** Storage bucket not created  
**Solution:** Create `person-photos` bucket in Supabase Storage

### **Search Not Filtering**
**Problem:** BLoC event not triggered  
**Solution:** Check debounce timer, hot restart app

### **Swipe Delete Not Working**
**Problem:** Missing unique key  
**Solution:** Use `Key(person.id)` for Dismissible

### **Navigation Crashes**
**Problem:** Wrong route parameter  
**Solution:** Use `/edit-person/$id` format

---

## 📊 Phase Status

```
✅ Phase 1: FOUNDATION          - COMPLETE (100%)
✅ Phase 2: TREE VISUALIZATION   - COMPLETE (100%)
✅ Phase 3: PERSON MANAGEMENT    - COMPLETE (100%)
⏳ Phase 4: RELATIONSHIPS UI     - PENDING (0%)
⏳ Phase 5: POLISH               - PENDING (0%)
```

---

## 🎯 Next Steps

### **Phase 4: Relationship Management UI**
- Add parent-child relationships
- Visual relationship editor
- Validate relationship rules
- Show family connections

### **What You Need to Do**
1. Test all Phase 3 features
2. Set up Supabase Storage bucket
3. Add sample data
4. Verify photo uploads work

---

## 📞 Support Resources

- **Supabase Storage**: https://supabase.com/docs/guides/storage
- **Image Picker**: https://pub.dev/packages/image_picker
- **GoRouter**: https://pub.dev/packages/go_router
- **BLoC Library**: https://bloclibrary.dev

---

## ✅ Success Checklist

Before Phase 4, ensure:

- [ ] All dependencies installed
- [ ] Supabase Storage bucket created
- [ ] Can add person with photo
- [ ] Can edit existing person
- [ ] Can delete (swipe/button)
- [ ] Search filters correctly
- [ ] Details screen displays properly
- [ ] Navigation works smoothly
- [ ] Error states show messages
- [ ] Success feedback appears

---

**Ready for Phase 4? Say "continue to phase 4"!**

---

**Current Status:** Phase 3 ✅ COMPLETE  
**Next:** Phase 4 - Relationship Management UI
