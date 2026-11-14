#!/bin/bash

# Curated module set for the production build (windows-build workflow).
# Mirrors the enabled set of the reference "AzerothCore WoTLK Repack
# (Playerbots + Individual Progression)" plus two QoL extras (duel-reset,
# learn-spells). The full public-module compile validation stays in
# ci-install-modules.sh; this script only clones what the server ships with.

set -e

echo "install user modules"

# --- Official azerothcore modules already validated by ci-install-modules.sh ---
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-1v1-arena modules/mod-1v1-arena
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-ah-bot modules/mod-ah-bot
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-autobalance modules/mod-autobalance
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-boss-announcer modules/mod-boss-announcer
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-cfbg modules/mod-cfbg
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-duel-reset modules/mod-duel-reset
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-instance-reset modules/mod-instance-reset
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-learn-spells modules/mod-learn-spells
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-npc-beastmaster modules/mod-npc-beastmaster
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-npc-buffer modules/mod-npc-buffer
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-npc-enchanter modules/mod-npc-enchanter
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-phased-duels modules/mod-phased-duels
git clone --depth=1 --branch=master https://github.com/azerothcore/mod-transmog modules/mod-transmog
# not in the official catalog; pinned the same way as ci-install-modules.sh
git clone --depth=1 --branch=master https://github.com/gozzim/mod-npc-spectator modules/mod-npc-spectator
git clone --depth=1 --branch=main   https://github.com/azerothcore/mod-queue-list-cache modules/mod-queue-list-cache

# --- From the reference repack (sources verified against its changelog) ---
# Progression gating per expansion era; the heart of the reference repack.
git clone --depth=1 https://github.com/ZhengPeiRu21/mod-individual-progression modules/mod-individual-progression
# Solo/underpopulated dungeon finder queues.
git clone --depth=1 https://github.com/azerothcore/mod-solo-lfg modules/mod-solo-lfg
# Loot every nearby corpse from one interaction.
git clone --depth=1 https://github.com/azerothcore/mod-aoe-loot modules/mod-aoe-loot
# Fork with a working config file (the upstream config was broken, see repack changelog).
git clone --depth=1 https://github.com/brighton-chi/mod-junk-to-gold modules/mod-junk-to-gold
# Bot AI: the bot tank leads the party through dungeons down to the final boss;
# ships with a client addon (jrad7/mod-dungeon-clear-addon), not needed server-side.
git clone --depth=1 https://github.com/jrad7/mod-dungeon-clear modules/mod-dungeon-clear
# Whistle item/ability: teleport to the nearest flight master of the current area.
git clone --depth=1 https://github.com/silviu20092/mod-flightmaster-whistle modules/mod-flightmaster-whistle
# Quest items drop for every party member instead of one winner.
git clone --depth=1 https://github.com/pangolp/mod-quest-loot-party modules/mod-quest-loot-party
# Reagent bank NPC: separate storage for spell reagents.
git clone --depth=1 https://github.com/ZhengPeiRu21/mod-reagent-bank modules/mod-reagent-bank
# Dynamic zone-profile weather.
git clone --depth=1 https://github.com/hermensbas/mod_weather_vibe modules/mod_weather_vibe
