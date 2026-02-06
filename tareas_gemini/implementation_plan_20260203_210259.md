# Implementation Plan - Pull-to-Refresh for User List & Lint Fix

Created: 2026-02-03 21:02:59

Implement pull-to-refresh functionality on the User List screen to allow users to manually reload the list of users from the database.

## Proposed Changes

### Users Feature

#### [MODIFY] [user_list_event.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_event.dart)

- Add `RefreshUsers` event to trigger a reload.
- **Update**: Ensure `props` overrides use `List<Object?>` to fix lint errors.

#### [MODIFY] [user_list_bloc.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_bloc.dart)

- Handle `RefreshUsers` event.
- Refactor fetching logic to `_fetchUsers`.

#### [MODIFY] [user_list_page.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/pages/user_list_page.dart)

- Wrap the `ListView.builder` inside a `RefreshIndicator`.
- Implement the `onRefresh` callback to dispatch the `RefreshUsers` event.

## Verification Plan

### Manual Verification

- Navigate to the User List screen.
- Pull down the list to trigger a refresh.
- Verify that the list updates with fresh data.
- Verify that no lint errors remain in the code.
