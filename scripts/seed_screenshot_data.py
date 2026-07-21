#!/usr/bin/env python3
"""Skriver realistisk demodata till simulatorns store.json inför App Store-skärmbilder.

Använd:
    python3 scripts/seed_screenshot_data.py <sökväg till store.json>

Datumen är relativa till dagens datum så bilderna aldrig ser inaktuella ut.
Dates use Foundation's default Codable encoding: seconds since 2001-01-01 UTC.
"""

import json
import sys
import uuid
from datetime import datetime, timedelta, timezone

REFERENCE_DATE = datetime(2001, 1, 1, tzinfo=timezone.utc)


def ts(day_offset: int) -> float:
    """Klockslag 15:00 lokal tid, day_offset dagar från idag, som Foundation-tidsstämpel."""
    moment = datetime.now(timezone.utc).replace(
        hour=13, minute=0, second=0, microsecond=0
    ) + timedelta(days=day_offset)
    return (moment - REFERENCE_DATE).total_seconds()


def uid() -> str:
    return str(uuid.uuid4()).upper()


def stay(name, arrival, departure, people, bed_spaces=None, note=None):
    item = {
        "id": uid(),
        "familyName": name,
        "arrivalDate": ts(arrival),
        "departureDate": ts(departure),
        "peopleCount": people,
        "createdAt": ts(-30),
        "updatedAt": ts(-2),
    }
    if bed_spaces is not None:
        item["bedSpacesNeeded"] = bed_spaces
    if note:
        item["note"] = note
    return item


def inventory(name, category, status, quantity=None):
    item = {
        "id": uid(),
        "name": name,
        "category": category,
        "status": status,
        "lastUpdatedAt": ts(-3),
        "createdAt": ts(-60),
    }
    if quantity:
        item["quantityNote"] = quantity
    return item


def shopping(name, quantity=None, category=None, completed=False):
    item = {
        "id": uid(),
        "name": name,
        "isCompleted": completed,
        "createdAt": ts(-5),
        "updatedAt": ts(-1),
    }
    if quantity:
        item["quantityNote"] = quantity
    if category:
        item["category"] = category
    return item


store = {
    "settings": {
        "id": uid(),
        "cottageName": "Sommarstugan",
        "maxBedSpaces": 10,
        "updatedAt": ts(-14),
    },
    # Vecka 2 är medvetet överbokad (12 av 10 sängplatser) för att visa varningen.
    "stays": [
        stay("Familjen Wulff", 1, 6, 4, note="Tar med kajakerna"),
        stay("Mormor & Morfar", 3, 10, 2),
        stay("Familjen Berg", 8, 13, 5, note="Kommer sent på fredagen"),
        stay("Familjen Lind", 9, 12, 4),
        stay("Anna & Erik", 10, 15, 3),
        stay("Familjen Wulff", 20, 27, 4),
    ],
    "inventory": [
        inventory("Mjölk", "fridge", "low", "1 paket kvar"),
        inventory("Smör", "fridge", "available", "2 paket"),
        inventory("Ägg", "fridge", "out"),
        inventory("Köttbullar", "freezer", "available", "2 påsar"),
        inventory("Glass", "freezer", "low"),
        inventory("Pasta", "pantry", "available", "4 paket"),
        inventory("Krossade tomater", "pantry", "available", "6 burkar"),
        inventory("Oregano", "pantry", "low"),
        inventory("Kaffe", "pantry", "out"),
        inventory("Havregryn", "pantry", "available"),
        inventory("Diskmedel", "household", "available", "2 flaskor"),
        inventory("Toapapper", "household", "low", "3 rullar"),
        inventory("Tändstickor", "household", "available"),
        inventory("Myggmedel", "other", "out"),
    ],
    "shoppingList": [
        shopping("Kaffe", "2 paket", "pantry"),
        shopping("Ägg", "2 kartonger", "fridge"),
        shopping("Myggmedel", category="other"),
        shopping("Toapapper", "storpack", "household"),
        shopping("Mjölk", "3 liter", "fridge", completed=True),
        shopping("Grillkol", category="other", completed=True),
    ],
}

if len(sys.argv) != 2:
    sys.exit("Användning: seed_screenshot_data.py <sökväg till store.json>")

with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump(store, handle, ensure_ascii=False)

print(f"Skrev demodata till {sys.argv[1]}")
