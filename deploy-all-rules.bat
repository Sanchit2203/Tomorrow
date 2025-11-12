@echo off
echo Deploying Firebase rules...

echo.
echo Deploying Firestore rules...
firebase deploy --only firestore:rules

echo.
echo Deploying Storage rules...
firebase deploy --only storage

echo.
echo Deployment complete!
pause