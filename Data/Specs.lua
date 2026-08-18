local _, PPH = ...

-- English PvP-friendly abbreviations are intentionally keyed by specialization ID,
-- so the output is stable even on non-English WoW clients.
PPH.SpecData = {
    -- Death Knight
    [250] = { spec = "Blood",  class = "DK",     classFile = "DEATHKNIGHT" },
    [251] = { spec = "Frost",  class = "DK",     classFile = "DEATHKNIGHT" },
    [252] = { spec = "Unholy", class = "DK",     classFile = "DEATHKNIGHT" },

    -- Demon Hunter
    [577]  = { spec = "Havoc", class = "DH",     classFile = "DEMONHUNTER" },
    [581]  = { spec = "Veng",  class = "DH",     classFile = "DEMONHUNTER" },
    [1480] = { spec = "Dev",   class = "DH",     classFile = "DEMONHUNTER" },

    -- Druid
    [102] = { spec = "Balance", class = "Druid", classFile = "DRUID" },
    [103] = { spec = "Feral",   class = "Druid", classFile = "DRUID" },
    [104] = { spec = "Guard",   class = "Druid", classFile = "DRUID" },
    [105] = { spec = "Resto",   class = "Druid", classFile = "DRUID" },

    -- Evoker
    [1467] = { spec = "Devast", class = "Evoker", classFile = "EVOKER" },
    [1468] = { spec = "Pres",   class = "Evoker", classFile = "EVOKER" },
    [1473] = { spec = "Aug",    class = "Evoker", classFile = "EVOKER" },

    -- Hunter
    [253] = { spec = "BM",   class = "Hunter", classFile = "HUNTER" },
    [254] = { spec = "MM",   class = "Hunter", classFile = "HUNTER" },
    [255] = { spec = "Surv", class = "Hunter", classFile = "HUNTER" },

    -- Mage
    [62] = { spec = "Arcane", class = "Mage", classFile = "MAGE" },
    [63] = { spec = "Fire",   class = "Mage", classFile = "MAGE" },
    [64] = { spec = "Frost",  class = "Mage", classFile = "MAGE" },

    -- Monk
    [268] = { spec = "Brew", class = "Monk", classFile = "MONK" },
    [269] = { spec = "WW",   class = "Monk", classFile = "MONK" },
    [270] = { spec = "MW",   class = "Monk", classFile = "MONK" },

    -- Paladin
    [65] = { spec = "Holy", class = "Pal", classFile = "PALADIN" },
    [66] = { spec = "Prot", class = "Pal", classFile = "PALADIN" },
    [70] = { spec = "Ret",  class = "Pal", classFile = "PALADIN" },

    -- Priest
    [256] = { spec = "Disc",   class = "Priest", classFile = "PRIEST" },
    [257] = { spec = "Holy",   class = "Priest", classFile = "PRIEST" },
    [258] = { spec = "Shadow", class = "Priest", classFile = "PRIEST" },

    -- Rogue
    [259] = { spec = "Assa",   class = "Rogue", classFile = "ROGUE" },
    [260] = { spec = "Outlaw", class = "Rogue", classFile = "ROGUE" },
    [261] = { spec = "Sub",    class = "Rogue", classFile = "ROGUE" },

    -- Shaman
    [262] = { spec = "Ele",   class = "Sham", classFile = "SHAMAN" },
    [263] = { spec = "Enh",   class = "Sham", classFile = "SHAMAN" },
    [264] = { spec = "Resto", class = "Sham", classFile = "SHAMAN" },

    -- Warlock
    [265] = { spec = "Aff",    class = "Lock", classFile = "WARLOCK" },
    [266] = { spec = "Demo",   class = "Lock", classFile = "WARLOCK" },
    [267] = { spec = "Destro", class = "Lock", classFile = "WARLOCK" },

    -- Warrior
    [71] = { spec = "Arms", class = "War", classFile = "WARRIOR" },
    [72] = { spec = "Fury", class = "War", classFile = "WARRIOR" },
    [73] = { spec = "Prot", class = "War", classFile = "WARRIOR" },
}

PPH.ClassAbbreviations = {
    DEATHKNIGHT = "DK",
    DEMONHUNTER = "DH",
    DRUID = "Druid",
    EVOKER = "Evoker",
    HUNTER = "Hunter",
    MAGE = "Mage",
    MONK = "Monk",
    PALADIN = "Pal",
    PRIEST = "Priest",
    ROGUE = "Rogue",
    SHAMAN = "Sham",
    WARLOCK = "Lock",
    WARRIOR = "War",
}
