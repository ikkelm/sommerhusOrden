# Email body — sommerhusOrden Codex package

Subject: sommerhusOrden – Codex-prompter och projektinstruktioner

Hej Mikkel,

Här kommer Codex-paketet för iOS-appen **sommerhusOrden**.

Syfte:
En native iOS-app för närmaste familjen som hjälper till med:

1. **Stugplanering**
   - vilka familjer är i stugan
   - vilka datum/veckor
   - hur många personer/sängplatser som behövs
   - varning om max antal sängplatser överskrids

2. **Mat och inköp**
   - vad finns i kyl/frys/skafferi/hushåll
   - sök t.ex. oregano eller mjölk
   - gemensam inköpslista

Beslut som är inarbetade:
- Alla familjemedlemmar kan ändra allt.
- Max antal sängplatser startar på 10 och kan ändras i inställningar.
- Bokning sker per familj/grupp, med antal personer som faktiskt kommer per vistelse.
- Appnamn: sommerhusOrden.
- Rekommenderad stack: Swift, SwiftUI, CloudKit/iCloud, XCTest.
- Målet är en proffsig App Store-redo app med minimal handpåläggning.

Rekommenderad Codex-ordning:
1. Läs `00_MASTER_PROMPT.md`
2. Följ `11_CODEX_PROMPT_PHASE_0_1_PROJECT_SETUP.md`
3. Fortsätt fas för fas:
   - Phase 2: Stugvistelser
   - Phase 3: Inventarie
   - Phase 4: Inköpslista
   - Phase 5: CloudKit/iCloud sync
   - Phase 6: App Store-polish
   - Phase 7: Release candidate

/J
