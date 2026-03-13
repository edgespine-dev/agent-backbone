# PLAN skill migration

Status: draft-v0.2  
Date: 2026-03-11  
Owner: TBD

## 1) Scope och mål

Den här planen skissar:
- effekter av att flytta repo-specifika skills från `bakerlabs-k8s` till `agent-backbone`
- målorganisation där `skills` och arkitekturanteckningar hålls separerade
- en initial migrationssekvens med kompatibilitet under övergång

Ej i scope i v0:
- fullständig omskrivning av varje skill
- automatisk massmigrering av alla externa konsumenter samma dag

## 2) Bakgrund (nuläge)

Observerat nuläge:
- `agent-backbone` innehåller idag generiska katalogskills (`deterministic`, `stochastic`, `orchestration`, `references`)
- `bakerlabs-k8s/skills/edgespine` innehåller domänspecifika EdgeSpine-skills, egna referenser, tester och install/verify-script
- lokala wrappers i `~/.codex/skills` pekar idag till både agent-backbone och bakerlabs paths

Konsekvens:
- katalogen är delad över två repos med olika release- och ändringscykler
- risk för drift mellan generiska mönster och domänimplementation

## 3) Taxonomi (status + typ)

Inför två explicita portföljfält för alla skills:

### Status
- `core`: alltid installerbar och långsiktigt supportad
- `domain`: domänspecifik, installerbar via subset/profil
- `experimental`: opt-in, ej stabilt kontrakt
- `deprecated`: installeras inte som default; endast kompatibilitetstid

`core` ska tolkas strikt. En skill bör endast klassas `core` om den:
- används över flera projekt/domäner
- har stabilt kontrakt
- har verifierbar smoke-test
- inte kräver repo-lokal domänkunskap för att vara meningsfull

### Typ
- `runtime_skill`: aktivt arbetsflöde som används i löpande arbete
- `governance_reference_skill`: policy/klassificering/routing/referensstyrning

## 4) Effektanalys: flytt bakerlabs -> agent-backbone

### Förväntade vinster
- en källa för skill-governance, release och installlogik
- enklare återanvändning av samma domänskills mellan projekt
- tydligare katalogering med status/typ minskar installationsfel
- bättre testbarhet när skill-tester kan standardiseras i samma repo

### Kostnader / risker
- brutna paths i befintliga wrappers och scripts
- oklar ownership om domänkunskap flyttas utan tydliga CODEOWNERS-regler
- risk att domänskills urvattnas om repo-specifika referenser tappas
- temporär dubbelkälla under migration (två repos lever parallellt)

### Riskreducering (måste finnas i planen)
- bakåtkompatibla wrappers i `bakerlabs-k8s` under övergång
- explicit source-of-truth-markering per skill
- verifieringsscript som kontrollerar symlink targets + metadata
- tidsboxad deprecationsperiod med tydligt slutdatum
- replacement-spår för deprecations (`replacement_skill`, ev. `replacement_path`)

## 5) Målorganisation av agent-backbone

Designprincip: håll exekverbara skills separerade från arkitektur/anteckningar.
Separera även skill-interface från portfölj/governance-metadata.

Föreslagen top-level:

```text
agent-backbone/
  skills/
    general/
    k8s/
    iot/
    data-analysis/
    testing/
    internal/
    references/
  registry/
    skills.yaml
    profiles/
      core.yaml
      k8s.yaml
      full.yaml
      legacy.yaml
  architecture/
    notes/
    decisions/
    migration/
  scripts/
    install/
    verify/
    migrate/
  PLANS/
```

Tolkning av mappar:
- `skills/general`: små stabila byggblock (oftast `core`)
- `skills/internal`: portföljstyrning, policy och uppdateringsregler (`governance_reference_skill`)
- `skills/<domain>`: konkreta domänflöden (oftast `domain`)
- `skills/references`: globala tvärgående referenser
- `skills/<domain>/references`: domänlokala referenser (t.ex. `skills/k8s/references`)
- `architecture/notes`: resonemang, modeller, bakgrund
- `architecture/decisions`: ADR-liknande beslut
- `architecture/migration`: migreringsartefakter och cutoverlogg
- `registry/`: portföljlager för status, typ, owners, profiler och deprecations

Notera: utan domänlokala references riskerar global `skills/references/` att bli dumpyta.

## 6) Metadata-kontrakt per skill

### Skill interface contract (`SKILL.md`)

`SKILL.md` ska hållas minimalt och stabilt:
- `name`
- `description`

### Portfolio metadata contract (`skill.meta.yaml` eller registry)

Governance-metadata ska inte bo i `SKILL.md`.  
Metadata ska ligga i separat portföljlager, antingen:
- lokal `skill.meta.yaml` bredvid varje skill, eller
- central registry (rekommenderad default): `registry/skills.yaml` + `registry/profiles/*.yaml`

Precedence-regel i v0.2:
- `registry/` är source of truth för install/verify/cutover.
- `skill.meta.yaml` får användas endast under aktiv migrering eller lokal utveckling.
- vid konflikt gäller alltid `registry/` och `verify` ska faila på mismatch.

Livscykelregel för `skill.meta.yaml`:
- tillåten i migreringsfaser och lokal utveckling
- får inte användas av install-path i steady state
- efter cutover ska `verify`/CI flagga och kunna blockera kvarvarande `skill.meta.yaml` som fortfarande påverkar installbar metadata

Fält som ska stödjas i portföljlagret:
- `schema_version`
- `canonical_id`
- `status`: `core|domain|experimental|deprecated`
- `type`: `runtime_skill|governance_reference_skill`
- `owners`
- `source_of_truth`
- `domain`
- `install_profiles`
- `deprecation_date` (krävs om `status=deprecated`)
- `replacement_skill` (krävs om `status=deprecated`)
- `replacement_path` (rekommenderas när path byts)

Maskinläsbara format:
- `canonical_id`: globalt unikt id i formen `<domain>/<family>/<name>`
- `source_of_truth`: strukturerat objekt med minst:
  - `repo_id` (canonical repo-id)
  - `repo_path` (repo-relativ canonical path)
- `owners`: lista av standardiserade identiteter (t.ex. GitHub team slug eller repo-owner-alias), ej fri text

Namnkonfliktregel:
- path namespacas per domän, men `canonical_id` måste vara entydigt i hela registry
- `verify` ska faila vid dubletter av `canonical_id` eller kolliderande installnamn

Kontraktsversionering:
- metadata följer semver i `schema_version` (ex. `1.0.0`)
- `verify` accepterar patch/minor inom samma major
- okänd major-version är blockerande tills verify/install uppdaterats

## 7) Initial migreringsordning

### Fas 0: Lock baseline
- frys nuvarande skill-lista och path-inventory
- definiera metadata-kontrakt + valideringsscript
- besluta ownership-regler (CODEOWNERS eller motsvarande)
Owner: migreringsansvarig + repo-owners  
Entry: plan godkänd för v0.2  
Exit: fryst inventory + beslutad ownership + validerbar kontraktsmall

### Fas 1: Struktur i agent-backbone
- skapa målmappar under `skills/` och `architecture/`
- skapa `registry/` och profilfiler
- flytta/normalisera installer/verify-scripts till gemensam struktur
- lägg till katalog-README som beskriver status/typ och installationsprofiler
Owner: platform/maintainers för agent-backbone  
Entry: Fas 0 klar  
Exit: katalogstruktur + registry + script-skelett finns och passerar grundverify

### Fas 2: Pilotmigrering (1-2 skills)
- migrera 1-2 EdgeSpine-skills till `agent-backbone/skills/k8s/edgespine/`
- uppdatera wrappers/entrypoints för pilot-scope
- verifiera install, metadata, wrappers och smoke-tests
- justera kontrakt/scripts innan bred flytt
Owner: EdgeSpine domänägare + plattformsägare  
Entry: Fas 1 klar  
Exit: pilot passerar verifieringsmatrix för `core`, `k8s`, `legacy`

### Fas 3: Migrera EdgeSpine skills (bred flytt)
- flytta `bakerlabs-k8s/skills/edgespine/*` till vald domänmapp i `agent-backbone/skills/k8s/edgespine/*`
- bevara referensdokument och tester intakta i första flytten
- markera varje skill som `domain` initialt
Owner: EdgeSpine domänägare  
Entry: Fas 2 klar  
Exit: alla scope-skills migrerade + metadata publicerad i registry

### Fas 4: Kompatibilitet
- lämna tunna wrappers i `bakerlabs-k8s` som pekar till nya paths
- behåll gamla installer-entrypoints men skriv tydlig deprecation-warning
- verifiera att både Codex och Claude-install fungerar under övergång
- när `deprecated`: ange alltid `replacement_skill` och vid behov `replacement_path`
Owner: plattformsägare för installverktyg  
Entry: Fas 3 klar  
Exit: wrappers/entrypoints verifierade + deprecation-signaler aktiva

### Fas 5: Cutover och städning
- byt default-install till `agent-backbone` som primär källa
- efter deprecationsfönster: ta bort gamla paths i `bakerlabs-k8s`
- publicera slutlig migreringsrapport i `architecture/migration/`
Owner: release-ansvarig  
Entry: Fas 4 klar + verifieringsmatrix grön för `core`, `k8s`, `legacy`  
Exit: default-install bytt + cutover loggad + städning planerad

Go/No-Go-regel för cutover:
- Go kräver uttrycklig sign-off från release-ansvarig + relevant domänägare
- Go kräver grön verifieringsmatrix för `core`, `k8s`, `legacy`
- No-Go vid rött verifieringsutfall eller blockerande registry/path-mismatch; rollback aktiveras omedelbart

## 8) Contract lock points

Lås följande innan bred flytt:
- interface-kontrakt (`SKILL.md` minimal frontmatter)
- portfolio-kontrakt (`status`, `type`, ownership, replacements, profiler)
- katalogstruktur (domänmappar + references + architecture-split)
- installkontrakt (subset/profiler och default urval)
- verifieringskontrakt (path, symlink, metadata, smoke)

## 9) Installationsprofiler (för projektinstallerare)

Exempel:
- `profile:core` -> endast `status=core`
- `profile:k8s` -> `core + domain(k8s)`
- `profile:full` -> `core + domain + experimental` (explicit opt-in)
- `profile:legacy` -> inkluderar `deprecated` endast för migrering

Profilfiler i registry (default):
- `registry/profiles/core.yaml`
- `registry/profiles/k8s.yaml`
- `registry/profiles/full.yaml`
- `registry/profiles/legacy.yaml`

## 10) Verifieringsmatrix (minimikrav)

`verify` ska minst kontrollera:
- metadata valid (schema + obligatoriska fält)
- path exists (skill-path och referens-path)
- wrapper/symlink target valid
- install fungerar för Codex
- install fungerar för Claude
- smoke prompt passerar
- deprecated-warning visas där det är tillämpligt
- inga ghost skills: oregistrerade installerbara skills får inte finnas
- wrappers får inte peka mot target som saknar registry-entry
- registry-entry och faktisk skill-path måste matcha

Cutover-gate:
- inför Fas 5 måste verifieringsmatrix vara grön för minst profilerna `core`, `k8s`, `legacy`.
- vid rött utfall eller blockerande mismatch stoppas cutover och rollback-plan aktiveras.

## 11) Rollback-plan vid misslyckad cutover

Om cutover misslyckas:
- återställ default-install till gamla entrypoint
- verifiera wrappers och gamla paths
- markera cutover som avbruten i migreringsloggen
- pausa vidare flytt tills verify är grön igen
- ta bort/isolera kvarvarande `skill.meta.yaml` som påverkar steady-state install

## 12) Beslut och rekommenderade default-val

Rekommenderad default-riktning:
- `edgespine` placeras under `skills/k8s/edgespine/`
- både global och domänlokal `references/` stöds
- default deprecationsperiod: 60 dagar
- dag 1 klassas få skills som `core`; EdgeSpine startar som `domain`

Öppna beslut kvar för review:
- exakt policydatum när `skill.meta.yaml` går från tillåten i migrering till blockerad i CI
- exakt cutoff-datum för första deprecationsvågen

## 13) Definition of done för v1-migrering

- alla migrerade skills har metadata enligt kontrakt
- `SKILL.md` innehåller endast interface-fält (`name`, `description`)
- governance-metadata hanteras i separat portföljlager
- install/verify fungerar från `agent-backbone` för Codex + Claude
- bakåtkompatibla wrappers finns och är markerade `deprecated`
- deprecated skills har `replacement_skill` (obligatoriskt) och `replacement_path` när pathbyte skett
- dokumenterad cutover-plan med datum och ansvariga finns
- inga okända skill-källor kvar i produktion (source-of-truth entydig)

## 14) Verktygslåda: jämförande review-prompt

För att undvika ad-hoc jämförelser mellan externa skill-kataloger och agent-backbone ska vi använda en standardprompt i verktygslådan:
- `PLANS/prompts/PROMPT_catalog_gap_review.md`

Syfte:
- identifiera vad externa kataloger gör bättre
- identifiera vad som saknas i vår katalog
- ge konkreta, migreringsnära åtgärder utan scope creep

Krav på output från prompten:
- severity-rankade findings med filreferenser
- förslag som kan mappas till `registry`, `install`, `verify`, `wrappers` eller `docs`
- tydlig markering av "adopt now", "pilot first", eller "defer"
