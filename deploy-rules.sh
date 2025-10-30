#!/bin/bash

# Firebase Rules Deployment Script for Tomorrow App
# This script helps deploy Firestore and Storage security rules

echo "🔥 Firebase Rules Deployment for Tomorrow App"
echo "=============================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo "📥 Please install Firebase CLI first:"
    echo "   npm install -g firebase-tools"
    echo "   or"
    echo "   curl -sL https://firebase.tools | bash"
    echo ""
    exit 1
fi

echo "✅ Firebase CLI found"

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 Please login to Firebase first:"
    echo "   firebase login"
    echo ""
    exit 1
fi

echo "✅ Firebase authentication verified"

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo "⚠️  firebase.json not found. Initializing Firebase project..."
    firebase init firestore storage
fi

# Deploy Firestore rules
echo ""
echo "📤 Deploying Firestore rules..."
if firebase deploy --only firestore:rules; then
    echo "✅ Firestore rules deployed successfully!"
else
    echo "❌ Failed to deploy Firestore rules"
    exit 1
fi

# Deploy Storage rules
echo ""
echo "📤 Deploying Storage rules..."
if firebase deploy --only storage; then
    echo "✅ Storage rules deployed successfully!"
else
    echo "❌ Failed to deploy Storage rules"
    exit 1
fi

echo ""
echo "🎉 All rules deployed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Test your app signup process"
echo "2. Go to Profile → Settings → Test Firebase"
echo "3. Verify all tests pass with ✅"
echo ""
echo "🔗 View your rules in Firebase Console:"
echo "   https://console.firebase.google.com/project/$(firebase use --print)/firestore/rules"
echo "   https://console.firebase.google.com/project/$(firebase use --print)/storage/rules"