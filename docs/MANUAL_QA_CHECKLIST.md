# Manuell QA-checklista — sommerhusOrden

Kör igenom före varje TestFlight/App Store-bygge. Simulator räcker för allt utom iCloud-stegen.

## Grundflöden
- [ ] Appen startar utan krasch (kall start)
- [ ] Alla fyra flikar öppnas och visar vettiga tomlägen vid första start

## Stugan
- [ ] Lägg till vistelse; syns i veckoöversikten med rätt vecka
- [ ] Redigera vistelse (tryck på rad eller svep → Redigera)
- [ ] Ta bort vistelse; bekräftelsedialog visas; radera fungerar
- [ ] Skapa två överlappande vistelser som överskrider max → "Överbokat"-varning i rött
- [ ] Vistelse fredag–söndag räknas som fredag- och lördagsnatt (inte söndagsnatt)
- [ ] Anteckning visas på raden

## Mat
- [ ] Lägg till vara i varje kategori
- [ ] Sök hittar vara oavsett stora/små bokstäver ("OREGANO" hittar "oregano")
- [ ] Kategorichips filtrerar; "Alla" nollställer
- [ ] Ändra status via håll-intryckt-menyn; "Uppdaterad …" ändras
- [ ] Svep → "Till inköp" lägger varan i inköpslistan (bekräftelse-banner visas)
- [ ] Samma vara två gånger till inköp ger ingen dubblett
- [ ] Ta bort vara med bekräftelse

## Inköp
- [ ] Snabbfältet lägger till med retur; fältet töms och behåller fokus
- [ ] Bocka av → varan flyttar till "Klart"; bocka ur → tillbaka till aktiva
- [ ] Redigera namn/mängd/kategori
- [ ] Svep-radera enskild vara
- [ ] "Rensa" tar bort alla avbockade efter bekräftelse

## Inställningar
- [ ] Ändra stugans namn; syns i Stugan-flikens kort
- [ ] Ändra max sängplatser; kapacitetsvarningen reagerar direkt
- [ ] Version visas

## Uthållighet
- [ ] Döda appen och starta om → all data finns kvar (lokal JSON-lagring)

## iCloud (kräver enheter med iCloud-konto, se docs/CLOUDKIT_SETUP.md)
- [ ] Utan iCloud-konto: Inställningar visar iCloud-behövs-texten; appen fungerar lokalt
- [ ] Med iCloud: status "iCloud är anslutet …"
- [ ] Två enheter, samma konto: ändring på A dyker upp på B
- [ ] "Dela med familjen" ger en länk; annan användare kan gå med och se/ändra data
- [ ] Flygplansläge: ändringar görs lokalt och synkas när nätet är tillbaka

## Tillgänglighet
- [ ] Största Dynamic Type-storleken: inga avklippta texter i flikarna
- [ ] VoiceOver: rader läser namn + status; knappar har begripliga etiketter
- [ ] Mörkt läge ser rimligt ut i alla flikar
