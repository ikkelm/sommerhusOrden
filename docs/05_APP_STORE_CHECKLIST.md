# App Store Checklist — sommerhusOrden

Status per 2026-07-21. ☐ = kvarstår för Mikkel, ☑ = klart i koden.

## Technical
- [x] App builds on current Xcode stable version (Xcode 26.6: Release-bygge för enhet
      lyckas, 45 tester passerar)
- [x] Bundle identifier chosen (`se.mikkelwulff.sommerhusOrden`)
- [x] Signeringsteam valt i projektet (`DEVELOPMENT_TEAM = 7SZ4X2N2U7`)
- [x] iCloud/CloudKit capability configured (entitlements + kod, se docs/CLOUDKIT_SETUP.md)
- [x] App icon added (riktig ikon från logo.png, 1024×1024 utan alpha)
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
- [x] Privacy policy prepared (docs/PRIVACY_POLICY.md; färdig sida i web/integritet.html)
- [ ] App Store privacy answers align with actual data usage (svara "Ingen datainsamling" — utvecklaren samlar inget; data ligger i användarens iCloud)

## Store listing
- [x] App name: sommerhusOrden
- [x] Subtitle drafted (docs/APP_STORE_LISTING.md)
- [x] Description drafted
- [x] Keywords drafted
- [x] Screenshots prepared (4 st 6.9" i `screenshots/`, se screenshots/README.md;
      Inställningar-bilden kräver enhet med iCloud)
- [ ] Support URL prepared (sida klar i web/support.html — ladda upp)
- [ ] Privacy policy URL prepared (sida klar i web/integritet.html — ladda upp)

## Review risk notes
- Appen är formulerad generellt: "familjeapp för delat fritidshus", inte bunden till en namngiven familj.
- iCloud-krav förklaras i appen; utan iCloud fungerar appen lokalt (bör undvika review-avslag).
