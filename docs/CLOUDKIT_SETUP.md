# CloudKit Setup — manuella steg för Mikkel

Synkarkitekturen är implementerad i koden (CKSyncEngine, se `sommerhusOrden/CloudKit/`),
men följande steg kräver Apple Developer-konto och kan inte automatiseras härifrån.

## 1. Signering (krävs innan CloudKit fungerar)

1. Öppna `sommerhusOrden.xcodeproj` i Xcode.
2. Välj targetet **sommerhusOrden** → fliken **Signing & Capabilities**.
3. Välj ditt **Team** (Apple Developer-medlemskap krävs för CloudKit).
4. Kontrollera att bundle-id är `se.mikkelwulff.sommerhusOrden` (eller byt till ditt eget —
   ändra då även container-id, se nedan).

## 2. iCloud-container

Entitlements-filen (`sommerhusOrden/sommerhusOrden.entitlements`) pekar på containern:

```text
iCloud.se.mikkelwulff.sommerhusOrden
```

När du valt team skapar Xcode containern automatiskt första gången du bygger,
eller via **Signing & Capabilities → iCloud → Containers**.

Byter du bundle-id: uppdatera även `CloudKitSyncService.containerIdentifier`
i `sommerhusOrden/CloudKit/CloudKitSyncService.swift` och entitlements-filen.

## 3. CloudKit-schema

Recordtyperna (`CottageStay`, `InventoryItem`, `ShoppingListItem`, `CottageSettings`)
skapas automatiskt i **utvecklingsmiljön** första gången appen sparar data.

Innan App Store-release: gå till [CloudKit Console](https://icloud.developer.apple.com),
välj containern och **deploya schemat från Development till Production**.
Utan detta steg fungerar synk inte i App Store-versionen.

## 4. Testa synk (kräver riktiga enheter/konton)

Detta kan inte verifieras i simulator utan iCloud-inloggning:

1. Kör appen på två enheter/simulatorer inloggade med **samma** iCloud-konto —
   ändringar ska dyka upp på båda.
2. Familjedelning: Inställningar → **Dela med familjen** öppnar systemets
   delnings-UI. Standard är privat delning: bjud in familjemedlemmar
   (annat iCloud-konto) via Kontakter/Meddelanden. I samma UI kan du senare
   hantera deltagare eller avsluta delningen.
3. Familjemedlemmen öppnar inbjudan på sin enhet med appen installerad,
   accepterar, och ser därefter samma data.

## 5. Push-noteringar

CKSyncEngine använder tysta CloudKit-pushar internt (`remote-notification`-bakgrundsläget
och `aps-environment` finns i projektet). Inga användarsynliga pushar skickas —
det är infrastruktur för synk, inte notiser.

## Beteende utan iCloud

- Utan iCloud-konto visar Inställningar:
  "iCloud behövs för att synka med familjen. Du kan fortfarande se lokala data om de finns på enheten."
- All data sparas alltid lokalt (`Application Support/sommerhusOrden/store.json`)
  och synkas när iCloud blir tillgängligt.

## Konfliktregler (implementerade)

- Last-writer-wins per record via `updatedAt`/`lastUpdatedAt`.
- Stabila UUID-baserade recordnamn (`stay-<uuid>` osv.) förhindrar dubbletter.
- Zonen `SommerhusZone` i ägarens privata databas delas i sin helhet (zon-delning)
  med familjen; alla deltagare kan redigera allt.
