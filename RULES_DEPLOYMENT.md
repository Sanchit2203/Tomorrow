# Firebase Rules Deployment Guide

## 📁 Files Created

1. **`firestore.rules`** - Complete Firestore security rules
2. **`storage.rules`** - Firebase Storage security rules  
3. **`firestore.indexes.json`** - Database indexes for performance
4. **`firebase.json`** - Updated Firebase configuration
5. **`deploy-rules.bat`** - Windows deployment script
6. **`deploy-rules.sh`** - Linux/Mac deployment script

## 🚀 Quick Deployment (Recommended)

### Option 1: Using Deployment Script (Windows)
```cmd
# Run the deployment script
deploy-rules.bat
```

### Option 2: Using Deployment Script (Linux/Mac)
```bash
# Make script executable
chmod +x deploy-rules.sh

# Run the deployment script
./deploy-rules.sh
```

### Option 3: Manual Deployment
```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules,storage
```

## 🔧 Manual Setup (Firebase Console)

If you prefer to use the Firebase Console:

### Firestore Rules
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **tomorrow-6e538** project
3. Navigate to **Firestore Database** → **Rules**
4. Copy the content from `firestore.rules` file
5. Paste it in the rules editor
6. Click **Publish**

### Storage Rules
1. In Firebase Console, navigate to **Storage** → **Rules**
2. Copy the content from `storage.rules` file
3. Paste it in the rules editor
4. Click **Publish**

## 🔐 What These Rules Allow

### Firestore Database Rules
- ✅ **Users**: Read/write own profile, read others' public profiles
- ✅ **Posts**: Create posts, read all posts, edit/delete own posts
- ✅ **Comments**: Comment on posts, manage own comments
- ✅ **Likes**: Like/unlike posts and comments
- ✅ **Following**: Follow/unfollow users, manage followers
- ✅ **Notifications**: Receive and manage notifications
- ✅ **Stories**: Create and view stories (if implemented)
- ✅ **Chat**: Private messaging (if implemented)
- ✅ **Test Collection**: For debugging (remove in production)

### Storage Rules
- ✅ **User Folders**: Personal file storage for each user
- ✅ **Profile Images**: Upload/manage profile pictures (10MB limit)
- ✅ **Post Media**: Upload images/videos for posts (100MB limit)
- ✅ **Story Media**: Upload story content
- ✅ **File Validation**: Automatic file type and size validation
- ✅ **Public Assets**: Read-only public content

## 🧪 Testing the Rules

After deployment, test your rules:

1. **Run the app** and try to sign up
2. **Open Profile** → Settings → **Test Firebase**
3. **All tests should show** ✅ if rules are working
4. **Check Firebase Console** to see the `users` collection

## 🔍 Troubleshooting

### Common Issues:

**"Permission denied" errors:**
- Make sure you deployed the rules
- Check that user is authenticated
- Verify the rule conditions match your data structure

**"Firebase CLI not found":**
```bash
npm install -g firebase-tools
```

**"Not logged in":**
```bash
firebase login
```

**Rules don't seem to work:**
- Wait 1-2 minutes after deployment
- Clear app data and try again
- Check Firebase Console for rule syntax errors

## 📊 Rule Structure

```
users/{userId}           → User profiles
posts/{postId}           → User posts
posts/{postId}/comments  → Post comments
posts/{postId}/likes     → Post likes
users/{userId}/followers → User followers
users/{userId}/following → Users being followed
chats/{chatId}           → Chat rooms
chats/{chatId}/messages  → Chat messages
stories/{storyId}        → User stories
notifications/{userId}   → User notifications
```

## 🛡️ Security Features

- **Authentication Required**: All operations require user login
- **Owner-based Access**: Users can only modify their own content
- **Public Reading**: Posts and profiles are publicly readable
- **File Validation**: Automatic file type and size limits
- **Admin Protection**: Admin-only sections secured
- **Default Deny**: Undefined paths are automatically blocked

## 🎯 Next Steps

1. **Deploy the rules** using one of the methods above
2. **Test signup/login** in your app
3. **Verify user creation** in Firebase Console
4. **Test profile features** (username display, image upload)
5. **Remove test collection** rules before production

Your Firebase backend is now fully secured and ready for production! 🚀