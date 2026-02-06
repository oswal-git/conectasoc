# Implementation Plan - Refactor ArticleEditPage

Created: 2026-02-03 23:32:14

Refactor `article_edit_page.dart` to improve maintainability, readability, and reusability of components.

## Proposed Changes

### Articles Feature

#### [MODIFY] [article_edit_page.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/pages/article_edit_page.dart)

1.  **Extract Quill Components**:
    - Create a reusable `_QuillEditorField` widget that encapsulates the `QuillSimpleToolbar`, the `Container` wrapper, the `QuillEditor`, and the character count display.

2.  **Extract Form Sections**:
    - Extract `buildCategorySelectors` into a `_CategorySelectorSection` widget.
    - Extract `buildStatusDropdown` into a `_StatusDropdownSection` widget.
    - Extract `buildDatePickers` into a `_DatePickerSection` widget.

3.  **Simplify Main State**:
    - Assemble the extracted widgets in `_ArticleEditViewState.buildForm`.

## Verification Plan

### Manual Verification

- Verify that Article Title and Abstract editors still work as expected.
- Verify that category selection, status switching, and date picking still work.
