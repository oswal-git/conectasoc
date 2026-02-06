# Implementation Plan - Customize Article Editor & Reduce Icon Size

Created: 2026-02-03 21:26:56

Customize the Quill editor toolbars for Article Title and Summary fields and reduce the icon size.

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
- **Icon Size Reduction**: Use `buttonOptions` in `QuillSimpleToolbarConfig` to set `iconSize` to `18.0` (reducing from default 24.0).

## Verification Plan

### Manual Verification

- Navigate to the article editor.
- Verify that the toolbars for Title and Summary don't show the excluded buttons.
- Verify that icons in the toolbar are smaller (18.0 px instead of 24.0 px).
