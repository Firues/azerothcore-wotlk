# AzerothCore Playerbots — Living World Fork

A ready-to-run World of Warcraft **3.3.5a** server (AzerothCore + mod-playerbots) where the
realm is genuinely crowded: **11,620 bots** live in the world, and it all fits in **~4 GB of RAM**
on an ordinary home PC.

Everything described below is implemented in this fork. Stock AzerothCore with stock
mod-playerbots cannot do this — there, a bot population beyond a few hundred fully simulated
characters needs a dedicated server machine, and most of the world stays empty.

---

## 📥 Download

**[Living World Server Build v1.0 (latest release)](https://github.com/Firues/azerothcore-wotlk/releases/latest)**
— one zip, no compiling needed. Inside:

- `worldserver.exe` and `authserver.exe` with all runtime DLLs (OpenSSL, MySQL)
- the DB importer and the map/DBC/vmap extraction tools
- config templates for every included module
- a bilingual `HOW-TO-START.txt` (English / Russian)

Every push to this repository is also compiled automatically by GitHub Actions; per-commit
binaries are on the [Actions page](https://github.com/Firues/azerothcore-wotlk/actions).

### 🕹️ Optional: the Azeroth Hub launcher

[**Azeroth Hub**](https://github.com/Firues/azeroth-hub) — a desktop control panel for this
server. One window instead of three consoles, and it stops the stack in the order that keeps
your characters safe (world → login → database). Rollback points with one-button restores,
health checks, a characters browser, seven UI languages.
**[Download the launcher](https://github.com/Firues/azeroth-hub/releases/latest)** — drop
`wow-hub.exe` next to `worldserver.exe` and run it.

---

## 🌍 What is different here

| | Stock playerbots server | This fork |
|---|---|---|
| Bot population | a few hundred before RAM explodes | **11,620** |
| RAM for the world server | grows with every bot | **~3.6 GB regardless of population** |
| Who window | shows only the bots near you | shows the **whole realm** (5,000+ results per search) |
| Inviting an "offline" bot | impossible | works — the bot materializes and joins you, even from another continent |
| Bot levels | random, mostly level 1 | match the players around them |
| Factions | bots ignore territory | Horde lives in Horde lands, Alliance in Alliance lands |
| World feel | ghost town | crowds in every low-level zone, like a busy retail realm |

The short version: **this fork keeps the whole population in memory as tiny records and turns
only the nearby ones into real characters** — with a set of systems making that invisible to
the player. Details below.

---

## 🧠 How 11,620 bots fit in 4 GB

Every bot exists in one of two states:

| State | What it is | Amount | Cost |
|---|---|---|---|
| **Recorded** | a compact record in RAM: name, race, class, level, guild, zone, position | ~11,300 | ~1.4 MB **total** |
| **Live** | a real character with a session, AI, map presence | ≤ 300 | the only expensive part |

What this feels like while playing:

1. **You log in.** Within seconds a crowd of ~40 bots
   (`Playerbots.LOD.BotsNearPlayerTarget`) comes alive around you.
2. **Nobody pops into existence in front of your eyes.** Bots are materialized at least
   100 yards away (`Playerbots.LOD.MinSpawnDistance`) — farther than the client renders
   distant creatures, so they walk into view naturally, exactly like any mob or object.
3. **You travel.** Bots left behind stay simulated for a grace period
   (`Playerbots.LOD.DematerializeDelay = 60` s), then quietly turn back into records;
   the new zone fills up the same way. Transitions are spread over ticks, so there is
   no login storm.
4. **Empty zones cost nothing.** The terrain, collision and pathfinding data of zones
   nobody is in get released (`GridUnload = 1`) — the world behind you stops costing memory.

The clever part is that the recorded population is *not* dead weight: the Who window and
the invite system work on the full population, cold or hot (see below).

---

## ✨ Features

### 1. A realm that is actually crowded
11,620 characters spread over the world, with more of them steered toward where players
actually are (`Playerbots.LOD.ConcentrateInPlayerZone`). A level-10 character in Dun Morogh
sees level-appropriate crowds around them — not an empty map with three strangers at the
capital. This is the single biggest difference from stock playerbots.

### 2. The Who window shows the whole realm
Stock behavior: the Who list contains only physically online players, i.e. at most the
300 active bots. Here the list is **extended with the entire recorded population** — names,
levels, races, classes, zones and guilds of all 11,620 characters. Searching for
"level 40–49 warrior" returns hundreds of hits, like on a busy retail realm.

### 3. Invite any bot you find — even one on another continent
You are in the Barrens, the Who window shows a level-55 death knight in Dun Morogh,
you click *Invite*, and it works:

1. the server materializes that exact bot where it lives;
2. the bot logs in by itself (delivery retries for up to a minute if the world is busy);
3. you get the invite popup, and the bot joins your party.

In stock playerbots every character outside the active set simply does not exist
for invites — "player not found". Here the whole realm is one friend list.

### 4. Bot levels follow the players, not the dice
Stock playerbots rolls random levels from 1 upward, so a level-60 player stood in a sea of
level-1 bots. In this fork:

- bots materialized around you roll levels in the band **[your level − 10 … your level + 3]**;
- every character in the recorded population has a **stable level in the same band** — the
  Who window, the invite system and the actual spawn always agree on one level per bot;
- bots live in their **race's starting zones**, and the zone shown in the Who window is
  always the real one.

### 5. A world owned by both factions
Horde lands are populated by Horde bots, Alliance lands by Alliance bots, and the crowd
steering respects faction territory — an Alliance character traveling through the Barrens
meets Horde crowds there. With `GameType = 1` (world PvP) in `worldserver.conf` the
territories genuinely belong to their factions.

### 6. Bots play by the same classic rules you do
The server ships with the Individual Progression module, which gates the whole game to
classic-era pacing — and the bots obey the same rules: **ground mounts at level 40, epic
mounts at 60, no flying mounts in the old world**. The bot AI and the bot gear factory both
read the shared progression setting, so no bot zooms past you on a flying mount it
shouldn't have yet.

### 7. The world keeps moving even far away from you
Recorded bots are not frozen placeholders: every half a minute each one picks a new
position around its zone and drifts there (`Playerbots.LOD.ColdTickInterval`,
`ColdWanderRadius`) — the population slowly reshuffles on its own instead of standing
parked at spawn points forever. And the crowd around you stays alive: bots you kill
resurrect after a short delay (`Playerbots.LOD.ReviveDelay = 60` s) so the neighborhood
does not turn into a graveyard.

### 8. Runs on a home PC: memory discipline
Beyond the LOD system itself, the fork does the unglamorous work that keeps RAM flat:

- empty zones release their terrain, collision and pathfinding data
  (`GridUnload` / `GridCleanUpDelay`);
- far-away bots stop sending client updates earlier
  (`Visibility.Distance.Bots = 120` in `worldserver.conf`);
- recorded bots are kept in memory and only periodically written to the database —
  no per-bot database chatter;
- the bot manager skips all client-only update work for the recorded population.

**Measured while playing:** worldserver ≈ 3.5–3.6 GB, MySQL ≈ 1.1 GB, authserver ≈ 16 MB.

### 9. A fresh population in one restart
Flip `Playerbots.DeleteRandomBotAccounts = 1`, start the server, flip it back. The server
wipes every bot account (your characters are untouched) and rebuilds a brand-new population
with new names, levels, zones and guilds. First generation takes ~40–60 minutes; every
boot after that is ~2 minutes.

### 10. Twenty-four modules preinstalled
Selected by comparing the reference "repack" distributions and keeping only working,
maintained ones:

| Module | What it gives |
|---|---|
| mod-individual-progression | Classic-era progression gating — the backbone of the experience |
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

## ⚙️ Settings worth knowing

All in `configs/playerbots.conf` unless noted:

| Setting | Default here | What it changes |
|---|---|---|
| `Playerbots.LOD.Enabled` | 1 | master switch of the whole living world |
| `Playerbots.LOD.Population` | 10000 | how many bots exist as records |
| `Playerbots.LOD.MaxActiveBots` | 300 | how many are real characters at once — **the first RAM knob** |
| `Playerbots.LOD.BotsNearPlayerTarget` | 40 | desired crowd size around each player |
| `Playerbots.LOD.ActiveRadius` / `DeactivateRadius` | 250 / 400 | materialize when a player is within 250 yd; keep until they are 400 yd away |
| `Playerbots.LOD.MinSpawnDistance` | 100 | yards — keep above the client render distance so bots appear off-screen |
| `Playerbots.LOD.DematerializeDelay` | 60 | seconds a deserted bot stays simulated |
| `Playerbots.LOD.ReviveDelay` | 60 | seconds after death before a bot resurrects |
| `Playerbots.LOD.ConcentrateInPlayerZone` | 1 | steer spare population toward zones where players are |
| `Playerbots.SyncLevelWithPlayers` | 1 | keep bot levels near real player levels |
| `Playerbots.DeleteRandomBotAccounts` | 0 | 1 = wipe + regenerate the whole population on next start |
| `GameType` *(worldserver.conf)* | 1 | world PvP on |
| `GridUnload` / `GridCleanUpDelay` *(worldserver.conf)* | 1 / 60000 | release memory for empty zones |
| `Visibility.Distance.Bots` *(worldserver.conf)* | 120 | where far bots stop updating clients |

**If RAM creeps above 4 GB**, lower in this order: `Playerbots.LOD.MaxActiveBots` →
`Playerbots.LOD.BotsNearPlayerTarget` → `Visibility.Distance.Bots`. Each step trades a bit
of crowd density for a chunk of memory.

---

## 🚀 Quick start

1. Unpack the [latest release](https://github.com/Firues/azerothcore-wotlk/releases/latest).
2. Extract `maps` / `DBC` / `vmaps` from your 3.3.5a client into `data/` — the archive's
   `HOW-TO-START.txt` walks through it, the tools are included.
3. Check the database lines in `configs/worldserver.conf` / `configs/authserver.conf`.
4. Client realmlist: `set realmlist 127.0.0.1`.
5. Run `authserver.exe` and `worldserver.exe`; in the worldserver console type
   `account create <name> <password>`.
6. Log in and open the Who window — the realm is already full.

Use a fresh database on first start: the population generates itself automatically.
**RAM while playing:** worldserver ≈ 3.5–3.6 GB, MySQL ≈ 1.1 GB, authserver ≈ 16 MB.

---

## 🛠 Source & CI

- Code lives on the **`my-server`** branch of this repo and of
  [Firues/mod-playerbots](https://github.com/Firues/mod-playerbots).
- `.github/workflows/windows_build.yml` compiles a full Windows server on every push and
  publishes the binaries; releases are snapshots of that pipeline.

## 🙏 Credits

- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) — the core.
- [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots) — the bot framework.
- [ZhengPeiRu21's Individual Progression repack](https://github.com/ZhengPeiRu21/mod-individual-progression) —
  the reference for the module set and progression rules.
- All module authors in the table above.

---

*Personal, non-commercial project. World of Warcraft is a trademark of Blizzard
Entertainment; no affiliation.*
