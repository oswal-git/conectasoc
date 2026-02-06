# Implementation Plan - Pull-to-Refresh on Home Screen

Implement a "pull-to-refresh" mechanism on the home screen to allow users to manually reload articles and categories.

## Proposed Changes

### [Component] Home BLoC

#### [MODIFY] [home_event_bloc.dart](file:///n:/flutter/conectasoc/lib/features/home/presentation/bloc/home_event_bloc.dart)

- `LoadHomeData` already has `forceReload`. No changes expected here unless we want a dedicated `RefreshHomeData` event, but `LoadHomeData` is sufficient.

#### [MODIFY] [home_bloc.dart](file:///n:/flutter/conectasoc/lib/features/home/presentation/bloc/home_bloc.dart)

- Update `_onLoadHomeData` to avoid emitting `HomeLoading()` if the current state is already `HomeLoaded`.
- Instead, it should emit `currentState.copyWith(isLoading: true)` to allow the UI to stay visible while the refresh happens in the background.

### [Component] Home UI

#### [MODIFY] [article_list_widget.dart](file:///n:/flutter/conectasoc/lib/features/home/presentation/widgets/article_list_widget.dart)

- Wrap the `ListView.builder` with a `RefreshIndicator`.
- Implement `onRefresh` by dispatching `LoadHomeData(user: user, membership: membership, forceReload: true)`.
- Wait for the BLoC state to change back to `isLoading: false` or similar to complete the `onRefresh` future.

### [Component] User List Refresh

#### [MODIFY] [user_list_state.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_state.dart)

- Add `isLoading` boolean to `UserListLoaded` to track background refreshes.

#### [MODIFY] [user_list_bloc.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/bloc/list/user_list_bloc.dart)

- Update `_onRefreshUsers` to emit `currentState.copyWith(isLoading: true)` before fetching data.
- Ensure `_fetchUsers` resets `isLoading` to `false`.

#### [MODIFY] [user_list_page.dart](file:///n:/flutter/conectasoc/lib/features/users/presentation/pages/user_list_page.dart)

- Update `onRefresh` logic to wait for `!isLoading`.
- Use `AlwaysScrollableScrollPhysics` in `ListView` to ensure refresh works on empty or short lists.

### [Component] Association List Refresh

#### [MODIFY] [association_state.dart](file:///n:/flutter/conectasoc/lib/features/associations/presentation/bloc/association_state.dart)

- Add `isLoading` boolean to `AssociationsLoaded` state.

#### [MODIFY] [association_event.dart](file:///n:/flutter/conectasoc/lib/features/associations/presentation/bloc/association_event.dart)

- Add `RefreshAssociations` event.

#### [MODIFY] [association_bloc.dart](file:///n:/flutter/conectasoc/lib/features/associations/presentation/bloc/association_bloc.dart)

- Update `AssociationBloc` to handle `RefreshAssociations`.
- Emit `currentState.copyWith(isLoading: true)` during refresh.
- Reset `isLoading` to `false` when data is loaded.

#### [MODIFY] [association_list_page.dart](file:///n:/flutter/conectasoc/lib/features/associations/presentation/pages/association_list_page.dart)

- Wrap `ListView.builder` with `RefreshIndicator`.
- Implement `onRefresh` to dispatch `RefreshAssociations` and wait for completion.
- Use `AlwaysScrollableScrollPhysics`.

### [Component] Role-Based Access Control (RBAC) for Articles

#### [NEW] [article_permissions.dart](file:///n:/flutter/conectasoc/lib/core/utils/article_permissions.dart)

- Implement `ArticlePermissions.canEdit(article, user, membership)` to centralize the rules:
    - `superadmin`: Can edit everything.
    - `admin`: Can edit articles of their own association (`assocId` match).
    - `editor`: Can only edit articles of their own association (`assocId` match) AND that they created (`userId` match).
    - `asociado`: Cannot edit.
    - General articles (`assocId == ''`): Only `superadmin` can edit.

#### [MODIFY] [article_card_widget.dart](file:///n:/flutter/conectasoc/lib/features/home/presentation/widgets/article_card_widget.dart)

- Use `ArticlePermissions.canEdit` to conditionally show the Edit button.

#### [MODIFY] [article_edit_bloc.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/bloc/edit/article_edit_bloc.dart)

- Use `ArticlePermissions.canEdit` in `_onLoadArticleForEdit` to prevent unauthorized loads.
- Use `ArticlePermissions.canEdit` in `_onSaveArticle` as a secondary safeguard.

#### [MODIFY] [auth_remote_datasource.dart](file:///n:/flutter/conectasoc/lib/features/auth/data/datasources/auth_remote_datasource.dart)

- Update `signInWithEmailOnly` to include `lastLoginDate` update in Firestore.

### [Component] Superadmin UI and Creation Fixes

#### [MODIFY] [auth_bloc.dart](file:///n:/flutter/conectasoc/lib/features/auth/presentation/bloc/auth_bloc.dart)

- Filter `superadmin_access` out of memberships when determining `currentMembership` in `_onAuthCheckRequested` to prevent "Unknown Association" errors on restart.

#### [MODIFY] [article_edit_bloc.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/bloc/edit/article_edit_bloc.dart)

- Allow `currentMembership` to be null for superadmins in `_onPrepareArticleCreation`.
- Use empty strings for `assocId` and `associationShortName` when creating general articles as a superadmin.

#### [MODIFY] [home_page_view_widget.dart](file:///n:/flutter/conectasoc/lib/features/home/presentation/widgets/home_page_view_widget.dart)

- Improved labeling logic to ensure "Todas" remains stable for superadmins with no association selected.

### [Component] Article Visibility Rules

#### [MODIFY] [article_repository.dart](file:///n:/flutter/conectasoc/lib/features/articles/data/repositories/article_repository_impl.dart)

- **Edit Mode Logic Refinement**:
    - **Superadmin**: Bypass all `assocId` filters (already implemented/verify).
    - **Admin**: Fetch by `assocId` IN memberships. Post-filter: None (sees all in assoc).
    - **Editor**: Fetch by `assocId` IN memberships. Post-filter: Keep only if `article.userId == user.uid`.
- **Read Mode Logic Update (Superadmin)**:
    - Allow Superadmin to see ALL published articles regardless of membership to ensure newly created content is visible.

## Verification Plan

### Manual Verification

- Launch the app and go to the Home screen.
- Perform a pull-down gesture on the article list.
- Verify the `RefreshIndicator` appears and stays until the data is loaded.
- Verify that the list updates with fresh data from the database.
- Ensure the whole screen doesn't clear (no full-screen spinner) during the manual refresh.
