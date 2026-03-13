---
name: esp32-embedded-runner
description: run a minimal esp32 embedded workflow from build assumptions to flash/test checkpoints.
---

# esp32-embedded-runner

## Purpose
Provide a bounded workflow for ESP32 embedded tasks so execution can move from assumptions to reproducible checkpoints.

## Primary scope
- Capture board/SDK assumptions.
- Define build and flash checkpoints.
- Define minimal runtime verification checks.

## Not responsible for
- Hardware provisioning.
- Vendor-specific support escalation.
- Replacing project-specific firmware architecture decisions.

## Workflow
1. Lock target board, framework, and toolchain assumptions.
2. Confirm expected build command and artifact output.
3. Confirm expected flash command and connection assumptions.
4. Define minimal post-flash checks (boot log, serial sanity, basic IO signal).
5. Record pass/fail and next smallest remediation.

## Output contract
Return:
- `assumptions`
- `build_checkpoint`
- `flash_checkpoint`
- `runtime_checkpoint`
- `risks_and_unknowns`
- `next_smallest_step`
