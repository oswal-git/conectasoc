# Implementation Plan - Customize Article Editor

Created: 2026-02-03 21:20:58

Customize the Quill editor toolbars for Article Title and Summary fields to exclude specific options and set default text styles.

## Proposed Changes

### Articles Feature

#### [MODIFY] [article_edit_page.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/pages/article_edit_page.dart)

- Update `QuillSimpleToolbarConfig` for both `_titleController` and `_abstractController`.
- Set the following options to `false`:
    - `showCodeBlock`
    - `showListBullets`
    - `showListNumbers`
    - `showListCheck`
    - `showIndent`
    - `showQuote`
    - `showLink`
    - `showClearFormat`
    - `showHeaderStyle` (to hide the header selector)
- Ensure the Title is set to **Header 1** by default.
- Ensure the Summary is set to **Normal** by default.

## Verification Plan

### Manual Verification

- Navigate to the article creation/edition page.
- Verify that the toolbars for Title and Summary do not show the excluded buttons.
- Verify that the style selector is hidden in both toolbars.
- Verify that new Titles are created with Header 1 style.
- Verify that new Summaries are created with Normal style.
