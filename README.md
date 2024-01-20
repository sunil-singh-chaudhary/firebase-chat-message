# chat_meesage_demo

A new Flutter project.

## How To setUp Firebase

1.Go to Firebase Authentication and Enable SignIn provider for email and password 2. Go to firestore Database in firebase console check Rules and add paste below code for authroized person to only read and write permission

```bash

rules_version = '2';

service cloud.firestore {
match /databases/{database}/documents {
// Allow read and write access to all documents for authenticated users
match /{document=\*\*} {
allow read, write: if request.auth != null;
}
}
}

```bash
