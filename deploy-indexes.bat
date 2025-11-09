@echo off
echo Deploying Firestore indexes...
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Firebase CLI is not installed or not in PATH
    echo Please install Firebase CLI first: npm install -g firebase-tools
    echo.
    pause
    exit /b 1
)

REM Check if user is logged in
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo You need to login to Firebase first
    echo Running: firebase login
    firebase login
)

REM Deploy indexes
echo Deploying Firestore indexes...
firebase deploy --only firestore:indexes

if %errorlevel% equ 0 (
    echo.
    echo ✅ Firestore indexes deployed successfully!
    echo.
    echo The following indexes have been created:
    echo - posts: authorId + createdAt
    echo - posts: authorId + createdAt + __name__
    echo - posts: isPublic + createdAt
    echo - posts: hashtags (array) + createdAt
    echo - stories: expiresAt + isActive + createdAt
    echo - stories: authorId + createdAt
    echo - users: username
    echo - comments: postId + createdAt
    echo - notifications: userId + read + createdAt
    echo.
    echo Your app should now work without index errors!
) else (
    echo.
    echo ❌ Failed to deploy indexes
    echo Please check the error messages above
)

echo.
pause