# Implementation Plan - Pull-to-Refresh for User List

Created: 2026-02-03 20:56:28

Implement pull-to-refresh functionality on the User List screen to allow users to manually reload the list of users from the database.

## Proposed Changes

### Users Feature

#### [MODIFY] [user_list_event.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_event.dart)

- Add `RefreshUsers` event to trigger a reload without showing the full-screen loading state if possible (or just to be explicitly triggered by the `RefreshIndicator`).

#### [MODIFY] [user_list_bloc.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_bloc.dart)

- Handle `RefreshUsers` event.
- It will reuse the logic from `_onLoadUsers` but might avoid emitting `UserListLoading` if we want a smoother experience. However, since the user explicitly said "volviendo a acceder a BBDD", I will ensure it calls the same use cases.

#### [MODIFY] [user_list_page.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/pages/user_list_page.dart)

- Wrap the `ListView.builder` inside a `RefreshIndicator`.
- Implement the `onRefresh` callback to dispatch the `RefreshUsers` event and wait for completion.

## Verification Plan

### Manual Verification

- Navigate to the User List screen.
- Pull down the list to trigger a refresh.
- Verify that the loading indicator appears at the top.
- Verify that the list updates with fresh data from the database.
- Verify that searching and sorting still work as expected after a refresh.
