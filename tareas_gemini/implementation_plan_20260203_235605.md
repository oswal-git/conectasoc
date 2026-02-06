# Implementation Plan - One Class Per File Refactoring

The goal is to follow the user's preference for splitting each widget class into its own file within the `lib/features/articles/presentation/widgets/article_edit/` directory.

## Proposed Changes

### [Component] Article Edit Widgets

Split the existing grouped files into individual files:

#### [MODIFY] [article_edit_page.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/pages/article_edit_page.dart)

- Update imports to use a new barrel file or specific widget files.

#### [NEW] [category_selector_section.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/category_selector_section.dart)

- Extracted from `article_form_sections.dart`.

#### [NEW] [status_dropdown_section.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/status_dropdown_section.dart)

- Extracted from `article_form_sections.dart`.

#### [NEW] [date_picker_section.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/date_picker_section.dart)

- Extracted from `article_form_sections.dart`.

#### [NEW] [cover_image_picker.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/cover_image_picker.dart)

- Extracted from `article_form_sections.dart`.

#### [NEW] [date_picker_field.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/date_picker_field.dart)

- Extracted from `article_form_sections.dart`.

#### [NEW] [article_preview.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_preview.dart)

- Extracted from `article_preview_widgets.dart`.

#### [NEW] [preview_section.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/preview_section.dart)

- Extracted from `article_preview_widgets.dart`.

#### [NEW] [section_list.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/section_list.dart)

- Extracted from `article_section_widgets.dart`.

#### [NEW] [article_section_editor.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_section_editor.dart)

- Extracted from `article_section_widgets.dart`.

#### [NEW] [article_quill_editor_field.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_quill_editor_field.dart)

- Extracted from `article_quill_editor.dart`.

#### [NEW] [section_image.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/section_image.dart)

- Extracted from `article_quill_editor.dart`.

#### [NEW] [article_edit_widgets.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_edit_widgets.dart)

- Barrel file exporting all the above widgets.

#### [DELETE] [article_form_sections.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_form_sections.dart)

- Grouped file removed.

#### [DELETE] [article_preview_widgets.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_preview_widgets.dart)

- Grouped file removed.

#### [DELETE] [article_section_widgets.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_section_widgets.dart)

- Grouped file removed.

#### [DELETE] [article_quill_editor.dart](file:///n:/flutter/conectasoc/lib/features/articles/presentation/widgets/article_edit/article_quill_editor.dart)

- Grouped file removed.

## Verification Plan

### Automated Tests

- Fix any compilation or lint errors arising from broken imports.
- Run `flutter analyze` locally if tools permit.

### Manual Verification

- Verify that the Article Editor still functions exactly as before (Preview, Form, Image picking, etc.).
