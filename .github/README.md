# AzerothCore Playerbots — Living World Fork

Prebuilt World of Warcraft **3.3.5a** server (AzerothCore + mod-playerbots) for one home PC.

---

## 🎯 The goal of this fork

**Two hard requirements, everything else serves them:**

| # | Requirement | Status |
|---|---|---|
| 1 | **10,000+ bots living in the world** — a crowded realm, not a ghost town | ✅ 11,620 bots |
| 2 | **Server never exceeds 4 GB of RAM** — runs on an ordinary home PC | ✅ ~3.6 GB measured |

A normal playerbots server with 10,000 fully simulated bots would need a dedicated server
machine and still choke. This fork reaches both numbers with a **LOD population system**
(described below): bots far away exist as tiny data records, bots near you are real.

Everything listed further down is implemented in this fork — none of it exists in upstream.

---

## 📥 Download

- **Latest build:** [github.com/Firues/azerothcore-wotlk/releases/latest](https://github.com/Firues/azerothcore-wotlk/releases/latest)
  — zip with `worldserver.exe`, `authserver.exe`, runtime DLLs, map tools, all module configs
  and a bilingual `HOW-TO-START.txt`. No compiling needed.
- Every push is compiled automatically (GitHub Actions); per-commit builds live on the
  [Actions page](https://github.com/Firues/azerothcore-wotlk/actions).

---

## 🧠 How 10,000 bots fit in 4 GB: the LOD population

The bots are kept in two states:

| State | Where | Amount | Cost |
|---|---|---|---|
| **Recorded (cold)** | RAM as 128-byte records: name, race, class, level, zone, position | ~11,320 | ~1.4 MB total |
| **Materialized (hot)** | Real characters walking the world with full AI | ≤ 300 | the only heavy part |

What you experience while playing:

1. You log in. Within seconds, **40 bots** (`LOD.BotsNearPlayerTarget`) materialize around you.
2. They are level-appropriate, faction-appropriate and spawn **100+ yards away** — outside the
   ~70-yard client render distance, so nobody "pops" into existence in front of your eyes.
3. You travel to another zone. After **60 seconds** (`LOD.DematerializeDelay`) the bots you left
   are turned back into records, and the new zone fills up the same way.
4. The map chunks (terrain, mobs, vmaps) of empty zones are released too
   (`GridUnload = 1`) — the world behind you stops costing memory.

**The trick:** to the client, a recorded bot is invisible — but everything *player-facing*
still works on cold records (see the Who list and invites below).

---

## ✨ Features implemented in this fork

### 1. Who window shows the whole realm
Upstream shows only physically-online players (≤ 300). Here the Who list is **extended with
all cold records** — names, levels, races, classes, zones and guilds of the entire population.
Typical search result: **"Найдено игроков: 5,083 (показано: 50)"** — exactly how a crowded
retail realm felt.

### 2. Invite any bot from the Who window — even one on another continent
Found a level-55 death knight in Dun Morogh while standing in the Barrens? Click *Invite*:

1. The server materializes that exact bot (it becomes a real character in its zone).
2. It logs in by itself — takes a few seconds; delivery retries for up to 60 s if needed.
3. You receive the invite, and the bot is in your party.

No more "Игрок не найден" — upstream simply said "player not found" for anyone offline.
(Finding and fixing this required instrumenting the group-invite dispatch: three other
modules' script hooks were shadowing ours; then a malformed packet crashed the server —
both fixed and verified in-game.)

### 3. Bot levels follow the players, not the dice
Upstream rolls bot levels randomly from level 1 — so a level-60 player was surrounded by
level-1 crowds. Here:

- Materialized bots roll levels in the band **[player level − 10 … player level + 3]**.
- Never-materialized records get a **stable per-bot level** in the same band — the Who list,
  the invite system and the actual spawn always agree on one level per bot.
- Bots spawn in their **race's starting zones** (zone recorded at creation — no more
  "unknown zone" in the Who window).

### 4. A world owned by both factions
Horde lands are populated by Horde bots, Alliance lands by Alliance bots. An Alliance
character travelling through the Barrens meets Horde crowds there. With
`GameType = 1` (world PvP, set in `worldserver.conf`) territories genuinely belong
to their factions.

### 5. Vanilla-era riding rules for bots
Under the Individual Progression module the whole server plays classic-era progression —
and the bots obey the same rules: **ground mounts at 40, epic mounts at 60, no flying
in old-world zones**. The bot AI (mount logic) and the bot gear factory both read the
shared `IndividualProgression.Enable` flag.

### 6. Memory hygiene
- `GridUnload = 1` + `GridCleanUpDelay = 60000`: empty zones release terrain/vmap/mmap
  memory. (Upstream's grid-unload path crashed the server on never-loaded grids —
  fixed in this fork: `6a56ab889`.)
- `Visibility.Distance.Bots = 120`: far bots stop sending data to clients earlier.
- A **headless fast-path** in the bot manager skips per-bot AI work for the recorded
  population entirely.
- Bot records are updated in memory and only periodically flushed to the database.

### 7. Population you can regenerate in one restart
Flip `Playerbots.DeleteRandomBotAccounts = 1`, run the world, flip it back — the server wipes
all bot accounts (your characters untouched) and rebuilds a fresh 11,620-bot population with
new names, starting zones and guilds. Verified twice in this project.

### 8. Crash-hardening that upstream needed
Along the way this fork fixed its own share of upstream-level bugs: a script-hook dispatcher
that silently dropped our hooks, a group-invite packet that overran its buffer and killed the
worldserver, unbraced-loop compile errors, MySQL client-version mismatches in CI, and
race-constant name differences in this fork. All found via in-game testing, crash dumps and
instrumented CI builds — and all fixed.

---

## 🧩 The 24 included modules

Chosen by comparing the reference "repack" distribution and keeping only working,
maintained ones (plus the two that make the whole thing run: `mod-playerbots` itself
and the module loader):

| Module | What it gives |
|---|---|
| mod-individual-progression | Classic-era progression gating (the backbone of the experience) |
| mod-playerbots *(this fork's version)* | The bots themselves + all living-world features above |
| mod-solo-lfg | Dungeon finder works solo |
| mod-dungeon-clear | Bot parties clear dungeons end-to-end (+ client addon) |
| mod-aoe-loot | Loot every nearby corpse at once |
| mod-quest-loot-party | Quest drops go to every party member |
| mod-junk-to-gold | Grey items auto-sold |
| mod-flightmaster-whistle | One-click teleport to the nearest flight master |
| mod-reagent-bank | Reagent bank NPC |
| mod-npc-beastmaster | Pet skill NPC |
| mod-npc-buffer | Buff NPC |
| mod-npc-enchanter | Enchant NPC |
| mod-npc-spectator | Spectate other players |
| mod-1v1-arena | Solo queue arena |
| mod-cfbg | Cross-faction battlegrounds |
| mod-duel-reset | Duels reset HP/mana |
| mod-phased-duels | Duels in a private phase |
| mod-boss-announcer | Raid boss kill announcements |
| mod-ahbot | Auction house economy filler |
| mod-autobalance | Mob scaling for small parties |
| mod-instance-reset | One-command instance reset |
| mod-learn-spells | NPCs that teach spells |
| mod-queue-list-cache | Battleground queue listing |
| mod-transmog | Transmogrification |
| mod_weather_vibe | Zone-specific dynamic weather |

---

## ⚙️ The knobs that matter

| Setting (playerbots.conf unless noted) | Default here | What it changes |
|---|---|---|
| `LOD.Enabled` | 1 | master switch of the whole living world |
| `LOD.Population` | 10000 | how many bots exist as records |
| `LOD.MaxActiveBots` | 300 | how many are real characters at once — **first RAM knob** |
| `LOD.BotsNearPlayerTarget` | 40 | desired crowd around each player |
| `LOD.MinSpawnDistance` | 100 | yards — must stay above the client render distance (70) |
| `LOD.DematerializeDelay` | 60 | seconds a deserted bot stays simulated |
| `Playerbots.SyncLevelWithPlayers` | 1 | keeps bot levels near real player levels |
| `Playerbots.DeleteRandomBotAccounts` | 0 | 1 = wipe + regenerate the whole population on next start |
| `GameType` *(worldserver.conf)* | 1 | world PvP on |
| `GridUnload` / `GridCleanUpDelay` *(worldserver.conf)* | 1 / 60000 | memory release for empty zones |

**If RAM creeps above 4 GB**, lower in this order: `LOD.MaxActiveBots` →
`LOD.BotsNearPlayerTarget` → `Visibility.Distance.Bots` → `DynamicReactDelay`.
Each step trades a bit of crowd density for a chunk of memory.

---

## 🚀 Quick start

1. Unpack the [latest release](https://github.com/Firues/azerothcore-wotlk/releases/latest).
2. Put extracted `maps` / `DBC` / `vmaps` into `data/` (the archive's `HOW-TO-START.txt`
   walks through it; tools are included).
3. Check DB lines in `configs/worldserver.conf` / `configs/authserver.conf`.
4. Client realmlist → `set realmlist 127.0.0.1`.
5. Run `authserver.exe` and `worldserver.exe`; in the worldserver console type
   `account create <name> <password>`.
6. Log in and open the Who window — the realm is already full.

First start with a fresh database: the population is generated automatically
(11,620 characters, ~40–60 minutes); later boots are **~2 minutes**.

**RAM you can expect while playing:** worldserver ≈ 3.5–3.6 GB, MySQL ≈ 1.1 GB
(1 GB InnoDB pool), authserver ≈ 16 MB.

---

## 🛠 Source & CI

- Code lives on the **`my-server`** branch of this repo and of
  [Firues/mod-playerbots](https://github.com/Firues/mod-playerbots).
- `.github/workflows/windows_build.yml` compiles a full Windows server on every push and
  publishes an artifact; releases above are snapshots of that pipeline.

## 🙏 Credits

- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) — the core.
- [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots) — the bot framework.
- [ZhengPeiRu21's Individual Progression repack](https://github.com/ZhengPeiRu21/mod-individual-progression) —
  the reference for the module set and progression rules.
- All module authors in the table above.

---

*Personal, non-commercial project. World of Warcraft is a trademark of Blizzard
Entertainment; no affiliation.*
