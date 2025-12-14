 Human Steps Remaining

  Category 1: Blocked Stories (Requires Human Involvement)

  EPIC-003 - Conspiracy Board UI:
  | Story     | Task                              | Notes                       |
  |-----------|-----------------------------------|-----------------------------|
  | BOARD-001 | Create Figma prototype            | Design tool access required |
  | BOARD-002 | Recruit 10 testers for validation | Human recruitment task      |
  | BOARD-003 | Achieve 8/10 user satisfaction    | Depends on BOARD-001/002    |

  EPIC-004 - Environmental Data:
  | Story    | Task                        | Notes                                                     |
  |----------|-----------------------------|-----------------------------------------------------------|
  | DATA-005 | NGO partnership outreach    | Template in conspiracy_board/content/outreach_template.md |
  | DATA-006 | NGO content review/approval | Depends on DATA-005                                       |

  ---
  Category 2: Steam Integration (Requires Steam Developer Account)

  | Task               | Current State             | Required Action                                    |
  |--------------------|---------------------------|----------------------------------------------------|
  | Steam App ID       | Using 480 (Spacewar test) | Register your own App ID at partner.steamgames.com |
  | GodotSteam plugin  | Stub implementation       | Download/integrate actual GodotSteam plugin        |
  | Steam achievements | Framework ready           | Configure in Steamworks dashboard                  |
  | Steam Cloud        | Stub ready                | Enable after GodotSteam integration                |

  ---
  Category 3: Hardware Testing (Requires Physical Hardware)

  | Target             | Requirement              | Notes                           |
  |--------------------|--------------------------|---------------------------------|
  | GTX 1060 @ 1080p   | 60fps minimum            | Performance validation          |
  | Steam Deck @ 800p  | 55fps minimum            | Need actual Steam Deck hardware |
  | Linux build        | Steam runtime compatible | Need Linux test environment     |
  | Controller support | XInput validation        | Physical controller testing     |

  ---
  Category 4: Art & Audio Assets (Placeholders Used)

  Art:
  - Frog player sprite
  - Boss sprites (Lobbyist, CEO)
  - Enemy sprites (Polluted Tadpole, Toxic Minnow)
  - Corkboard background (1920x1080)
  - Informant portraits (Deep Croak, Lily Padsworth)

  Audio:
  - hit_thwap.wav - Tongue hit sound
  - death_glorp.wav - Enemy death sound
  - Background music tracks
  - UI sounds

  ---
  Category 5: Accessibility Validation

  | Task                  | Tool/Method                          |
  |-----------------------|--------------------------------------|
  | Screen reader testing | NVDA/JAWS (external tools)           |
  | Colorblind validation | User testing with colorblind players |
  | WCAG AA contrast      | Manual color checker validation      |

  ---
  Summary

  | Category              | Count      | Priority                             |
  |-----------------------|------------|--------------------------------------|
  | Blocked stories       | 5          | P0 for NGO partnership, P2 for Figma |
  | Steam setup           | 4 tasks    | P0 for launch                        |
  | Hardware testing      | 4 devices  | P0 for launch                        |
  | Art/Audio assets      | ~15 assets | P0 for launch                        |
  | Accessibility testing | 3 methods  | P0 (WCAG compliance)                 |

  Total code implementation: ✅ Complete (78/78 stories)
  Human-dependent tasks: ~20 items remaining