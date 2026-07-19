# App Store Checklist — sommerhusOrden

Status per 2026-07-19 (fas 6). ☐ = kvarstår för Mikkel, ☑ = klart i koden.

## Technical
- [x] App builds on current Xcode stable version (Xcode 16.4, verifierat)
- [x] Bundle identifier chosen (`se.mikkelwulff.sommerhusOrden`)
- [x] iCloud/CloudKit capability configured (entitlements + kod; team måste väljas, se docs/CLOUDKIT_SETUP.md)
- [x] App icon added (platshållare — byt gärna mot riktig design före release)
- [x] Launch screen works (genererad launch screen)
- [x] No hardcoded secrets
- [x] No private APIs
- [x] Privacy manifest included (`sommerhusOrden/PrivacyInfo.xcprivacy`: ingen tracking, ingen datainsamling, inga deklarerade required-reason-API:er)
- [x] Works on supported iOS version range (iOS 17+)

## Product
- [x] First-run experience explains iCloud requirement (Inställningar visar synk-status och hjälptext; tomlägen förklarar varje flik)
- [x] Empty states are helpful
- [x] Error states are understandable (iCloud otillgängligt, synkfel visas i Inställningar)
- [x] Offline/unavailable iCloud state handled (lokal lagring alltid; svensk hjälptext)
- [ ] All core flows tested on device/simulator (kör docs/MANUAL_QA_CHECKLIST.md; iCloud-stegen kräver riktiga konton)

## Privacy
- [x] No ads
- [x] No analytics
- [x] Privacy policy prepared (docs/PRIVACY_POLICY.md — publicera på URL)
- [ ] App Store privacy answers align with actual data usage (svara "Ingen datainsamling" — utvecklaren samlar inget; data ligger i användarens iCloud)

## Store listing
- [x] App name: sommerhusOrden
- [x] Subtitle drafted (docs/APP_STORE_LISTING.md)
- [x] Description drafted
- [x] Keywords drafted
- [ ] Screenshots prepared (lista i docs/APP_STORE_LISTING.md)
- [ ] Support URL prepared (platshållare finns — publicera sida)
- [ ] Privacy policy URL prepared (platshållare finns — publicera sida)

## Review risk notes
- Appen är formulerad generellt: "familjeapp för delat fritidshus", inte bunden till en namngiven familj.
- iCloud-krav förklaras i appen; utan iCloud fungerar appen lokalt (bör undvika review-avslag).
