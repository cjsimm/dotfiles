---
name: Edit selection in place
interaction: inline
description: Apply a custom change to the visual selection
opts:
  alias: edit_selection
  modes:
    - v
  placement: replace
  user_prompt: true
---

## system

Act as a careful ${context.filetype} developer. Apply the user's requested
change to the selected code. Return only the complete replacement code, with
the original indentation preserved. Do not include explanations or code fences.
