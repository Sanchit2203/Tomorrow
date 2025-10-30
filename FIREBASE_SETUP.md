# Firebase Firestore Security Rules Configuration

## Problem
The signup is failing and unable to fetch data because Firestore is likely in production mode with restrictive security rules.

## Solution
You need to configure Firestore security rules to allow authenticated users to read and write their own data.

## Step 1: Access Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your "Tomorrow" project
3. Navigate to **Firestore Database** in the left sidebar
4. Click on the **Rules** tab

## Step 2: Update Security Rules
Replace the existing rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read other users' public profile information
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Posts collection - users can create and read posts
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
    
    // Test collection for debugging (remove in production)
    match /test/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 3: Firebase Storage Security Rules
Also update Storage rules:

1. Navigate to **Storage** in the left sidebar
2. Click on the **Rules** tab
3. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can manage their own folders
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 4: Test the Configuration
1. Install and run the app
2. Create a new account or login
3. Go to Profile → Settings → Test Firebase
4. Run the Firebase connection test
5. If successful, you should see ✅ for all tests

## Alternative: Development Mode (Temporary)
For quick testing, you can temporarily use development mode rules (NOT for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## What These Rules Do
- **Users Collection**: Users can read/write their own profile data and read others' public profiles
- **Posts Collection**: Users can create posts and read all posts, but only edit/delete their own
- **Authentication Required**: All operations require user authentication
- **Storage**: Users can only access their own storage folders

## Verification
After updating the rules:
1. Try signing up a new user
2. Check if the user document is created in Firestore
3. Verify that the profile screen shows the correct username from the database
4. Test image upload functionality

The rules ensure security while allowing the app to function properly with user authentication and data management.