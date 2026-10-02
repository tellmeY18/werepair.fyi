# CLAUDE.md — werepair.fyi (The Open Repair Platform)

> **Status:** Brainstorming → pre-MVP. Revision 2.
> **Scope of this doc:** essence, values, operational flows, UX/UI. No code, no architecture, no tech spec.
> **Stack note (for later, not specified here):** Phoenix / Elixir for the platform; MediaWiki for the knowledge base.

### Legend
| Marker | Meaning |
|---|---|
| ✅ | **Your answer** (from you, recorded as you said it, lightly cleaned) |
| 🟡 | **Default** (my sane guess, aligned with your values; accept or correct it) |
| ⬜ | **Open** (needs your voice; no good default exists) |

Correct any 🟡 by replying with its number and the right answer. Anything you don't correct is treated as accepted.

---

## ⚠️ Flags: things I'd double-check before building

1. **"MVP by this weekend."** Realistic only for a *thin slice* (see §26). The wiki deployment, Kochi technician seed list, events, and auth are each a day of work if solo. I've proposed a cut that fits.
2. **Phone number mandatory vs. zero budget.** Verifying a phone (OTP/SMS) normally costs money, and you said no messaging costs for MVP. Default: *collect* the number at MVP, show it as **unverified**, and add the verified "blue tick" later. (Q35, Q40, Q41.)
3. **Instagram login.** Meta has restricted Instagram login for ordinary personal accounts in recent years. Verify what is currently possible before promising it; treat it as "nice to have, drop if blocked." (Q32.)
4. **"CC-04 share alike."** I've read this as **CC BY-SA 4.0**. It matches Wikimedia Commons' accepted licences, which fits your free-media strategy. Confirm. (Q8.)
5. **Wikimedia Commons only accepts freely licensed media.** Photos of requesters' devices/people shouldn't go there without consent, and ID/chat media must *never* go there. (§29.)
6. **Your answer to Q10** ("platform custom build is the idea") reads like an answer to a different question (build vs. buy). I've recorded it that way and left the original Q10 open. (Q10.)
7. **Deletion vs. retention for crime tracing.** Doable (delete profile, keep minimal logs for a short, stated period), but Indian data-protection rules (the DPDP Act) and IT Act obligations should be checked with a lawyer before public beta. Not legal advice from me. (Q44, Q214, Q222.)
8. **Repair events carry real-world liability** (venue, injuries, fire/electric hazards, stolen devices). Needs clear "organiser responsibilities" before the first public event. (§29.)

---

## 1. Essence

**werepair.fyi is a public, open platform where anyone can get something repaired, anyone can become the person who repairs it, and everyone can learn how, with the cost of running the platform shown to everyone.**

Three inspirations, fused:

| Inspiration | What we borrow |
|---|---|
| **QuickRide** | One account, no fixed role. You act as a *requester* or a *technician* depending on what you post or respond to. Simple, local, person-to-person. |
| **OLX / classifieds** | Open listings, no middleman cut, low barrier to entry. |
| **Udemy → replaced by a wiki + apprenticeship** | Learning happens through the open knowledge wiki and by working beside technicians at repair events. |
| **Repair Café movement** | In-person repair fests where multiple technicians, volunteers and apprentices gather, flea-market style. |

**The motto:** *Repair over Replace.*
**The end goal:** repair anything, via a growing, community-owned body of repair knowledge and a network of real people who can do it.
**The attitude:** *Think local, build local.* Start in Kochi, make it work for people there, then let other places replicate it.

**Pitch (draft):** *"If it's broken, someone near you can fix it, you can learn how it was done, and you can see exactly what it costs to keep this running."*

---

## 2. Core Values

1. **Open by default.** Finances/running costs, knowledge, code and data are open. *(Governance is the one exception: BDFL model, see §20.)*
2. **No middlemen.** The goal is to remove the cut extracted by agencies and aggregators so maximum value reaches the person doing the work.
3. **Anyone can participate.** Low barrier for technicians and requesters; trust is earned and shown, not gatekept.
4. **Layered trust.** Trust levels are visible and unlock things (phone verified, ID verified, track record).
5. **Learn, don't just outsource.** Requesters are encouraged to watch, ask and learn so next time they can fix it themselves. Knowledge compounds.
6. **Requester documents.** The responsibility for describing the problem, the debugging steps taken and the fix lies with the requester; this is how the knowledge base grows.
7. **Safety over speed.** Some repairs are dangerous; the platform knows its limits.
8. **Repair over replace.**
9. **Privacy-respecting.** No third-party ads. No selling user data. Free, privacy-respecting analytics only.
10. **Frugal.** Run on as close to zero cost as possible: Wikimedia Commons and YouTube for bulk media, minimal paid services.
11. **Simple, "simpler-stupider" app** that anyone can use.

> ✅ **Q-VALUES-1:** "values sounds good to me." Values 2, 5, 6, 9, 10, 11 added from your answers.

---

## 3. People (Personas)

| Persona | Who | Wants |
|---|---|---|
| **Requester** | Anyone with something broken (18+) | Get it fixed fairly, safely, and learn from it |
| **Technician** | Any individual who repairs (hobbyist to professional, 18+) | Find work, build reputation, mentor, earn directly |
| **Volunteer / Apprentice** | Someone who helps a technician and learns a trade | Experience that is tracked and shown on their profile |
| **Organiser** | Person who runs a repair fest/event | Gather technicians + requesters in one place |
| **Wiki Contributor** | Writes/edits repair knowledge | Credit, impact |
| **Admin / BDFL / Moderator** | You, initially | Spam/abuse handling, platform stewardship |
| **Observer** | Anonymous visitor | Browse the directory, wiki, events and cost page |

> ✅ **Q-PERSONA-1:** lgtm.
> ✅ **Q-PERSONA-2:** Yes, one account can do everything. **No separate roles or apps, no toggle.** Follow the QuickRide model: one profile, mode chosen per post/response. Being a technician doesn't mean you won't need help from others.

**Note on the QuickRide model:** in QuickRide you have one profile and choose, per ride, whether you're offering or looking for one. Equivalent here: each post says "I need this fixed" or "I can fix this / I'm offering my skills," and profiles show both histories.

---

## 4. Platform Pillars

1. **Technician Directory** (Kochi first, mapped on OpenStreetMap)
2. **Repair Requests** (listings-based; requester-documented; tracking log)
3. **Repair Events / Fests** (the MVP's centre of gravity)
4. **Knowledge Wiki** (`wiki.werepair.fyi`, MediaWiki; catalogue + guides + journals)
5. **Profiles, Ratings & Trust Ticks**
6. **Radical Transparency** (public cost page)
7. **Safety, Reports & Moderation**

---

## 5. Operational Flows

### 5.1 Requester flow (MVP)
1. Browse the site (public, no login).
2. Sign in (basic auth in POC) when ready to post.
3. Post a request. **The requester writes:** what the item is, the symptoms, what they tried, photos. They commit to documenting the repair.
4. Technicians respond (comment/contact). Optionally, the requester contacts a technician directly from the directory.
5. Requester picks a technician. Price is agreed **between them** (technician decides; no money passes through the platform).
6. Repair happens (technician visits / requester goes to the technician / at a repair event). Requester is encouraged to watch and learn.
7. Requester logs the work in the request's **tracking log** (steps, parts, who bought what, agreed price, outcome).
8. Requester marks Fixed / Partly / Not fixed; both sides leave a rating.
9. Requester is prompted to **publish the journal to the wiki** (CC BY-SA), which grows the knowledge base.

### 5.2 Technician flow (MVP)
1. Sign up (same account type as everybody).
2. Create a profile: real name, area, skills, optional shop location (OSM), availability note, phone.
3. Appear in the directory and see open requests and events.
4. Respond to requests, join repair events, optionally bring volunteers/apprentices (once trusted enough).
5. Build reputation via ratings, event participation, apprentices mentored, wiki contributions.
6. Raise trust level (phone verified → ID verified → track record).

### 5.3 Repair event flow (MVP centre)
1. An organiser (initially you) creates an event: date, place on the map, theme/domain (e.g. "Electronics fest").
2. Technicians sign up to attend and list what they can repair.
3. Volunteers/apprentices sign up under specific technicians (with those technicians' acceptance).
4. Requesters see the event, optionally pre-register the item(s) they'll bring.
5. On the day: items are repaired with the owner present and learning; volunteers help.
6. After: attendance and apprenticeship are recorded on profiles; requesters log/publish journals; event gets a public summary.

### 5.4 Trust ladder
| Level | What it means | Status at MVP |
|---|---|---|
| L0 | Visitor | ✅ |
| L1 | Account with real name | ✅ |
| L2 | Verified phone (blue tick) | ⏳ later (number collected, unverified) |
| L3 | Government ID verified | ⏳ later |
| L4 | Face match to ID | ⏳ later |
| L5 | Track record (jobs/events/apprentices/wiki) | ✅ computed from activity |

**Blue-tick principle (yours):** *to see someone's phone number you must have verified your own.* Same idea later for Government ID (e.g. ID-verified-only features).

### 5.5 Transparency flow
A public "What it costs" page: what we spend (domain, hosting, services), what we received (donations), what we take from repairs (**₹0, because no money passes through at MVP**). Hand-updated monthly at first.

### 5.6 Learning flow
Wiki guides + YouTube links + apprenticeship at events. Apprenticeship hours/events are logged by the technician and displayed on the apprentice's profile as a trust boost.

---

## 6. UX / UI Principles

- **Simpler, stupider app** that caters to everyone.
- **Mobile-first**, light pages, mid-range Android in mind.
- **Browse before sign-in**: directory, events, wiki and cost page are public.
- **Posting a request takes under 2 minutes.**
- **Trust is visible**: ticks + level on every card.
- **Plain language**, English + Malayalam.
- **The Open page is first-class**: "What it costs" is in the header and footer.
- **Honest empty states**: if there's no technician, say so and point to the wiki/events.
- **Reuse existing tools** (MediaWiki editor, OSM maps) rather than reinvent.

### MVP screens (proposed)
1. Home 2. Sign in/up 3. Post request 4. Request detail + tracking log 5. Technician directory (list + OSM map) 6. Technician profile 7. Events list 8. Event page (sign-up as technician / volunteer / requester) 9. My profile 10. Wiki (separate site, linked) 11. "What it costs" 12. Admin (reports, spam)

> 🟡 **Q-UX-0:** Everything on that list is in; nothing like chat, courses, payments or catalogue UI is on it (wiki covers the catalogue).

---

# QUESTION BANK, WITH ANSWERS

---

## 7. Vision, Scope & Positioning

**1.** Who's the first user you'd love to see succeed: requester, technician or learner?
> ✅ **Technicians first.** Start as a directory of actual local technicians, onboard locals. Tell requesters to learn as much as they can from the technician so next time they can do it themselves. The requester carries the responsibility of describing and documenting the problem, debug steps and the fix.

**2.** What's the narrow wedge for the POC?
> ✅ **No wedge: anything.** Narrowing risks reducing exposure and makes onboarding harder.

**3.** Which geography first?
> ✅ **Kochi.** An early task: build a proper directory of local technicians and map them using OSM.

**4.** Local or global?
> ✅ **Local.** "Think local, build local."

**5.** Company / non-profit / co-op / undecided, and how does it interact with "Open"?
> ✅ **Side gig for now.** Listings-based means no money involved. After the pivot, possibly a finance-based company, built after consulting experts, designed to minimise money handling. For MVP: technicians decide price; requester logs the work in tracking (also gives transparency on workers).

**6.** What does "Open" mean concretely?
> ✅ **Everything is open except governance.** You are the BDFL and will actively consider user requests.

**7.** Open-source code, which licence?
> ✅ **AGPL v3.**

**8.** Is knowledge openly licensed? Which?
> ✅ **Yes, very much.** All knowledge under share-alike. You wrote "CC-04 share alike?" → 🟡 **read as CC BY-SA 4.0** (confirm). Contributions are licensed under it; authors keep credit via wiki history.

**9.** Competitors/alternatives and what to reference?
> ✅ **None really.** Reference: Repair Café (repaircafe.org). **Feature:** organise repair fests focused on a domain, with multiple technicians in one place, flea-market style. Volunteers/apprentices sign up under technicians to help and learn a trade, tracked and shown on their bio to enhance trust. **The MVP will revolve around these events** to bootstrap the platform.

**10.** What do you believe alternatives do badly that you'll do better?
> ⬜ **Open.** (Your note "platform custom build is the idea" is recorded under 🟡 *Build vs. buy: custom-built platform, with MediaWiki only for the knowledge base.*)

**11.** What would make you say "the POC worked"?
> ✅ **People actively using it.** 🟡 Suggested measurable targets: ~20 technicians listed in Kochi, 1 repair event held, ~10 requests posted and closed, ~20 wiki pages.

**12.** What would make you stop or pivot?
> ✅ "No clue right now." ⬜ Revisit after the first event.

**13.** Timeline for POC/MVP?
> ✅ **By this weekend.** → see Flag 1 and §26 for the thin-slice proposal.

**14.** Team?
> ✅ **Just you**, possibly a student intern for Elixir/Phoenix, plus a mentor with strong Phoenix knowledge for fixing things.

**15.** Budget ceiling?
> ✅ **₹0 initially; ~sub-₹30k before August 2027**, more once it's rolling.

**16.** Name?
> ✅ **werepair.fyi** (wiki at **wiki.werepair.fyi**).

**17.** Mission statement / homepage line?
> ✅ **"Repair over Replace."**

**18.** What will the platform never do?
> ✅ **No third-party ads. No selling user data to anyone. No proprietary analytics**, only free, privacy-respecting analytics; respect every user's privacy to the best of our efforts.

---

## 8. Users, Personas & Roles

**19.** One account both requester and technician? Toggle?
> ✅ **Yes both; no toggle.** Being a technician doesn't mean they won't need help.

**20.** Are organisations supported at MVP?
> ✅ **No orgs now, listing-model individuals only.** Maybe at a later stage.

**21.** If organisations: employees/sub-technicians under one brand? Liability?
> ✅ **Skip orgs; list the individual workers of agencies instead.** Goal: remove the middleman cut and give people the most cost-efficient service, with maximum revenue reaching the people doing the work.

**22.** Age restrictions?
> ✅ **18+ only for MVP** (safe, Indian legal standards, protects minors).

**23.** Special handling for elderly, non-English, low digital literacy?
> ✅ **"Simpler stupider app to cater everyone."** 🟡 Plus Malayalam UI strings and assisted sign-up by volunteers.

**24.** Public portfolio URL for technicians?
> ✅ **Yes, can be done.**

**25.** "I'll repair this myself, help me" requests?
> ✅ **Should be possible.**

**26.** Mentor/apprentice roles?
> ✅ **Yes.** Technicians can onboard apprentices **once they reach an adequate trust level.**

**27.** Moderator role from day one?
> ✅ **Yes: you as admin.** Moderation = spam and platform moderation; standard rules and tools for spam/abuse.

**28.** Parts suppliers/sellers at MVP?
> ✅ **Not now, open later.** Possibly function as an **aggregator** (Google-Flights-style) that queries multiple places, synthetically and via humans, to find the cheapest price.

**29.** Manufacturers/brands?
> ✅ **No. People first.**

**30.** Most important non-obvious user, and how do they use it?
> ✅ Your answer addressed onboarding the offline/older technicians: **word of mouth and referrals**; the whole idea is a collective community helping each other. 🟡 Concretely: assisted sign-up at events and in person, Malayalam UI. (See also Q232.)

---

## 9. Sign-up, Login & Identity

**31.** Which login methods in the POC?
> ✅ **POC: simple manual basic auth.** Public beta: as many OAuth providers as possible.

**32.** Why Instagram?
> ✅ **Hope it brings free promotion;** drop it if it doesn't work out. 🟡 See Flag 3.

**33.** Link multiple identities to one account?
> ✅ **Yes.**

**34.** Same person, different emails across providers?
> ✅ **Merge.**

**35.** Is phone number mandatory?
> ✅ **Yes, at least for now, definitely necessary.** 🟡 Collected at sign-up for technicians and requesters; verification comes later (see Flag 2).

**36.** Pseudonymous-to-public but verified-to-platform?
> ✅ "Has to be thought out." → ⬜ Open (see Q42: real name is currently required).

**37.** First-screen/onboarding length?
> ✅ **Short onboarding flow.**

**38.** Role selection at sign-up?
> ✅ **No default role; follow QuickRide.** Both profiles exist on one account, no forced choice.

**39.** Account recovery?
> ✅ **Standard, whatever works.**

**40.** Guest requests with OTP?
> ✅ **Later, definitely not in MVP** (messaging/OTP incurs cost).

**41.** What's public vs. private on a profile?
> ✅ **Blue-tick model:** you can see someone's phone number only if you've verified yours; the same fair-trade idea applies to Government ID. 🟡 Public by default: real name, photo, area (neighbourhood level), skills, ticks, ratings, history. Private: phone (tick-gated), email, exact address.

**42.** Real name vs. alias?
> ✅ **Real name**, play it safe.

**43.** Fake/duplicate accounts and sock puppets?
> ✅ "**Bans?**" 🟡 Bans for fake accounts; ratings only count when tied to a linked request/event; one account per person (merge on duplicates).

**44.** Account deletion?
> ✅ **Yes, deletion possible, with data retained for a short period for logging**, so that crimes on the platform can still be traced. 🟡 Check with a lawyer (see Flag 7).

**45.** Blocklist/ban system and appeals?
> ✅ **Email-based appeal, maybe WhatsApp too.**

**46.** 2FA for technicians handling money?
> ✅ **Not needed: MVP doesn't deal with money on the platform;** it's between the parties.

---

## 10. Trust, Verification & Safety

**47.** Define each trust level precisely.
> 🟡 See §5.4. MVP: L0, L1 and L5 (computed). L2-L4 are post-MVP.

**48.** Which government IDs?
> 🟡 Later. Any government photo ID; avoid storing ID numbers (Aadhaar in particular has handling restrictions), store only a "verified on <date>, doc type" flag. Check legal.

**49.** Who verifies IDs?
> 🟡 You, manually, at first (no third-party cost). Images deleted after review.

**50.** Facial verification plan?
> 🟡 Later, optional badge, not in MVP.

**51.** How to store sensitive identity documents?
> 🟡 **Don't.** Keep only the flag + date; delete raw images after review.

**52.** Background/police verification?
> 🟡 Out of scope for MVP.

**53.** How does trust show on cards?
> 🟡 Blue-tick-style icons with text labels (e.g. "Phone verified"), plus level.

**54.** Can trust level go down?
> 🟡 Yes: expired verification, upheld complaints, ban.

**55.** Do requesters have trust levels?
> 🟡 Yes, same ladder (single account model).

**56.** Safety for in-home visits?
> 🟡 MVP: directory only connects people; show a safety tip ("meet in a public place or at an event first; tell someone"). Events are public settings, which is one reason they lead the MVP.

**57.** Restricted/high-risk categories?
> 🟡 Flag mains-voltage, gas, vehicle brakes/steering, swollen lithium batteries, medical devices, lifts. MVP: banner warnings + wiki safety pages; no enforcement.

**58.** Does the platform ever say "don't repair, replace/call a licensed pro"?
> 🟡 Yes, via wiki safety banners; admin decides initially.

**59.** Professional licences as a verification path?
> 🟡 Later: optional uploaded licence → badge.

**60.** Preventing scams?
> 🟡 Report button, ratings tied to real interactions, tip text: "never pay in advance for unseen work." No money on platform reduces exposure.

**61.** Off-platform payment policy?
> 🟡 N/A in MVP: payment is off-platform by design. Rule against advance payment demands; report offenders.

**62.** Liability for theft/damage/injury?
> 🟡 Platform is a directory/community, not the service provider (stated in ToS). No insurance at MVP. For events: organiser responsibilities page. Check with a lawyer.

**63.** Warranty on repairs?
> 🟡 Technician-defined, recorded in the tracking log.

**64.** Data privacy when repairing phones/laptops?
> 🟡 Wiki page "Before you hand over your device" (back up, sign out, lock, factory reset). Requester's responsibility.

**65.** Before/after state verification?
> 🟡 Tracking log encourages before/after photos and serial numbers (optional).

**66.** Stolen goods?
> 🟡 Prohibited by ToS; report; platform can't verify ownership.

**67.** Code of conduct?
> 🟡 Yes, short, plain language, public on the wiki; changes proposed openly, decided by you.

**68.** Rules for reviews of people?
> 🟡 Only for linked interactions; no harassment; report → admin removes violations.

---

## 11. Service Requests (listings-based, requester-documented)

**69.** Fields in a request?
> 🟡 Item, category (optional), brand/model (optional), symptoms, **what I've tried**, photos, neighbourhood, preferred time, free text, optional wiki link.

**70.** Mandatory vs. optional?
> 🟡 Minimum: title + description + area. Everything else optional.

**71.** Link to a catalogue/wiki item?
> 🟡 Yes, optional link to a wiki page.

**72.** Service modes?
> 🟡 Technician visits; requester goes to technician; **at a repair event.** Remote later.

**73.** How do requests reach technicians?
> 🟡 Public board (OLX-style) + direct contact via the directory. No algorithmic matching.

**74.** Pricing model?
> ✅ **Technician decides** the price; the requester tracks it in the log.

**75.** Diagnosis/visit fee?
> 🟡 Technician's call; noted in tracking.

**76.** Price changes after diagnosis?
> 🟡 Recorded in the tracking log; requester agrees directly.

**77.** Cap on responses?
> 🟡 No cap at MVP.

**78.** Request lifetime?
> 🟡 30 days, then auto-archived.

**79.** Categories/tags?
> 🟡 Fixed top-level categories + free tags (wiki categories mirror them).

**80.** "Doesn't fit any category"?
> 🟡 Yes: an "Other / not sure" category. ("Repair anything" is the principle.)

**81.** Ambiguous problems?
> 🟡 Requester documents what they know; community can comment; wiki search suggestions.

**82.** Free community answers before booking?
> 🟡 Yes: comments on requests act as free help.

**83.** Statuses?
> 🟡 Open → In talks → In progress → Fixed / Partly / Not fixed → Closed (or Cancelled).

**84.** Auto-cancel/escalation?
> 🟡 Auto-close at 30 days of inactivity; no escalation.

**85.** Emergency requests?
> 🟡 Not at MVP.

**86.** Recurring/maintenance requests?
> 🟡 Not at MVP.

**87.** Bundling items?
> 🟡 One item per request.

**88.** Public or private?
> 🟡 **Public** (it's "Open"), area-level only; exact address shared privately.

**89.** Showing approximate location?
> 🟡 Neighbourhood on the OSM map until a technician is chosen.

**90.** Cancellations/no-shows?
> 🟡 No penalties at MVP; visible in tracking and reputation.

**91.** Who decides "done"?
> 🟡 Requester marks Fixed/Partly/Not fixed; technician confirms.

**92.** Parts: who buys/pays?
> 🟡 Between the parties; logged in tracking (what, who bought, cost optional).

**93.** Upselling?
> 🟡 Via a tracking-log update the requester accepts.

**94.** Old/replaced parts?
> 🟡 Belong to the requester by default; wiki page on e-waste disposal.

**95.** "Repair vs. replace" advisory?
> 🟡 Wiki guidance only; features later. (Culturally: repair over replace.)

**96.** Second opinions?
> 🟡 New request linked to the previous one.

---

## 12. Matching, Discovery & Search

**97.** How do requesters find technicians?
> 🟡 Directory with a **list + OSM map**, filters by category/area.

**98.** Ranking logic public?
> 🟡 Yes. MVP sorts by distance → trust level → recency. Rules written on the site.

**99.** Paid boosts?
> 🟡 **Never.** Consistent with no ads.

**100.** Cold start for new technicians?
> 🟡 "New" badge and rotation in results.

**101.** Service radius/availability?
> 🟡 Service area + a simple availability note/toggle; calendars later.

**102.** Search across catalogue/docs?
> 🟡 Site search for directory/requests/events; wiki has its own search. Photo/voice search later.

**103.** Saved searches/alerts?
> 🟡 Later.

**104.** Notification channels?
> 🟡 **Email only** (WhatsApp/SMS/push cost or complexity).

**105.** Supply/demand imbalance?
> 🟡 Manual outreach in Kochi; events used to balance.

---

## 13. Payments, Pricing & Money Flow

**106.** On-platform payments in POC?
> ✅ **No money on the platform at MVP.** It's between each other.

**107.** If on-platform, which methods?
> 🟡 N/A.

**108.** Escrow?
> 🟡 N/A.

**109.** How does the platform make money?
> ✅ **It doesn't at MVP** (listings only, no money). Later, after the pivot, possibly a finance-based company built after expert consultation, minimising the use of money. 🟡 Compatible later options: donations, event sponsorships (non-ad), but nothing that violates §2.

**110.** Fee percentage?
> 🟡 **0%.**

**111.** Taxes?
> 🟡 N/A at MVP; consult before any money handling.

**112.** Payouts?
> 🟡 N/A.

**113.** Refunds?
> 🟡 N/A; disputes handled by mediation (§20).

**114.** Chargebacks?
> 🟡 N/A.

**115.** Platform fee on requesters?
> 🟡 None.

**116.** Tipping?
> 🟡 Off-platform at their discretion.

**117.** Free/sponsored repairs?
> 🟡 Repair events can be free or donation-based; organisers decide.

**118.** Community-funded repairs?
> 🟡 Later.

**119.** Course pricing?
> 🟡 No courses; the wiki is free forever.

**120.** Contributor rewards?
> 🟡 Recognition: attribution, wiki history, profile badges. No cash.

**121.** Credits/points?
> 🟡 No.

**122.** Legal/payment compliance?
> 🟡 None needed at MVP because no money is handled; consult before ever doing so.

---

## 14. Radical Transparency

**123.** What's on the transparency page?
> 🟡 Domain/hosting/service costs, donations received, fee taken from repairs (₹0), who paid for what. Hand-updated.

**124.** Granularity?
> 🟡 Line items per bill, monthly.

**125.** Update frequency?
> 🟡 Monthly, manual at first.

**126.** Per-transaction breakdown?
> 🟡 N/A at MVP (no money on platform).

**127.** Team compensation?
> 🟡 None exists yet; if it ever does, publish it.

**128.** Transparency of ranking/moderation?
> 🟡 Ranking rules public; anonymised moderation log later.

**129.** Cost per user/repair?
> 🟡 Later, once there's data.

**130.** Direct donations?
> 🟡 Later; show donated vs. spent.

**131.** Public changelog/roadmap?
> 🟡 Yes, on the wiki / public repo.

**132.** Data you must not expose?
> 🟡 Personal data and security configs.

**133.** Tone of the page?
> 🟡 Friendly, plain, numbers first.

**134.** Audit?
> 🟡 Later.

**135.** Gaming/misreading?
> 🟡 Accept; publishing is the point.

---

## 15. Ratings, Reviews & Reputation

**136.** Rating scale?
> 🟡 1–5 stars + optional short comment ("simpler stupider").

**137.** Two-sided?
> 🟡 Yes; shown after both submit (or after a time window).

**138.** Photos/videos in reviews?
> 🟡 Later.

**139.** Review fraud protection?
> 🟡 Reviews only for linked, closed requests/events; no self-review; report button.

**140.** Technician responses?
> 🟡 Yes.

**141.** Review lifetime/decay?
> 🟡 No decay at MVP; show dates.

**142.** Disputed reviews?
> 🟡 Report → admin removes if rules were broken.

**143.** Profile content?
> 🟡 Photo, real name, bio, skills/categories, area, trust ticks, jobs and events count, rating avg + count, apprentices/mentors, wiki contributions.

**144.** Single public score?
> 🟡 Average + count only. No hidden score.

**145.** Badges?
> 🟡 Phone verified, ID verified, Event regular, Mentor, Apprentice (with hours), Wiki contributor.

**146.** Badges from learning/contributions?
> 🟡 Yes.

**147.** Peer endorsements?
> 🟡 Later.

**148.** Specialisations?
> 🟡 Free tags.

**149.** Proving skill without credentials?
> 🟡 Track record, apprenticeship under a trusted technician, wiki contributions, event participation.

**150.** Portable reputation?
> 🟡 Public profile URL now; export later.

---

## 16. Catalogue (the wiki)

> 🟡 **Decision:** the catalogue **is the wiki** (`wiki.werepair.fyi`, MediaWiki), modelled on repair.wiki. No parts marketplace at MVP.

**151.** What is the catalogue?
> ✅ Knowledge kept on **MediaWiki**, so you don't hand-roll a knowledge base.

**152.** Who populates it at launch?
> 🟡 You, plus community; link to other open sources where licences allow.

**153.** Structure?
> 🟡 Wiki categories: category → brand → model → fault.

**154.** Item page contents?
> 🟡 Specs, common faults, tools needed, linked journals/guides, link to "get it repaired."

**155.** Repairability score?
> 🟡 Later.

**156.** "My garage" items?
> 🟡 Later.

**157.** Service log per product?
> 🟡 Later.

**158.** Marketplace for used items/parts?
> 🟡 No at MVP. (Aggregator idea later, see Q28.)

**159.** Quality/returns responsibility?
> 🟡 N/A.

**160.** Parts compatibility?
> 🟡 Wiki notes.

**161.** Technician parts inventory?
> 🟡 Later.

**162.** Tools lending?
> 🟡 Informal at events; feature later.

**163.** Low-quality entries?
> 🟡 Normal wiki patrol and your moderation.

**164.** Manuals and copyright?
> 🟡 Link out; host only original CC BY-SA content.

**165.** Regional variants?
> 🟡 Noted on the model page.

---

## 17. Repair Journals & Documentation

**166.** What is a journal?
> ✅ Linked to your principle: the **requester documents** problem, debug steps and fix. 🟡 Each request's **tracking log** becomes a journal; on closing as Fixed there's a **"Publish to wiki"** option (CC BY-SA).

**167.** Journal vs. guide vs. fault entry?
> 🟡 Journal = a story of one repair. Guide = reusable how-to. Fault entry = a section on an item page.

**168.** Auto-generated, prompted or manual?
> 🟡 **Prompted** after completion, pre-filled from the tracking log.

**169.** Authoring on a phone?
> 🟡 Simple form with photo upload; step-by-step capture later.

**170.** Consent and privacy for publishing?
> 🟡 The requester authors and publishes it (consent implicit); personal info stripped; technician credited only if they agree.

**171.** Who can edit?
> 🟡 Wiki-style, any logged-in user.

**172.** Versioning and attribution?
> 🟡 MediaWiki history gives this.

**173.** Quality control?
> 🟡 Wiki patrol; "reviewed" tag later.

**174.** Licence?
> 🟡 CC BY-SA 4.0.

**175.** Linking between docs, catalogue, requests?
> 🟡 Two-way links between a request/journal and wiki pages.

**176.** Media?
> ✅ Bulk media on **Wikimedia Commons and YouTube** (to save hosting cost). 🟡 See §29 on what may go there.

**177.** Languages?
> 🟡 English + Malayalam, as contributors allow.

**178.** Mandatory safety callouts?
> 🟡 Yes, a standard red warning template on risky guides.

**179.** Statistics from journals?
> 🟡 Later; potential open dataset.

**180.** Outdated docs?
> 🟡 Wiki "outdated" tag.

**181.** "Wanted" documentation board?
> 🟡 Yes: MediaWiki's wanted-pages list plus requests linking to missing pages.

---

## 18. Upskilling & Learning

**182.** Is learning in the POC?
> 🟡 **Yes, in the form of wiki + apprenticeship at events.** No course product.

**183.** Who creates content?
> 🟡 Community and technicians.

**184.** Formats?
> 🟡 Wiki text + YouTube video.

**185.** Learning paths?
> 🟡 Wiki "path" pages later.

**186.** Skill assessment?
> 🟡 Technician confirms apprentice work.

**187.** Credentials?
> 🟡 Apprenticeship record on the profile.

**188.** Credentials unlocking work?
> 🟡 No gating at MVP.

**189.** Free vs. paid?
> 🟡 Always free.

**190.** Mentorship?
> ✅ Yes via technicians' apprentices at adequate trust level.

**191.** Apprentices on jobs?
> ✅ Yes, tracked and flexed on their bio (🟡 with requester consent for home visits).

**192.** Safe practice?
> 🟡 Repair events using e-waste items.

**193.** Cohorts/challenges?
> ✅ Repair fests are the core version of this.

**194.** "Ask a technician"?
> 🟡 Comments on requests; live help later.

**195.** Gamification?
> 🟡 None; just simple history.

**196.** Institutional partnerships?
> 🟡 Later: colleges/polytechnics as event hosts.

**197.** Learning tied to unmet requests?
> 🟡 Later.

---

## 19. Communication & Collaboration

**198.** How do people talk?
> 🟡 Comments on the request + contact info shown per the **blue-tick rule.** No in-app chat at MVP (cost).

**199.** Chat monitoring?
> 🟡 N/A.

**200.** Media sharing?
> 🟡 Photos on requests; size-limited.

**201.** Structured offers?
> 🟡 No; comment + optional price note.

**202.** System notifications?
> 🟡 New response, status change, event reminder, review request.

**203.** Channels?
> 🟡 Email only.

**204.** Community space?
> 🟡 Request comments + wiki talk pages; no forum.

**205.** Support?
> 🟡 Email (+ WhatsApp by you), best effort.

**206.** Reporting UX?
> 🟡 Report button on every profile/request/comment → admin inbox.

---

## 20. Disputes, Moderation & Governance

**207.** Dispute process?
> 🟡 Report → admin reviews evidence → decision → email appeal.

**208.** Who mediates?
> ✅ You (admin).

**209.** Possible outcomes?
> 🟡 Warning, content removal, suspension, ban.

**210.** Decisions logged publicly?
> 🟡 Anonymised log later.

**211.** Community voting?
> ✅ **No: BDFL model.** You actively consider user requests (public and transparent).

**212.** Advisory council?
> 🟡 Later.

**213.** Volunteer moderators?
> 🟡 Later; volunteers for wiki patrol.

**214.** Severe issue escalation?
> ✅ Retain logs to trace crimes. 🟡 Cooperate with lawful requests; state this in the privacy policy.

**215.** Prohibited content?
> 🟡 Stolen goods, weapons, illegal modifications, safety-device bypassing, counterfeit, harassment, spam.

**216.** Legal takedowns?
> 🟡 Follow Indian legal process; log them; disclose counts.

**217.** ToS/Privacy principles?
> 🟡 Plain language, drafted in the open, reviewed by a lawyer before public beta.

---

## 21. Legal, Compliance & Risk (operational view)

**218.** Licensing requirements?
> ⬜ To research (Kerala/India electrical, gas, vehicle rules). Platform does not endorse licensed or unlicensed work.

**219.** Marketplace/intermediary or provider?
> 🟡 Directory/community; technicians are independent. Stated clearly.

**220.** Worker classification?
> 🟡 Independent individuals; no cut taken reduces the issue. Check with a lawyer.

**221.** Liability/insurance?
> 🟡 Disclaimers; no insurance at MVP; consider event insurance later.

**222.** Personal data protection?
> 🟡 Collect little; keep minimal logs; become DPDP-aware.

**223.** Data deletion/export?
> ✅ Deletion possible. 🟡 Handled manually via email at MVP.

**224.** E-waste?
> 🟡 Wiki page + later partnerships with authorised recyclers.

**225.** Consumer protection/warranty?
> 🟡 Warn users that third-party repair may void manufacturer warranty.

**226.** Legal entity needed for POC?
> 🟡 No (side gig, no money). Needed before handling money.

**227.** Tax registration?
> 🟡 N/A at MVP.

**228.** Minors and consent?
> ✅ 18+ only.

---

## 22. Growth, Community & Operations

**229.** How to get the first 20 technicians and 50 requesters?
> ✅ Word of mouth/referrals. 🟡 Technicians first (directory seeded from OSM + visits in Kochi), requesters via the first repair event.

**230.** City-by-city playbook?
> ✅ "Think local, build local." 🟡 Kochi first; replicate via local volunteers elsewhere.

**231.** Communities to plug into?
> 🟡 FOSS communities, college tech clubs, maker spaces, residents' associations, existing repair cafés.

**232.** Convincing offline technicians?
> ✅ Word of mouth and referrals. 🟡 Personal visits, assisted sign-up, Malayalam UI.

**233.** Referral mechanics?
> 🟡 Invite link recorded on profile; no rewards.

**234.** Offline touchpoints?
> ✅ Repair fests. 🟡 QR stickers on repaired items linking to the wiki page.

**235.** Telling the story?
> 🟡 Build in public; public changelog.

**236.** Qualitative feedback?
> 🟡 Post-event feedback form.

**237.** Metrics to watch?
> 🟡 Active users, requests posted/closed, events held, active technicians, wiki edits.

**238.** Which are public?
> 🟡 All, aggregated.

**239.** Support hours?
> 🟡 Best effort.

**240.** What can be manual in POC?
> 🟡 Everything except directory, requests and event posting.

**241.** Operations roles?
> 🟡 You (+ intern).

**242.** What if it runs out of money?
> 🟡 Publish a wind-down plan: open data export; the wiki (CC BY-SA) and code (AGPL) persist.

---

## 23. UX / UI: Experience Design

### 23.1 Brand, tone & feel
**243.** Personality adjectives?
> 🟡 Practical, warm, community, workshop-like, unpretentious.

**244.** Visual direction?
> 🟡 Friendly community toolbox / flea-market feel.

**245.** Reference apps?
> ✅ QuickRide (flow), OLX (listings), repair.wiki and repaircafe.org (concept). ⬜ Dislikes?

**246.** Logo/colours/type?
> ⬜ Open.

**247.** Photo/illustration style?
> 🟡 Real photos of real repairs.

**248.** Voice?
> 🟡 Plain, warm, short; English + Malayalam.

**249.** Dark mode?
> 🟡 Yes, follows system.

**250.** Showing "Open" visually?
> 🟡 "What it costs" in header and footer; open-source and wiki links in footer.

### 23.2 Platform & device
**251.** Web / PWA / native?
> 🟡 Web, mobile-first; installable PWA later; no native app.

**252.** Devices/screens?
> 🟡 Mid-range Android Chrome (last ~3 years) + desktop browsers.

**253.** Network conditions?
> 🟡 Design for slow connections; light pages.

**254.** Low-data mode?
> 🟡 Light by default.

**255.** Languages?
> 🟡 English + Malayalam; LTR only.

**256.** Accessibility?
> 🟡 Contrast, large tap targets, labels.

**257.** Voice-first input?
> 🟡 Later.

**258.** Assisted mode?
> ✅ Yes: volunteers can help (🟡 especially at events).

### 23.3 Landing & discovery
**259.** First 5 seconds?
> 🟡 Three paths: "Get something fixed", "I fix things", "Repair events near you".

**260.** Primary CTA?
> 🟡 Primary: find an event / technician near you. Secondary: post a request.

**261.** Hero element?
> 🟡 Search bar + category grid.

**262.** Social proof?
> 🟡 Real, small, honest counts (repairs, events, technicians).

**263.** Live activity feed?
> 🟡 No.

**264.** Where does the transparency link live?
> 🟡 Header and footer.

**265.** What do logged-out visitors see?
> 🟡 Everything public except contact details and exact addresses.

### 23.4 Requester UX
**266.** Create-request wizard style?
> 🟡 One short page.

**267.** Happy-path length?
> 🟡 One page, under 2 minutes.

**268.** Capturing the problem?
> 🟡 Photo upload + text; voice later.

**269.** Smart suggestions?
> 🟡 Later (wiki link suggestions).

**270.** Price expectation?
> 🟡 None at MVP; past price notes later.

**271.** How offers appear?
> 🟡 Responses as comments with an optional price note.

**272.** How requester chooses?
> 🟡 Contacts technician and marks "chosen."

**273.** Tracking screen?
> 🟡 Simple status timeline + the tracking log.

**274.** Completion UI?
> 🟡 Requester marks done; no payment UI.

**275.** Post-repair prompts?
> 🟡 Rate, publish journal to wiki, say thanks.

**276.** Dashboard?
> 🟡 My requests, my events, saved technicians.

### 23.5 Technician UX
**277.** Onboarding?
> ✅ Short. 🟡 Under 5 minutes: name, area, skills, phone.

**278.** Declaring skills?
> 🟡 Category checklist + free tags.

**279.** Request feed?
> 🟡 List + map with filters.

**280.** Quote composer?
> 🟡 No composer; reply with optional price note.

**281.** Job execution mode?
> 🟡 Tracking log (notes, photos, parts used).

**282.** Earnings view?
> 🟡 N/A; job and event counts only.

**283.** Profile completeness?
> 🟡 Completion meter + next-step hints.

**284.** Trust-level progress?
> 🟡 Ticks + checklist.

**285.** Availability?
> 🟡 Simple toggle/note.

**286.** Workshop profile?
> 🟡 Optional shop location on the OSM map for drop-off repairs.

**287.** Turning jobs into journals?
> 🟡 One-tap "publish to wiki" from the tracking log.

### 23.6 Catalogue, docs & learning UX
**288.** Item page above the fold?
> 🟡 Title, photo, common faults, "get it fixed" button.

**289.** Catalogue → request in one tap?
> 🟡 Yes, item pre-filled.

**290.** Guide reading experience?
> 🟡 MediaWiki mobile skin.

**291.** Journal authoring?
> 🟡 MediaWiki editor, pre-filled from the log.

**292.** Safety warnings?
> 🟡 Red banner template, not dismissible.

**293.** Course UI?
> 🟡 N/A.

**294.** Credentials display?
> 🟡 Profile ticks and apprenticeship history.

**295.** Learning dashboard?
> 🟡 N/A.

### 23.7 Transparency UX
**296.** Dashboard visuals?
> 🟡 Headline numbers + simple table.

**297.** Headline numbers?
> 🟡 "This month: ₹X to run · 0% taken from repairs · ₹Y donated."

**298.** Drill-down?
> 🟡 Link redacted invoices/receipts.

**299.** Per-repair receipts?
> 🟡 N/A.

**300.** "Why am I seeing this?"
> 🟡 One-line plain explanation of sort order.

### 23.8 Trust & safety UX
**301.** Badge design?
> 🟡 Simple blue-tick-style icons with text labels.

**302.** ID/face verification flow?
> 🟡 Later; short, with reassurance copy and a promise of deleting images.

**303.** SOS button?
> 🟡 Later; events are public settings.

**304.** High-risk category UX?
> 🟡 Notice banner on the category page.

**305.** Off-platform payment warnings?
> 🟡 Notice on the request page ("never pay in advance for unseen work").

**306.** Report flow?
> 🟡 Report button → short form.

### 23.9 States, errors & edge cases
**307.** No responses?
> 🟡 "No responses yet" + wiki help + directory suggestions.

**308.** Technician cancels?
> 🟡 Requester can reopen/relist.

**309.** Empty states for new technicians?
> 🟡 Encouraging checklist.

**310.** Item not repairable?
> 🟡 "Honest no" page with recycle/resell/replace wiki guide.

**311.** Verification failure?
> 🟡 Manual email fallback.

**312.** Payment failure?
> 🟡 N/A.

**313.** Offline/loading?
> 🟡 Basic offline message.

### 23.10 Navigation
**314.** Top-level nav?
> 🟡 Home · Requests · Technicians · Events · Wiki · What it costs · Profile.

**315.** Role switcher?
> ✅ No.

**316.** Mobile bottom nav?
> 🟡 Home · Events · Post (+) · Technicians · Profile (wiki and cost under a menu).

**317.** Notifications?
> 🟡 Bell icon + email.

**318.** Footer?
> 🟡 ToS, privacy, code (AGPL), wiki, What it costs, contact, donate (later).

---

## 24. Content Strategy & Seeding

**319.** What must exist before launch?
> 🟡 ~20 technicians in Kochi, ~20 wiki pages, one event planned.

**320.** Who writes the first guides?
> 🟡 You + community.

**321.** Demo data?
> 🟡 Clearly labelled; removed before launch.

**322.** Editorial standard?
> 🟡 Simple; safety review for risky guides.

**323.** Content calendar?
> 🟡 No.

**324.** Credit for contributors?
> 🟡 Wiki attribution + profile.

---

## 25. Data, Openness & Ethics

**325.** Data published openly?
> 🟡 Wiki, aggregated stats, cost ledger.

**326.** Data never shared?
> ✅ User data is never sold. 🟡 Contacts, IDs, addresses, chat never shared.

**327.** Open API/dataset?
> 🟡 Later; MediaWiki API exists.

**328.** AI features?
> 🟡 Optional, disclosed, off by default, not at MVP.

**329.** Training on user content?
> ⬜ Open (public CC BY-SA content is by nature reusable; private data never).

**330.** Bias?
> 🟡 Watch for it; fair rotation in listings.

**331.** Right-to-repair stance?
> 🟡 Supportive; light advocacy.

**332.** Environmental impact?
> 🟡 Nice-to-have: an "e-waste avoided" counter later.

---

## 26. POC / MVP Scoping (the cut line)

**333.** If you could ship only three features first?
> ✅ Your own framing: **directory of technicians + repair events (with volunteers/apprentices) + requests with tracking.** 🟡 Plus the public cost page and the wiki.

**334.** Must / manual / deferred?
> 🟡
> - **Must exist:** account (basic auth), technician profile + directory (list/OSM), request posting + tracking log, event creation + sign-ups, ratings, "What it costs" page, wiki link, report button.
> - **Can be manual:** Kochi technician seeding, event organisation, moderation, matching via WhatsApp, cost page updates.
> - **Deferred:** OAuth, phone/ID/face verification, payments, chat, orgs, marketplace, courses, catalogue UI, PWA, Malayalam polish, notifications beyond email.

**335.** Manual matching in POC?
> 🟡 Yes, you or volunteers.

**336.** Transparency dashboard hand-updated?
> 🟡 Yes.

**337.** ID verification in POC?
> 🟡 Skip.

**338.** Off-platform payments?
> ✅ Yes.

**339.** Trust levels in POC?
> 🟡 L0, L1, L5.

**340.** Minimum catalogue size?
> 🟡 ~20 wiki pages.

**341.** Minimum docs/journals?
> 🟡 ~20 pages + ~5 journals.

**342.** Minimum technicians?
> 🟡 ~20 across Kochi.

**343.** Top 5 risks?
> 🟡 No supply (technicians don't join) · no demand · safety incident at an event · solo bandwidth · legal/liability gap.

**344.** Mitigations and tripwires?
> ⬜ Open: the first event is your natural tripwire.

---

## 27. Open-Ended / Wildcard

**345.** Best possible day?
> ⬜ Open: yours to write.

**346.** Worst possible day?
> ⬜ Open.

**347.** The person you most want to help?
> ⬜ Open.

**348.** Five years from now?
> ⬜ Open.

**349.** Non-negotiables?
> 🟡 From your answers: open, no ads, no selling data, repair over replace, no middleman cut. Confirm.

**350.** What does everyone believe that you think is wrong?
> ⬜ Open.

**351.** Weirdest thing to repair?
> ⬜ Open.

**352.** If acquired with conditions compromising openness?
> ⬜ Open (your non-negotiables above suggest "no").

**353.** What should it feel like at 3 a.m.?
> ⬜ Open.

**354.** What didn't I ask?
> ⬜ Open.

---

## 29. New Questions Raised by Your Answers

### Repair Events / Fests
**355.** Who can organise an event: only you, or any trusted-level technician?
> 🟡 You at first; trusted technicians later.

**356.** What's an event page contain?
> 🟡 Date, venue (OSM), theme, technician list, volunteer slots, items accepted, safety rules, contact.

**357.** How do items get registered: pre-registration or walk-in queue?
> 🟡 Both; pre-registration optional.

**358.** Who is responsible for venue, permissions, power safety and fire safety?
> ⬜ Open: needs an organiser checklist.

**359.** Insurance or liability waiver for events?
> 🟡 Simple waiver/notice at sign-up; consider insurance later.

**360.** How are no-shows (technicians/volunteers) handled?
> 🟡 Visible in event history; no penalty.

**361.** Who confirms apprentice/volunteer hours?
> 🟡 The technician they worked under.

**362.** Can an apprentice be under more than one technician?
> 🟡 Yes.

**363.** Minimum trust level to host apprentices?
> ⬜ Open (e.g., X events + rating ≥ Y).

**364.** Event types: domain-themed fests, regular monthly café, one-off?
> 🟡 All, flagged by theme.

**365.** What happens to items left over / unrepaired?
> 🟡 Returned to owner; organiser doesn't keep items.

### Wiki integration
**366.** Single sign-on between werepair.fyi and wiki.werepair.fyi?
> 🟡 Desirable; if too costly, separate wiki accounts at MVP.

**367.** Is the real-name rule enforced on the wiki, too?
> 🟡 Wiki usernames may differ but link to the platform profile for credit.

**368.** Who can create new wiki pages?
> 🟡 Any logged-in user.

**369.** Wiki spam control?
> 🟡 Account required, rate limits, your moderation.

**370.** Naming and structure convention for wiki pages?
> ⬜ Open (model on repair.wiki).

### Media policy
**371.** What may go to Wikimedia Commons?
> 🟡 Only media the owner is happy to license freely (CC BY-SA/CC0), with no faces, personal info, serial numbers or addresses.

**372.** What may go to YouTube?
> 🟡 Public how-to videos under a clear licence, with consent.

**373.** What media is never public?
> 🟡 ID images, chats, private home photos.

**374.** Where does private/in-between media live (request photos not meant for the wiki)?
> ⬜ Open (storage cost is a constraint).

### OSM / directory
**375.** Do you add technicians/shops as OSM POIs, or only display OSM maps?
> 🟡 Display only for individuals (privacy); shops may be added with their consent.

**376.** How to show individuals who work from home without exposing addresses?
> 🟡 Neighbourhood-level pin only.

**377.** How are directory entries seeded before technicians sign up themselves?
> ⬜ Open (claimable listings? consent?).

### Governance and money, later
**378.** What are the triggers to move from listings-only to handling money?
> ⬜ Open (e.g., user demand, reaching N repairs).

**379.** What would "reduce money handling to the smallest possible" look like?
> ⬜ Open.

### Requester responsibility
**380.** What happens if a requester refuses or forgets to document?
> 🟡 Gentle reminders; ratings reflect cooperation; no penalty.

**381.** Is documenting a *hard* requirement to close a request?
> 🟡 No: a minimum (outcome + short note) is required; full journal is encouraged.

### Parking Lot

- **Decisions:** see ✅ answers above.
- **Out of scope for this doc:** architecture, technical spec, code.
