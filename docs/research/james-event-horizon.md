# Event Horizon Product Record

Status: recovered from the active product thread

Source thread:
[`T-01a02c82-1983-721a-8fd8-87caa8da3839`](https://ampcode.com/threads/T-01a02c82-1983-721a-8fd8-87caa8da3839)

Last updated: 2026-08-24

> Privacy note: this document contains family/child product context. Keep the
> repository private and review this file before any public release.

## Product purpose

Event Horizon is an iPad-first reading-comprehension game for Robert's
elementary-aged son James. James reads fluently; the target skills are main
idea, relevant details, cause/effect, sequence, evidence, inference,
connections, and explanation in his own words.

Success is not merely curriculum completion. James should want to play while
the instructional rigor remains real beneath the game framing.

## Product tone

- Original, nonviolent space-exploration setting
- Inspiration from exploration/puzzle/progression and modular building, without
  copying protected game or toy IP
- Kid-facing language: missions, transmissions, scans, discoveries,
  observatory repairs, equipment
- Avoid worksheet/objective terminology
- Do not reward speed; reward evidence, revision, and completed explanation

## Core mission loop

One weekday mission lasts roughly 12–15 minutes. Passages begin around 160
words and grow toward 250 during the first month.

1. **Mission brief** gives a narrative reason to read.
2. **Transmission** presents an authored, source-reviewed passage.
3. **Telescope scans** ask evidence, main-idea, vocabulary, inference, and
   connection questions with progressive hints.
4. **Connection Map** orders tappable text/visual pieces into main
   idea/supporting evidence/cause-effect/sequence structures.
5. **Captain's Log** optionally records a 30–60 second spoken explanation using
   a scaffold.
6. **Discovery reward** grants XP and an observatory/equipment/module unlock.

Parent review never blocks mission completion. Parents review selected work a
few times per week with one encouragement and one focused follow-up.

## Season 1

**The Great Observatory** contains four weeks and 20 planned missions. The
weekly mix is:

- three factual space-science missions;
- one Bible/Scripture Archive mission;
- one building, engineering, or original-adventure mission.

| Week | Comprehension emphasis | Arc |
|---|---|---|
| 1 | Find the big idea | Telescope, Moon, stars, Abram, build stability |
| 2 | Cause and effect | Mars dust, comets, orbits, Joseph, rover wheels |
| 3 | Systems | Star formation, invisible planets, microgravity, Nehemiah, spacesuits |
| 4 | Deep-space synthesis | Giant stars, gravity, Earth-sized telescope, storm, black-hole finale |

The black-hole reward remains rare and culminates on Day 20.

## Content constraints

- Science passages are original writing grounded in reputable sources such as
  NASA, ESA, EHT Collaboration, and engineering-education sources.
- Preserve source URLs with mission content.
- Include non-space content to test skill transfer.
- Bible content is a visually distinct, calm, reverent **Scripture Archive**,
  not fictionalized into the space story or turned into a boss battle.
- Use age-appropriate original retellings and short exact ESV excerpts; do not
  copy wording from Vos's *The Child's Story Bible*.
- Separate what the text says from application/theological interpretation.
- Robert and his wife review theology before release.
- Recheck current Crossway licensing/API terms, quotation limits, and required
  attribution before wider distribution.

## Current product state to preserve

- All five Week 1 missions are authored in fixture and Convex catalogs.
- Each has an 8–9 sentence passage, five graded questions, four-step hints,
  evidence interaction, source notes, Connection Map, Captain's Log prompt,
  parent guide, and reward.
- Dust Storm on Mars remains available after Week 1.
- Saturn, comet, and black-hole catalog stubs exist.
- Connection Map uses touch-first large tappable pieces instead of precision
  dragging or required typing.
- Captain's Log uses browser microphone capture with playback and a parent
  inbox; it performs no AI transcription or analysis.
- Live recordings use Convex storage and ownership checks; fixture recordings
  are temporary browser object URLs.

## Screens/routes to reproduce conceptually

- Landing/start
- Login and controlled account entry
- Family/kid onboarding
- Hub/PWA start target
- Mission reader and interactions
- Connection Map and Captain's Log
- Debrief/reward
- Hangar/customization
- Parent gate
- Parent dashboard/recording inbox
- Health endpoint

The Rails route names need not match the old implementation exactly.

## Identity and data concepts

- Authenticated parent/application user
- Family/account and one or more kid profiles
- Grade band and parent PIN digest
- Mission catalog with kind/presentation/skill/source/reward/reflection metadata
- Passage sentences and graded questions/evidence/hints
- Attempts and graded-answer/progress lifecycle
- Hint events and performance summaries
- Unlockable/equipped cosmetics and equipment
- Mission reflection with ordered map cards and optional recording
- Parent recording list, listening guide, playback, and permanent deletion

Cross-family ownership checks are mandatory.

## Device, PWA, and media requirements

- Primary target: iPad Safari
- Responsive support: phone, tablet, desktop, ultrawide
- No typing required for the core mission loop
- Large touch controls, safe-area handling, and no horizontal overflow
- Installable HTTPS PWA, standalone display, Apple metadata, and `/hub` start
- Internet remains required initially; PWA does not imply offline support
- Microphone permission, recording, bounded upload, playback, deletion, and
  no-microphone skip fallback
- Validate actual Safari formats and behavior on a physical iPad
- Audio upload cap was 10 MB in the existing design; retention policy remains
  open

## Current technical state

- React/TanStack Start + Vite
- Convex backend/storage
- Clerk parent authentication
- Vercel hosting
- Fixture adapter for development
- Current test baseline reported TypeScript, ESLint, production build, 123
  fixture tests, Convex authorization/reflection tests, and responsive browser
  checks at representative phone/tablet/desktop sizes

The current public alias has previously remained pinned to an older Vercel
deployment even after newer `main` builds. Any replacement release process must
verify that the intended build is actually serving at the stable URL.

## Deferred ideas

- Weeks 2–4 implementation/content completion
- Richer art and free dragging
- Typing/academy/flight-computer features
- Offline mode
- Dedicated bounded AI voice tutor
- Public distribution

An AI voice tutor, if ever revisited, requires provider terms for children,
parent consent/supervision, privacy minimization, static fallback, and legal
review. It is not part of the starter baseline or initial rebuild.

## Open product questions

1. Are Captain's Logs optional every day or required on selected synthesis
   missions?
2. What progression unlocks later missions and the Day-20 finale?
3. How many families and kid profiles must the private product support?
4. What is the child-audio retention policy?
5. What production/privacy/licensing bar is required for private family use
   versus wider distribution?
6. Is the parent PIN only a convenience gate, and what expiry/rate limiting
   should apply?
7. Which content beyond Week 1 should be migrated before feature parity is
   claimed?
