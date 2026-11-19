# AzerothCore Playerbots — Living World Fork

A ready-to-run World of Warcraft 3.3.5a server based on [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) and [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots), rebuilt around one idea: **the world should feel alive everywhere, not just next to you**.

A single real player logs in and shares the world with **more than 10,000 bots** — while the server stays light enough to run on a regular home PC.

---

## 📥 Download

The latest prebuilt Windows server (exe files, tools, configs — no compiling needed):

**[Download the latest release](https://github.com/Firues/azerothcore-wotlk/releases/latest)**

Every code change is built automatically by GitHub Actions. Older builds live on the
[Actions runs page](https://github.com/Firues/azerothcore-wotlk/actions) (free GitHub account needed to download those).

---

## 🌍 What this fork adds

### 10,000+ bots with a "Level of Detail" population
The heart of the fork is a brand-new **LOD (Level of Detail) population system** in
mod-playerbots (`BotLODMgr`):

- Every bot that is far away from players is stored as a **compact 128-byte record** — name,
  race, class, level, zone, position. Thousands of these take only about a megabyte of RAM.
- Up to **300 bots at a time are fully materialized** — real, walkable characters with AI,
  gear, mounts and quests — concentrated **around real players**.
- When a player moves to another zone, far bots are quietly "put back on the shelf"
  and new ones appear around the new location. To you it looks like a seamless living world;
  under the hood it is a constant, cheap swap.

### The Who window shows the whole realm
A normal private server shows only a handful of online players in the Who window.
Here the **Who list is extended with the entire bot population** — thousands of entries
with correct name, level, race, class and zone. Searching "Степи" or "Dun Morogh"
returns dozens of bots, exactly like a crowded retail realm would.

### Invite any bot from the Who window — even one on another continent
Click *Invite* on a bot you found through the Who window, and the bot will:

1. **materialize on the spot** (it becomes a real character),
2. **log in by itself**,
3. and **join your group automatically** a few seconds later.

No more "player not found" errors — this works for bots in far-away zones that
were never loaded. If the bot is still logging in, the invitation patiently waits
and is delivered as soon as it is ready.

### Bots match your level and the zone
- With `Playerbots.SyncLevelWithPlayers` enabled, bots around you roll levels in a
  **band around the real players' level** (a few below, a few above) — no more level-1
  crowds around a level-60 character.
- Bots are created in **their race's starting zones** and live in zones that make sense
  for their level, so Elwynn Forest feels like a level 5–10 area and Northrend like 70+.

### No pop-in: bots appear where you can't see them yet
New bots never materialize right in front of your character. They spawn
**beyond the client's render distance** (100+ yards, configurable via
`Playerbots.LOD.MinSpawnDistance`), so the world fills up naturally instead of
"popping" characters into view.

### A cross-faction living world
Alliance players travelling through Horde lands meet **Horde bots** there, and vice versa.
Combined with `GameType = 1` (world PvP), Horde and Alliance territories genuinely feel
owned by their factions.

### Vanilla-era riding rules for bots
The bots respect the same progression rules as players under the
[Individual Progression](https://github.com/ZhengPeiRu21/mod-individual-progression) module:
**mounts at level 40, epic mounts at 60, no flying in the old world**. The bot AI and the
bot gear factory both follow the shared `IndividualProgression.Enable` setting.

### Gentle on hardware
- **Grid unloading** releases map memory for zones nobody is visiting
  (with a runtime crash in the original approach fixed in this fork).
- A **headless fast-path** skips expensive per-bot work for far-away population.
- A special bot visibility distance (`Visibility.Distance.Bots`) reduces client traffic.
- The design target is a **full 10,000-bot world in ~4 GB of RAM** on one home machine.

---

## 🧩 Included modules

The build ships with a curated set of 24 modules (chosen after comparing with the
popular precompiled "repack" distribution, keeping only well-maintained ones):

| Module | What it gives |
| --- | --- |
| mod-individual-progression | Vanilla-era progression gating (the heart of the experience) |
| mod-solo-lfg | Solo/underpopulated dungeon finder queues |
| mod-dungeon-clear | Bot parties run dungeons down to the final boss (+ client addon) |
| mod-aoe-loot | Loot every nearby corpse with one click |
| mod-quest-loot-party | Quest items drop for every party member |
| mod-junk-to-gold | Grey vendor-trash auto-sold |
| mod-flightmaster-whistle | Teleport to the nearest flight master |
| mod-reagent-bank | Separate bank NPC for spell reagents |
| mod_weather_vibe | Dynamic zone-profile weather |
| mod-npc-beastmaster / npc_buffer / npc_enchanter | Pet, buff and enchant NPCs |
| mod-transmog, mod-1v1-arena, mod-cfbg, mod-duel-reset, mod-boss-announcer, mod-ahbot, mod_aoe_loot, AutoBalance, instance-reset, mod-learn-spells, mod-phased-duels, npc_spectator, npc_enchanter, QueueListCache, SoloLfg… | quality-of-life and balancing extras |

…and, of course, **mod-playerbots** itself with all the living-world changes of this fork.

---

## 🚀 Quick start

1. Download and unpack the [latest release](https://github.com/Firues/azerothcore-wotlk/releases/latest).
2. You need the WoW 3.3.5a game client and extracted `maps` / `DBC` / `vmaps` in the `data`
   folder (a bilingual `HOW-TO-START.txt` inside the archive walks you through this).
3. Point your database settings in `configs/worldserver.conf` / `configs/authserver.conf`.
4. Set the client realmlist to `127.0.0.1`, run `authserver.exe` and `worldserver.exe`,
   create an account (`account create <name> <password>` in the worldserver console).
5. Log in and open the Who window — the world is already full.

On the very first start the bot population is generated automatically
(11,620 bots across 1,162 bot accounts, with names, guilds and starting zones by race).

### Useful configuration knobs (playerbots.conf)

| Option | Meaning |
| --- | --- |
| `LOD.Enabled` | turn the living-world population on/off |
| `LOD.Population` | how many bots exist in total (records) |
| `LOD.MaxActiveBots` | how many are fully simulated at once |
| `LOD.BotsNearPlayerTarget` | desired crowd size around each real player |
| `LOD.MinSpawnDistance` | minimum spawn distance from players (yards) |
| `LOD.DematerializeDelay` | how long an abandoned bot stays fully simulated |
| `Playerbots.SyncLevelWithPlayers` | keep bot levels near real player levels |

---

## 🛠 How it is built

- Both repos (this core and
  [Firues/mod-playerbots](https://github.com/Firues/mod-playerbots)) carry a `my-server`
  branch with all fork changes on top of upstream.
- A GitHub Actions workflow (`windows_build.yml`) compiles the full Windows server on every
  push — the artifact always contains the current state of both repos.
- All changes are plain AzerothCore/module code: no binary patches, no client edits.

## 🙏 Credits

- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) — the core.
- [mod-playerbots](https://github.com/mod-playerbots/mod-playerbots) — the bot framework.
- [ZhengPeiRu21's Individual Progression repack](https://github.com/ZhengPeiRu21/mod-individual-progression) —
  the reference for the module set and the riding rules.
- Every module author listed above.

---

*This fork is a personal, non-commercial playground. World of Warcraft is a trademark of
Blizzard Entertainment; this project has no affiliation with it.*
