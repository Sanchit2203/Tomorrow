# Firestore Index Deployment Guide

## Problem
Your app is showing the error: "The query requires an index" when trying to load posts. This happens because Firestore requires composite indexes for queries that filter or sort by multiple fields.

## Solution
We've updated the `firestore.indexes.json` file with all necessary indexes for your app.

## Quick Fix - Option 1: Auto-Deploy Indexes

1. **Run the deployment script:**
   ```bash
   # Windows
   deploy-indexes.bat
   
   # Or manually
   firebase deploy --only firestore:indexes
   ```

2. **Wait for deployment** (usually takes 5-15 minutes)

3. **Test your app** - the error should be resolved

## Quick Fix - Option 2: Use Firebase Console Link

Click the link provided in the error message to create the index directly:
```
https://console.firebase.google.com/v1/r/project/tomorrow-6e538/firestore/indexes?create_composite=...
```

## What Indexes Were Added

### Posts Collection
- **authorId + createdAt**: For user's posts in profile
- **authorId + createdAt + __name__**: For paginated user posts
- **isPublic + createdAt**: For public feed posts
- **hashtags + createdAt**: For hashtag searches

### Stories Collection  
- **expiresAt + isActive + createdAt**: For active stories feed
- **authorId + createdAt**: For user's stories

### Other Collections
- **users.username**: For user searches
- **comments.postId + createdAt**: For post comments
- **notifications.userId + read + createdAt**: For user notifications

## Verification Steps

After deployment:

1. **Check Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project `tomorrow-6e538`
   - Navigate to Firestore → Indexes
   - Verify all indexes show "Enabled" status

2. **Test your app:**
   - Try loading posts in profile screen
   - Try loading feed in dashboard
   - Try creating new posts
   - All should work without errors

## Troubleshooting

### If deployment fails:
```bash
# Login to Firebase
firebase login

# Check current project
firebase projects:list

# Use correct project
firebase use tomorrow-6e538

# Deploy again
firebase deploy --only firestore:indexes
```

### If you get permission errors:
- Make sure you're logged in as the project owner
- Check that you have edit permissions on the Firebase project

### If indexes take too long:
- Large collections can take 30+ minutes to index
- Check Firebase Console for progress
- Your app may show errors until indexing completes

## Prevention

To avoid future index issues:
1. Always test new queries in development first
2. Add indexes to `firestore.indexes.json` before deploying new features
3. Use the Firebase emulator for local development

## Next Steps

After fixing the indexes, consider:
1. Testing the complete user flow
2. Deploying security rules if not done yet
3. Setting up monitoring for query performance