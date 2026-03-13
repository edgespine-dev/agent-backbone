# PROMPT catalog gap review

Använd denna prompt för att jämföra en extern skill-katalog mot `agent-backbone` med fokus på migrering, governance och verifierbarhet.

## Input
- `external_repo_root`: path till extern katalog
- `internal_repo_root`: path till `agent-backbone`
- `scope`: vilka domäner/skills som ingår i passet
- `constraints`: t.ex. "ingen scope creep", "ingen stor omstrukturering"

## Prompt
Du gör en strukturerad gap-review mellan två skill-kataloger.

Mål:
1. Identifiera vilka operativa egenskaper externa katalogen hanterar bättre, utifrån installation, governance, source-of-truth, verifiering och kompatibilitet.
2. Identifiera vad som saknas eller är svagare i interna katalogen inom scope.
3. Föreslå endast inkrementella förbättringar som stödjer migration, kompatibilitet och verifiering.

Arbetssätt:
0. Bygg en comparison map.
- Mappa externa artefakter till interna motsvarigheter.
- Om direkt motsvarighet saknas: markera detta explicit.
- Jämför funktionell roll, inte bara namn eller katalogplacering.

1. Inventera struktur:
- skills
- references
- registry/profiler
- install/verify-entrypoints
- wrappers
- README/kontraktsdokumentation

2. Jämför kontrakt:
- skill-interface
- metadata
- naming
- ownership
- source-of-truth
- replacement/deprecation-signaler

3. Jämför distributionsmodell:
- plugin/profile/subset-install
- install-defaults
- compatibility paths / legacy entrypoints

4. Jämför verifieringsmodell:
- ghost-skill-skydd
- path-mismatch-skydd
- registry-vs-filesystem-konsistens
- deprecation/replacement-signaler
- smoke-test-stöd

5. Lista:
- skill-gaps
- process-gaps
- kontraktsgaps
- verifieringsgaps

Outputformat:
1. Findings först, sorterat på severity (`high`, `medium`, `low`).
2. Varje finding ska innehålla:
- `title`
- `gap_type`: `structure | contract | install | verify | governance | migration | evidence_missing`
- `why_it_matters`
- `evidence_external` (fil + rad; om rad saknas, använd bästa tillgängliga ankare)
- `evidence_internal` (fil + rad; om rad saknas, använd bästa tillgängliga ankare)
- `recommended_action`
- `owner_suggestion`
- `adoption_mode`: `adopt_now | pilot_first | defer`
- `confidence`: `high | medium | low`
3. Om inget verifierbart gap finns för ett område: skriv explicit `no material gap found`.
4. Om underlag saknas: markera explicit `insufficient evidence`.
5. Avsluta med en kort `Patch plan` (max 5 punktinsatser) för nästa revision.

Evidensformat:
- använd klickbara absoluta filankare i format `/abs/path/file:line`
- om rad saknas, använd bästa tillgängliga filankare och markera osäkerhet

Guardrails:
- Ingen total omskrivning av planen eller katalogen.
- Inga vaga råd utan filankare.
- Förslag måste vara maskinläsbara eller verifierbara när möjligt.
- Respektera givna constraints.
- Föreslå inte ny arkitektur om den inte direkt stödjer migration, kompatibilitet eller verifiering.
- `recommended_action` ska vara en konkret patchbar ändring, inte generell riktning.
