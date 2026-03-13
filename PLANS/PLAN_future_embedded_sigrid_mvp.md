# PLAN future embedded + sigrid mvp

Status: draft-v0.1  
Date: 2026-03-11  
Owner: TBD

## 1) Syfte

Detta är en future-plan som ligger separat från aktiv skill-migrering.

Målet är att etablera ett litet MVP-spår för:
- `esp32 embedded`-arbetsflöden
- `sigrid`-testflöden

Fokus:
- minsta körbara struktur
- registry-koppling
- verifierbar install/verify-yta

Ej i scope:
- full domänimplementering
- ny arkitektur eller nya metadatafält
- ersätta befintliga katalogskills

## 2) MVP-scope

MVP består av två nya skills:
1. `esp32-embedded-runner` under `skills/iot/`
2. `sigrid-test-runner` under `skills/testing/`

MVP ska ha:
- canonical skill-filer
- registry entries
- profil för enkel installmålning
- ett verify-script som validerar att artefakter finns och matchar registry

## 3) Kontrakt (oförändrat)

- Skill interface: endast `name`, `description` i frontmatter.
- Portfolio metadata: ligger i `registry/skills.yaml`.
- Inga nya metadatafält införs i denna plan.

## 4) Genomförandesteg (MVP)

1. Lägg till skill-filer i `skills/iot/` och `skills/testing/`.
2. Lägg till registry entries med `status: experimental`.
3. Lägg till profil `registry/profiles/future-mvp.yaml`.
4. Lägg till verify-script för future-MVP.
5. Kör verify-script och dokumentera resultat.

## 5) Exit-kriterier för MVP

- båda skill-filer finns och är läsbara
- båda skills finns i `registry/skills.yaml`
- profil `future-mvp` mappar till båda canonical_id
- verify-script passerar lokalt

## 6) Deferred

- full ESP32 toolchain-integration
- full Sigrid test harness med externa beroenden
- CI-gate i pipeline (kan läggas senare efter första användning)
