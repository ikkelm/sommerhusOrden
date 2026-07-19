# App Store-inlämningsanteckningar — sommerhusOrden 1.0

## Före inlämning — måste göras (kräver Mikkel/Apple-konto)
1. Välj signeringsteam i Xcode och bygg mot en riktig enhet (docs/CLOUDKIT_SETUP.md §1–2).
2. Testa iCloud-synk och delning med två riktiga konton (docs/CLOUDKIT_SETUP.md §4).
3. Deploya CloudKit-schemat Development → Production i CloudKit Console.
4. Publicera integritetspolicy (docs/PRIVACY_POLICY.md) och supportsida; ersätt
   platshållar-URL:erna i docs/APP_STORE_LISTING.md.
5. Ta skärmbilder (lista i docs/APP_STORE_LISTING.md).
6. Valfritt men rekommenderat: ersätt platshållarikonen.
7. Kör hela docs/MANUAL_QA_CHECKLIST.md på enhet.

## App Store Connect-uppgifter
- Bundle-id: `se.mikkelwulff.sommerhusOrden`
- Kategori: Livsstil (sekundär: Produktivitet)
- Pris: Gratis
- Åldersgräns: 4+
- Integritetsdeklaration: "Data samlas inte in" (utvecklaren har ingen åtkomst;
  all data ligger i användarens iCloud)
- Metadata: se docs/APP_STORE_LISTING.md

## Release notes 1.0 (utkast)
> Första versionen av sommerhusOrden — familjens app för den delade stugan:
> - Planera vistelser och se direkt om sängplatserna räcker
> - Håll koll på kyl, frys, skafferi och hushåll med snabb sökning
> - Gemensam inköpslista som hela familjen ser
> - Synk via iCloud med delningslänk till familjen — inga konton, inga annonser

## Anteckning till App Review
Appen är en generell samordningsapp för familjer som delar fritidshus.
iCloud används för synk/delning; utan iCloud fungerar appen lokalt med
en tydlig svensk förklaring i Inställningar. Ingen egen inloggning,
inga annonser, ingen analys, ingen datainsamling av utvecklaren.
Demo kräver inget konto: skapa vistelser/varor direkt vid första start.
