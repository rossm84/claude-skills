---
name: firestore-field-level-rules
description: Use when writing Firestore security rules that need per-field access control — e.g. only creator can edit config but anyone can modify a subscribers list, or specific fields must be immutable after creation
---

# Firestore Field-Level Update Restrictions

## Overview

Firestore security rules can restrict which fields a user is allowed to modify on update using `request.resource.data.diff(resource.data).affectedKeys()`. This enables patterns like "anyone can subscribe but only the creator can edit config."

## Quick Reference

| Pattern | Rule |
|---------|------|
| Only these fields changed | `.affectedKeys().hasOnly(['field1', 'field2'])` |
| These fields must be changed | `.affectedKeys().hasAll(['required1'])` |
| Exactly these fields | `.hasOnly()` AND `.hasAll()` combined |
| Field not changed | `!.affectedKeys().hasAny(['immutable'])` |
| Creator can edit all, others limited | `resource.data.createdBy == email \|\| .affectedKeys().hasOnly(['subscribers'])` |

## Core Pattern

```
// The diff between new and old data
request.resource.data.diff(resource.data).affectedKeys()
```

Returns a `Set` of field names that changed. Use `hasOnly()`, `hasAll()`, `hasAny()` to constrain.

## Common Patterns

### Creator edits all, others edit one field
```javascript
match /schedules/{id} {
  allow update: if isApprovedUser()
    && (resource.data.createdBy == request.auth.token.email
        || request.resource.data.diff(resource.data)
           .affectedKeys().hasOnly(['subscribers']));
}
```

### Immutable fields after creation
```javascript
match /logs/{id} {
  allow create: if isApprovedUser();
  allow update: if isApprovedUser()
    && !request.resource.data.diff(resource.data)
        .affectedKeys().hasAny(['createdBy', 'createdAt', 'type']);
}
```

### Status field only moves forward
```javascript
match /tasks/{id} {
  allow update: if isApprovedUser()
    && request.resource.data.diff(resource.data)
       .affectedKeys().hasOnly(['status'])
    && request.resource.data.status in ['in_progress', 'completed']
    && (resource.data.status != 'completed');  // Can't un-complete
}
```

### Array subscribe/unsubscribe only
```javascript
// Frontend uses arrayUnion/arrayRemove:
// updateDoc(ref, { subscribers: arrayUnion(email) })
// This only modifies 'subscribers', so hasOnly(['subscribers']) passes
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `merge: true` with `setDoc` | Sends ALL fields in the object, not just changed ones. `affectedKeys()` may include unchanged fields that were re-sent with the same value. Test carefully. |
| Forgetting `affectedKeys` checks nested fields | It only checks top-level fields. Nested changes (e.g. `config.theme`) show as `config` being modified. |
| `hasOnly` vs `hasAll` confusion | `hasOnly(['a','b'])` = only a and/or b changed (could be just a). `hasAll(['a','b'])` = both a AND b must have changed. |
| Not testing with Firestore emulator | Field-level rules are tricky. Use `firebase emulators:start` to test before deploying. |

## Deployment

```bash
# Deploy rules to all databases
firebase deploy --only firestore:rules

# Deploy to specific database
firebase deploy --only firestore:rules --database=firestorenative
```

Rules apply to **client SDK only** (web, mobile). Server-side Admin SDK / `google-cloud-firestore` Python client bypasses all rules.
