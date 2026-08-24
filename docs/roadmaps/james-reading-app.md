# Event Horizon Rebuild Roadmap

Status: proposed validation roadmap

Last updated: 2026-08-24

Read the full [product record](../research/james-event-horizon.md) before this
roadmap.

## Objective

Rebuild Event Horizon on the personal profile without losing its authored
content, touch-first gameplay, family ownership, Captain's Log, or PWA quality.
Use the rebuild to validate and improve the starter without introducing
family/game-specific machinery into the baseline.

## Non-goals for the first replacement

- AI tutor
- Offline-first support
- Public child accounts
- Public marketplace/content system
- Generic curriculum authoring platform
- Full Weeks 2–4 completion before the architecture is validated

## Phase J0 — Inventory and parity contract

1. Inspect the current repository, schema, fixtures, storage metadata, routes,
   tests, and deployed environment directly.
2. Export/version the five authored Week 1 missions and source metadata in a
   provider-independent format.
3. Inventory assets, rewards, progress, family records, PINs, and recordings.
4. Decide which existing user progress/audio must migrate and which may start
   fresh with explicit family agreement.
5. Turn the core mission loop and parent review into an executable parity
   checklist.
6. Record privacy, ESV licensing, source-review, and retention decisions.

Gate: no information exists only inside Convex or the old thread without an
export/migration decision.

## Phase J1 — Generate and model the personal application

1. Generate the current personal profile with password auth, jobs, storage,
   PWA, and family-profile capabilities.
2. Model parent user, family, kid, mission content, attempts, answers, hint
   events, reflections, rewards, and equipped items with ownership constraints.
3. Import one representative mission as deterministic seed/fixture content.
4. Add cross-family authorization tests before building all screens.

Gate: a second family cannot read or mutate the first family's profile,
attempts, progress, or files.

## Phase J2 — Parent identity and onboarding

1. Implement parent login/invitation using the starter's owned session model.
2. Create family and kid onboarding.
3. Implement the parent PIN as a defined convenience boundary with digest,
   pepper, rate limit, and session/expiry behavior.
4. Add development-only seeded family/parent/second-family agent login.
5. Verify returning-device and interrupted-onboarding behavior.

Gate: onboarding and returning login work without Clerk/Convex and are covered
by browser and ownership tests.

## Phase J3 — One complete mission vertical slice

Implement one Week 1 mission end to end:

- mission brief and transmission;
- evidence taps and graded questions;
- progressive hints;
- Connection Map using large tappable pieces;
- attempt persistence and resume;
- debrief and reward;
- hub progress.

Verify touch targets, no required typing, no speed rewards, refresh/resume, and
responsive behavior at phone, iPad portrait/landscape, and desktop sizes.

Gate: James can complete the mission on an iPad and the data survives refresh
and process restart.

## Phase J4 — Captain's Log and parent review

1. Record 30–60 second browser audio with skip/no-microphone fallback.
2. Validate size, duration metadata, ownership, and accepted formats.
3. Store through Active Storage.
4. Add playback, mission-specific listening guidance, and permanent deletion.
5. Add parent inbox and feedback without blocking child completion.
6. Define and automate recording retention.

Required physical iPad checks:

- microphone permission and denial;
- actual Safari recording MIME/format;
- upload and progress;
- playback after relaunch;
- deletion removes database attachment and stored object;
- safe-area and standalone PWA behavior.

Gate: the complete reflection lifecycle works on a physical iPad.

## Phase J5 — Product parity

1. Migrate all five Week 1 missions and Dust Storm on Mars.
2. Restore hub, mission catalog, debrief/reward, hangar/customization, parent
   gate, and parent progress/recording views.
3. Preserve Scripture Archive visual and content boundaries.
4. Add PWA manifest/icons/service-worker update behavior without claiming
   offline support.
5. Match or improve the old fixture/unit/authorization/responsive test baseline.
6. Verify source links and theological/licensing review status.

Gate: agreed current-use features have a written parity result; intentional
differences are approved rather than accidental omissions.

## Phase J6 — Private deployment and migration

1. Deploy the same image to an exe.dev VM with private PostgreSQL and worker.
2. Configure HTTPS, domain/alias, backups, local uploads or selected
   S3-compatible storage, and restore monitoring.
3. Rehearse import of any retained family/progress/audio data.
4. Restore into a disposable environment and assert family, mission, progress,
   and recording behavior.
5. Run old and new applications side by side until Robert approves switching
   family usage.
6. Verify the stable URL serves the intended image after release.

Gate: explicit cutover approval; old deployment remains rollback until the new
app has operated successfully.

## Phase J7 — Starter feedback

Classify each friction item:

- universal foundation;
- personal profile;
- optional PWA/media/family recipe;
- Event Horizon only.

Likely recipe candidates, subject to evidence:

- family/kid profile ownership pattern;
- PWA metadata/service-worker pattern;
- secure bounded audio upload lifecycle;
- touch-first ordering interaction.

Mission content, scoring, rewards, parent pedagogy, and Scripture presentation
remain application-specific.

## Acceptance summary

- No Clerk, Convex, or Vercel requirement
- Parent-owned identity and sessions
- Closed access
- Cross-family negative tests
- Complete mission loop on iPad without typing
- Durable progress and optional audio
- Parent review does not block completion
- Private deployment, backup, and restore evidence
- No institutional integration code in the generated personal app
