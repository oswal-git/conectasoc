# Implementation Plan - Customize Article Editor & Compact Toolbar

Created: 2026-02-03 21:47:26

Customize the Quill editor toolbars for Article Title and Summary fields, including compact icons and reduced line spacing.

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
- **Icon Size Reduction**: Use `buttonOptions` in `QuillSimpleToolbarConfig` to set `iconSize` to `parIconSize` (currently 12.0).
- **Toolbar Spacing Reduction**: Use `toolbarRunSpacing: 0`, `toolbarSectionSpacing: 0`, and `toolbarIconOuterPadding: const EdgeInsets.all(0)` in `QuillSimpleToolbarConfig` to minimize vertical space between icon rows.

## Verification Plan

### Manual Verification

- Navigate to the article editor.
- Verify that icons in the toolbar are smaller.
- Verify that the vertical spacing between rows of icons is minimized.
