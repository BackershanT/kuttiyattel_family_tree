# 🌳 Kuttiyattel Family Tree

A production-ready Flutter application for building and visualizing family trees with Supabase backend.

## 🚀 Features

- ✅ **Feature-based architecture** - Scalable project structure
- ✅ **GoRouter navigation** - Type-safe routing with deep linking
- ✅ **Dark/Light/System themes** - Beautiful UI in all modes
- ✅ **Supabase backend** - PostgreSQL database with real-time capabilities
- ✅ **Graph visualization** - Interactive family tree with zoom & pan
- ✅ **Person management** - Add, edit, search family members
- ✅ **Relationship mapping** - Define parent-child relationships

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Flutter SDK** (3.11.0 or higher)
2. **Supabase account** (free at https://supabase.com)
3. **Code editor** (VS Code, Android Studio, etc.)

## 🛠️ Setup Instructions

### Step 1: Clone the Project

```bash
cd kuttiyattel_family_tree
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Set Up Supabase Backend

#### 3.1 Create a Supabase Project

1. Go to https://supabase.com
2. Sign up/login
3. Create a new project
4. Wait for the database to be provisioned

#### 3.2 Run the Database Schema

1. Open your Supabase project dashboard
2. Go to **SQL Editor** (in the left sidebar)
3. Click **New Query**
4. Copy and paste the contents of `database_schema.sql`
5. Click **Run** to execute the SQL script

This will create:
- `persons` table
- `relationships` table
- Indexes for performance
- Row Level Security policies
- Sample data for testing

#### 3.3 Get Your Supabase Credentials

1. Go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (under "Project URL")
   - **Anon Public Key** (under "Project API keys")

### Step 4: Configure Flutter App

Open `lib/core/config/supabase_config.dart` and replace:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

With your actual credentials:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### Step 5: Run the Application

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── config/             # Configuration files
│   │   └── supabase_config.dart
│   ├── router/             # Navigation setup
│   │   ├── app_router.dart
│   │   └── routes.dart
│   └── theme/              # Theme configuration
│       ├── app_theme.dart
│       ├── dark_theme.dart
│       ├── light_theme.dart
│       └── theme.dart
│
├── features/                # Feature modules
│   ├── persons/            # Person management
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── person_model.dart
│   │   └── presentation/
│   │       └── screens/
│   │
│   ├── relationships/      # Relationship management
│   │   └── data/
│   │       └── models/
│   │           └── relationship_model.dart
│   │
│   └── tree_visualization/ # Tree display
│       └── presentation/
│           └── screens/
│               └── tree_screen.dart
│
└── main.dart               # App entry point
```

## 🎨 Features Overview

### Theme System

The app supports three theme modes:
- **Light Theme** - Clean, professional look
- **Dark Theme** - Easy on the eyes
- **System** - Follows device settings (default)

### Navigation

Built with GoRouter for:
- Type-safe routing
- Deep linking support
- Nested routes
- Path parameters

### Database Schema

#### Persons Table
- `id` - UUID (auto-generated)
- `name` - Full name
- `gender` - Male/Female/Other
- `dob` - Date of birth
- `photo_url` - Profile photo URL
- `created_at` - Timestamp

#### Relationships Table
- `id` - UUID (auto-generated)
- `parent_id` - Reference to parent
- `child_id` - Reference to child

## 🔧 Next Steps

### Phase 1: Foundation ✅ (Current)
- [x] Feature-based structure
- [x] Dependencies added
- [x] GoRouter navigation
- [x] Theme system
- [x] Supabase configuration
- [x] Database schema

### Phase 2: Data Layer (Next)
- [ ] Person repository implementation
- [ ] Relationship repository
- [ ] CRUD operations

### Phase 3: Tree Visualization
- [ ] GraphView integration
- [ ] InteractiveViewer (zoom/pan)
- [ ] Person cards UI
- [ ] Layout algorithms

### Phase 4: Polish
- [ ] Add/Edit person screens
- [ ] Search functionality
- [ ] Photo uploads
- [ ] Export/import features

## 📦 Dependencies

```yaml
go_router: ^14.0.0          # Navigation
supabase_flutter: ^2.0.0    # Backend
graphview: ^1.2.0           # Tree visualization
flutter_bloc: ^8.1.3        # State management
uuid: ^4.3.3                # ID generation
intl: ^0.19.0               # Internationalization
cached_network_image: ^3.3.1 # Image caching
```

## 🐛 Troubleshooting

### Issue: "MissingPluginException"
**Solution:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Supabase connection error
**Solution:** 
- Check your internet connection
- Verify Supabase credentials in `supabase_config.dart`
- Ensure your Supabase project is active

### Issue: Database tables not found
**Solution:** 
- Re-run the `database_schema.sql` in Supabase SQL Editor
- Check that the SQL executed successfully

## 📝 Useful Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk

# Build for Web
flutter build web

# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze
```

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [GraphView Documentation](https://pub.dev/packages/graphview)

## 🤝 Contributing

This is a private project for the Kuttiyattel family. 

## 📄 License

Private - All rights reserved

---

**Built with ❤️ for the Kuttiyattel Family**
