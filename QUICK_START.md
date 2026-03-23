# 🌳 Kuttiyattel Family Tree - Quick Start

## 🎯 Phase 1 Status: **COMPLETE** ✅

---

## ⚡ QUICK START (5 Minutes)

### 1️⃣ Install Dependencies
```bash
flutter pub get
```

### 2️⃣ Set Up Supabase Backend

#### Create Project
1. Go to https://supabase.com
2. Sign up → Create new project
3. Name: `kuttiyattel-family-tree`
4. Wait for provisioning (~2 min)

#### Run Database Schema
1. In Supabase dashboard → **SQL Editor** → **New Query**
2. Copy content from `database_schema.sql`
3. Paste and click **Run**
4. Verify success message

#### Get Credentials
1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** 
   - **anon public key**

### 3️⃣ Configure App

Open: `lib/core/config/supabase_config.dart`

Replace placeholder values:
```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 4️⃣ Run the App
```bash
flutter run
```

---

## 📦 What's Built

### Architecture
```
✅ Feature-based structure
✅ GoRouter navigation
✅ Light/Dark/System themes
✅ Supabase backend integration
✅ BLoC state management
✅ Repository pattern
```

### Key Features
- ✅ Person List screen (home)
- ✅ Navigation to Tree, Add, Search screens
- ✅ CRUD operations ready
- ✅ Database schema with sample data

---

## 🗂️ Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/core/config/supabase_config.dart` | **EDIT THIS** with your credentials |
| `database_schema.sql` | Database setup script |
| `SETUP_GUIDE.md` | Detailed setup instructions |
| `PHASE_1_COMPLETE.md` | Complete documentation |

---

## 🎨 Current Screens

1. **Home Screen** (`/`) - Person list (placeholder)
2. **Tree Screen** (`/tree`) - Family tree (to be built in Phase 2)
3. **Add Person** (`/add-person`) - Form (to be completed)
4. **Search** (`/search`) - Search UI (to be completed)
5. **Edit Person** (`/edit-person/:id`) - Edit form (to be completed)

---

## 🔧 Next: Phase 2

**Tree Visualization** with:
- GraphView library
- InteractiveViewer (zoom + pan)
- Person cards with photos
- Real-time data from Supabase
- BuchheimWalkerAlgorithm for tree layout

---

## ❓ Troubleshooting

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Can't connect to Supabase?
- Check internet connection
- Verify credentials in `supabase_config.dart`
- Ensure tables created in Supabase

### Navigation not working?
- Hot restart (not hot reload)
- Press `R` in terminal to restart

---

## 📞 Need Help?

Read detailed docs:
- `SETUP_GUIDE.md` - Full setup guide
- `PHASE_1_COMPLETE.md` - Phase 1 details

---

**Ready for Phase 2? Make sure:**
- ✅ Supabase is set up
- ✅ App runs without errors
- ✅ You can navigate between screens

Then say: **"continue to phase 2"**
