# InternshipSaathi

**Your companion for the right internship.**

InternshipSaathi is a Flutter mobile app that matches students with internships
based on their **skills, location, interests and career goals**. Instead of
making students scroll through endless unfiltered listings, it ranks every
internship by how well it fits *them* and explains *why* each one matched.

---

## Contents
- [Highlights](#highlights)
- [Run it in 60 seconds (demo mode)](#run-it-in-60-seconds-demo-mode)
- [The matching engine](#the-matching-engine)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Connecting Firebase (optional)](#connecting-firebase-optional)
- [Testing](#testing)

---

## Highlights
- 🔐 **Authentication** — email/password sign-up & sign-in.
- 🧑‍🎓 **Student profile** — skills, location, interests, career goals, bio.
- ✨ **Smart matching** — every internship scored 0–100 and ranked best-first.
- 📊 **Explainable matches** — a per-dimension breakdown shows *why* something matched.
- 🔎 **Browse & search** — full catalog with free-text search, still match-scored.
- 📝 **Applications** — apply in one tap and track status.
- 🌓 **Material 3** design with light & dark themes.
- 🧪 **Unit-tested** matching logic.
- 🔌 **Two backends, one switch** — runs on an in-memory demo store out of the
  box, or on **Firebase Auth + Cloud Firestore** by flipping a single flag.

---

## Run it in 60 seconds (demo mode)

The app ships in **demo mode** (`AppConfig.useFirebase = false`), so it runs
with **no backend setup at all** — ideal for a quick look or a classroom demo.

```bash
flutter pub get
flutter run
```

Sign in with the pre-seeded demo account:

| Email              | Password |
|--------------------|----------|
| `demo@saathi.app`  | `123456` |

…or tap **"Fill demo credentials"** on the login screen. You can also create a
new account and build a fresh profile. In demo mode the data lives in memory
and resets when the app restarts — which keeps demos clean and predictable.

---

## The matching engine

The heart of the app is [`lib/services/matching_service.dart`](lib/services/matching_service.dart):
a **pure Dart** class (no Flutter, no Firebase), which makes it fast,
deterministic and easy to unit-test.

It scores an internship against a student across **four dimensions** and
combines them with weights that sum to 1.0:

| Dimension      | Weight | How it's scored |
|----------------|:------:|-----------------|
| **Skills**     |  40%   | Fraction of the internship's required skills the student actually has (skill *coverage*). |
| **Interests**  |  25%   | Jaccard overlap between the student's interests and the internship's domains. |
| **Location**   |  20%   | Remote → 100 for anyone; same city → 100; different city → 30 (relocation possible). |
| **Career goals** | 15%  | Jaccard overlap between the student's goals and the internship's career tracks. |

```
finalScore = 0.40·skills + 0.25·interests + 0.20·location + 0.15·goals   // 0–100
```

Scoring is **case- and whitespace-insensitive**, so "` GIT`" matches "`Git`".
Each result also carries a **breakdown** (per-dimension sub-scores) and the
list of **matched skills**, which the detail screen renders as progress bars
and checkmarks — turning an opaque number into an explanation a student trusts.

**Why these weights?** Skills decide whether a student can actually do the
work, so they dominate. Interests and goals shape satisfaction and direction.
Location is a real constraint but shouldn't override a great fit — hence a
soft, non-zero score for other cities. The weights live in one constant and
are trivial to tune.

---

## Architecture

The app follows a clean, layered design. Every layer depends only on the one
below it, and the UI depends only on **abstract** service interfaces — so the
entire backend can be swapped without touching a single screen.

```
┌────────────────────────────────────────────────────┐
│  Screens (UI)         auth · matches · browse · …    │
├────────────────────────────────────────────────────┤
│  Providers (state)    AuthProvider · SessionProvider │  ← ChangeNotifier + Provider
├────────────────────────────────────────────────────┤
│  Services (logic)     MatchingService                │
│                       AuthService  ┐  (interfaces)   │
│                       DataService  ┘                 │
│                        ╱         ╲                   │
│                 Local (in-memory)   Firebase         │  ← chosen by ServiceLocator
├────────────────────────────────────────────────────┤
│  Models               Student · Internship · …       │
└────────────────────────────────────────────────────┘
```

- **`AuthService` / `DataService`** are interfaces with **two implementations
  each**: an in-memory one for the demo and a Firebase/Firestore one for
  production.
- **`ServiceLocator`** reads `AppConfig.useFirebase` and hands out the right
  implementation. This is the *only* place that knows which backend is live.
- **`SessionProvider`** is wired to `AuthProvider` via a
  `ChangeNotifierProxyProvider`: when the signed-in user changes, the session
  reloads the profile, catalog and applications, and re-ranks matches.

---

## Project structure

```
lib/
├── main.dart                     App entry, Firebase init, provider wiring
├── firebase_options.dart         Placeholder — overwritten by `flutterfire configure`
├── models/
│   ├── student.dart              Student profile (the matchable fields)
│   ├── internship.dart           Internship posting
│   ├── application.dart          A student's application
│   └── match_result.dart         Score + per-dimension breakdown
├── services/
│   ├── matching_service.dart     ★ the recommendation engine (pure Dart)
│   ├── auth_service.dart         Auth interface + AuthUser
│   ├── data_service.dart         Data interface
│   ├── service_locator.dart      Picks local vs. Firebase
│   ├── local/                    In-memory demo backend
│   └── firebase/                 Firebase Auth + Firestore backend
├── providers/
│   ├── auth_provider.dart        Auth state & actions
│   └── session_provider.dart     Profile, catalog, matches, applications
├── screens/
│   ├── auth/                     Gate, login, register, profile setup
│   ├── home/                     Bottom-nav shell
│   ├── matches/                  Ranked recommendations (home tab)
│   ├── internship/              Browse + detail (with match breakdown)
│   ├── applications/             Application tracking
│   └── profile/                  View & edit profile
├── widgets/                      Reusable UI (match card, score ring, chips…)
├── data/seed_data.dart           10 sample internships + demo student
└── utils/                        Constants (skill/interest catalogs), theme
test/
└── matching_service_test.dart    Unit tests for the engine
```

---

## Connecting Firebase (optional)

Demo mode needs nothing. To run on a real backend:

1. **Install the tooling** (one time):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```
2. **Create a Firebase project** at <https://console.firebase.google.com>.
   - Enable **Authentication → Email/Password**.
   - Create a **Cloud Firestore** database.
3. **Generate the config** from the project root:
   ```bash
   flutterfire configure
   ```
   This overwrites `lib/firebase_options.dart` and adds the platform files
   (`google-services.json`, etc.).
4. **Enable Firebase** — in [`lib/utils/constants.dart`](lib/utils/constants.dart):
   ```dart
   static const bool useFirebase = true;
   ```
5. **Run it.** On first launch, open **Profile → "Seed sample internships"**
   to populate Firestore with the bundled catalog.

Suggested Firestore security rules for development:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /students/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /internships/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;   // tighten for production
    }
    match /applications/{id} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Testing

```bash
flutter analyze    # static analysis — expect: No issues found!
flutter test       # unit tests for the matching engine
```

The tests cover skill coverage, remote/same-city/other-city location scoring,
case-insensitive matching, best-first ranking with a score threshold, and the
invariant that the weights sum to 1.0.
