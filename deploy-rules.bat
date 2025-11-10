@echo off
REM Firebase Rules and Indexes Deployment Script for Tomorrow App (Windows)
REM This script helps deploy Firestore rules, indexes, and Storage security rules

echo 🔥 Firebase Rules and Indexes Deployment for Tomorrow App
echo ========================================================

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found!
    echo 📥 Please install Firebase CLI first:
    echo    npm install -g firebase-tools
    echo.
    pause
    exit /b 1
)

echo ✅ Firebase CLI found

REM Check if user is logged in
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔐 Please login to Firebase first:
    echo    firebase login
    echo.
    pause
    exit /b 1
)

echo ✅ Firebase authentication verified

REM Check if firebase.json exists
if not exist firebase.json (
    echo ⚠️  firebase.json not found. Initializing Firebase project...
    firebase init firestore storage
)

REM Deploy Firestore rules
echo.
echo 📤 Deploying Firestore rules...
firebase deploy --only firestore:rules
if %errorlevel% neq 0 (
    echo ❌ Failed to deploy Firestore rules
    pause
    exit /b 1
)
echo ✅ Firestore rules deployed successfully!

REM Deploy Firestore indexes
echo.
echo 📤 Deploying Firestore indexes...
firebase deploy --only firestore:indexes
if %errorlevel% neq 0 (
    echo ❌ Failed to deploy Firestore indexes
    pause
    exit /b 1
)
echo ✅ Firestore indexes deployed successfully!

REM Deploy Storage rules
echo.
echo 📤 Deploying Storage rules...
firebase deploy --only storage
if %errorlevel% neq 0 (
    echo ❌ Failed to deploy Storage rules
    pause
    exit /b 1
)
echo ✅ Storage rules deployed successfully!

echo.
echo 🎉 All rules and indexes deployed successfully!
echo.
echo 📋 Next steps:
echo 1. Test your app signup process
echo 2. Test time capsule scheduled posts
echo 3. Go to Profile → Settings → Test Firebase
echo 4. Verify all tests pass with ✅
echo.
echo 🔗 View your configuration in Firebase Console:
echo    Rules: https://console.firebase.google.com/project/[PROJECT]/firestore/rules
echo    Indexes: https://console.firebase.google.com/project/[PROJECT]/firestore/indexes
echo    Storage: https://console.firebase.google.com/project/[PROJECT]/storage/rules

pause