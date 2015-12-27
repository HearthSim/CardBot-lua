#!/usr/bin/lua

local CARDBOT_IRC_CHANNEL = os.getenv("CARDBOT_IRC_CHANNEL") or "#hearthsim"
CARDBOT_IRC_CHANNEL = CARDBOT_IRC_CHANNEL:lower()
local CARDBOT_IRC_NICK = os.getenv("CARDBOT_IRC_NICK") or "CardBot"
local CARDBOT_IRC_SERVER = os.getenv("CARDBOT_IRC_SERVER") or "irc.freenode.net"

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Data
local CardClass =
{
	[0] = "Neutral",
	[1] = "Death Knight",
	[2] = "Druid",
	[3] = "Hunter",
	[4] = "Mage",
	[5] = "Paladin",
	[6] = "Priest",
	[7] = "Rogue",
	[8] = "Shaman",
	[9] = "Warlock",
	[10] = "Warrior",
	[11] = "Dream",
}
local CardSet =
{
	[0] = "Invalid",
	[1] = "Test",
	[2] = "Basic",
	[3] = "Classic",
	[4] = "Reward",
	[5] = "Tutorial",
	[6] = "Demo",
	[7] = "None",
	[8] = "Cheat",
	[9] = "Blank",
	[10] = "Debug",
	[11] = "Promo",
	[12] = "Naxx",
	[13] = "GvG",
	[14] = "BRM",
	[15] = "TGT",
	[16] = "Credits",
	[17] = "Hero Skins",
	[18] = "Tavern Brawl",
	[20] = "LOE",
}
local CardType =
{
	[0] = "Invalid",
	[1] = "Game",
	[2] = "Player",
	[3] = "Hero",
	[4] = "Minion",
	[5] = "Spell",
	[6] = "Enchantment",
	[7] = "Weapon",
	[8] = "Item",
	[9] = "Token",
	[10] = "Hero Power",
}
local CardTypeSortPriority =
{
	[0] = 6, --"Invalid",
	[1] = 7, --"Game",
	[2] = 8, --"Player",
	[3] = 3, --"Hero",
	[4] = 0, --"Minion",
	[5] = 1, --"Spell",
	[6] = 5, --"Enchantment",
	[7] = 2, --"Weapon",
	[8] = 9, --"Item",
	[9] = 10, --"Token",
	[10] = 4, --"Hero Power",
}
local CardRarity =
{
	--[0] = "Invalid",
	--[1] = "Common",
	--[2] = "Free",
	[3] = "12", -- Rare
	[4] = "06", -- Epic
	[5] = "07", -- Legendary
	--[6] = "UNKNOWN_6",
}
local CardRace =
{
	[0] = "Invalid",
	[1] = "Blood Elf",
	[2] = "Draenei",
	[3] = "Dwarf",
	[4] = "Gnome",
	[5] = "Goblin",
	[6] = "Human",
	[7] = "Night Elf",
	[8] = "Orc",
	[9] = "Tauren",
	[10] = "Troll",
	[11] = "Undead",
	[12] = "Worgen",
	[13] = "Goblin2",
	[14] = "Murloc",
	[15] = "Demon",
	[16] = "Scourge",
	[17] = "Mech",
	[18] = "Elemental",
	[19] = "Ogre",
	[20] = "Beast", -- "Pet"
	[21] = "Totem",
	[22] = "Nerubian",
	[23] = "Pirate",
	[24] = "Dragon",
}
local GameTag = {
	IGNORE_DAMAGE = 1,
	TAG_SCRIPT_DATA_NUM_1 = 2,
	TAG_SCRIPT_DATA_NUM_2 = 3,
	TAG_SCRIPT_DATA_ENT_1 = 4,
	TAG_SCRIPT_DATA_ENT_2 = 5,
	MISSION_EVENT = 6,
	TIMEOUT = 7,
	TURN_START = 8,
	TURN_TIMER_SLUSH = 9,
	PREMIUM = 12,
	GOLD_REWARD_STATE = 13,
	PLAYSTATE = 17,
	LAST_AFFECTED_BY = 18,
	STEP = 19,
	TURN = 20,
	FATIGUE = 22,
	CURRENT_PLAYER = 23,
	FIRST_PLAYER = 24,
	RESOURCES_USED = 25,
	RESOURCES = 26,
	HERO_ENTITY = 27,
	MAXHANDSIZE = 28,
	STARTHANDSIZE = 29,
	PLAYER_ID = 30,
	TEAM_ID = 31,
	TRIGGER_VISUAL = 32,
	RECENTLY_ARRIVED = 33,
	PROTECTED = 34,
	PROTECTING = 35,
	DEFENDING = 36,
	PROPOSED_DEFENDER = 37,
	ATTACKING = 38,
	PROPOSED_ATTACKER = 39,
	ATTACHED = 40,
	EXHAUSTED = 43,
	DAMAGE = 44,
	HEALTH = 45,
	ATK = 47,
	COST = 48,
	ZONE = 49,
	CONTROLLER = 50,
	OWNER = 51,
	DEFINITION = 52,
	ENTITY_ID = 53,
	HISTORY_PROXY = 54,
	COPY_DEATHRATTLE = 55,
	COPY_DEATHRATTLE_INDEX = 56,
	ELITE = 114,
	MAXRESOURCES = 176,
	CARD_SET = 183,
	CARD_ID = 186,
	DURABILITY = 187,
	SILENCED = 188,
	WINDFURY = 189,
	TAUNT = 190,
	STEALTH = 191,
	SPELLPOWER = 192,
	DIVINE_SHIELD = 194,
	CHARGE = 197,
	NEXT_STEP = 198,
	CLASS = 199,
	CARDRACE = 200,
	FACTION = 201,
	CARDTYPE = 202,
	RARITY = 203,
	STATE = 204,
	SUMMONED = 205,
	FREEZE = 208,
	ENRAGED = 212,
	OVERLOAD = 215,
	LOYALTY = 216,
	DEATHRATTLE = 217,
	BATTLECRY = 218,
	SECRET = 219,
	COMBO = 220,
	CANT_HEAL = 221,
	CANT_DAMAGE = 222,
	CANT_SET_ASIDE = 223,
	CANT_REMOVE_FROM_GAME = 224,
	CANT_READY = 225,
	CANT_EXHAUST = 226,
	CANT_ATTACK = 227,
	CANT_TARGET = 228,
	CANT_DESTROY = 229,
	CANT_DISCARD = 230,
	CANT_PLAY = 231,
	CANT_DRAW = 232,
	INCOMING_HEALING_MULTIPLIER = 233,
	INCOMING_HEALING_ADJUSTMENT = 234,
	INCOMING_HEALING_CAP = 235,
	INCOMING_DAMAGE_MULTIPLIER = 236,
	INCOMING_DAMAGE_ADJUSTMENT = 237,
	INCOMING_DAMAGE_CAP = 238,
	CANT_BE_HEALED = 239,
	CANT_BE_DAMAGED = 240,
	CANT_BE_SET_ASIDE = 241,
	CANT_BE_REMOVED_FROM_GAME = 242,
	CANT_BE_READIED = 243,
	CANT_BE_EXHAUSTED = 244,
	CANT_BE_ATTACKED = 245,
	CANT_BE_TARGETED = 246,
	CANT_BE_DESTROYED = 247,
	CANT_BE_SUMMONING_SICK = 253,
	FROZEN = 260,
	JUST_PLAYED = 261,
	LINKEDCARD = 262,
	ZONE_POSITION = 263,
	CANT_BE_FROZEN = 264,
	COMBO_ACTIVE = 266,
	CARD_TARGET = 267,
	NUM_CARDS_PLAYED_THIS_TURN = 269,
	CANT_BE_TARGETED_BY_OPPONENTS = 270,
	NUM_TURNS_IN_PLAY = 271,
	NUM_TURNS_LEFT = 272,
	OUTGOING_DAMAGE_CAP = 273,
	OUTGOING_DAMAGE_ADJUSTMENT = 274,
	OUTGOING_DAMAGE_MULTIPLIER = 275,
	OUTGOING_HEALING_CAP = 276,
	OUTGOING_HEALING_ADJUSTMENT = 277,
	OUTGOING_HEALING_MULTIPLIER = 278,
	INCOMING_ABILITY_DAMAGE_ADJUSTMENT = 279,
	INCOMING_COMBAT_DAMAGE_ADJUSTMENT = 280,
	OUTGOING_ABILITY_DAMAGE_ADJUSTMENT = 281,
	OUTGOING_COMBAT_DAMAGE_ADJUSTMENT = 282,
	OUTGOING_ABILITY_DAMAGE_MULTIPLIER = 283,
	OUTGOING_ABILITY_DAMAGE_CAP = 284,
	INCOMING_ABILITY_DAMAGE_MULTIPLIER = 285,
	INCOMING_ABILITY_DAMAGE_CAP = 286,
	OUTGOING_COMBAT_DAMAGE_MULTIPLIER = 287,
	OUTGOING_COMBAT_DAMAGE_CAP = 288,
	INCOMING_COMBAT_DAMAGE_MULTIPLIER = 289,
	INCOMING_COMBAT_DAMAGE_CAP = 290,
	CURRENT_SPELLPOWER = 291,
	ARMOR = 292,
	MORPH = 293,
	IS_MORPHED = 294,
	TEMP_RESOURCES = 295,
	OVERLOAD_OWED = 296,
	NUM_ATTACKS_THIS_TURN = 297,
	NEXT_ALLY_BUFF = 302,
	MAGNET = 303,
	FIRST_CARD_PLAYED_THIS_TURN = 304,
	MULLIGAN_STATE = 305,
	TAUNT_READY = 306,
	STEALTH_READY = 307,
	CHARGE_READY = 308,
	CANT_BE_TARGETED_BY_ABILITIES = 311,
	SHOULDEXITCOMBAT = 312,
	CREATOR = 313,
	CANT_BE_DISPELLED = 314,
	PARENT_CARD = 316,
	NUM_MINIONS_PLAYED_THIS_TURN = 317,
	PREDAMAGE = 318,
	ENCHANTMENT_BIRTH_VISUAL = 330,
	ENCHANTMENT_IDLE_VISUAL = 331,
	CANT_BE_TARGETED_BY_HERO_POWERS = 332,
	HEALTH_MINIMUM = 337,
	TAG_ONE_TURN_EFFECT = 338,
	SILENCE = 339,
	COUNTER = 340,
	HAND_REVEALED = 348,
	ADJACENT_BUFF = 350,
	FORCED_PLAY = 352,
	LOW_HEALTH_THRESHOLD = 353,
	IGNORE_DAMAGE_OFF = 354,
	SPELLPOWER_DOUBLE = 356,
	HEALING_DOUBLE = 357,
	NUM_OPTIONS_PLAYED_THIS_TURN = 358,
	NUM_OPTIONS = 359,
	TO_BE_DESTROYED = 360,
	AURA = 362,
	POISONOUS = 363,
	HERO_POWER_DOUBLE = 366,
	AI_MUST_PLAY = 367,
	NUM_MINIONS_PLAYER_KILLED_THIS_TURN = 368,
	NUM_MINIONS_KILLED_THIS_TURN = 369,
	AFFECTED_BY_SPELL_POWER = 370,
	EXTRA_DEATHRATTLES = 371,
	START_WITH_1_HEALTH = 372,
	IMMUNE_WHILE_ATTACKING = 373,
	MULTIPLY_HERO_DAMAGE = 374,
	MULTIPLY_BUFF_VALUE = 375,
	CUSTOM_KEYWORD_EFFECT = 376,
	TOPDECK = 377,
	CANT_BE_TARGETED_BY_BATTLECRIES = 379,
	SHOWN_HERO_POWER = 380,
	DEATHRATTLE_RETURN_ZONE = 382,
	STEADY_SHOT_CAN_TARGET = 383,
	DISPLAYED_CREATOR = 385,
	POWERED_UP = 386,
	SPARE_PART = 388,
	FORGETFUL = 389,
	CAN_SUMMON_MAXPLUSONE_MINION = 390,
	OBFUSCATED = 391,
	BURNING = 392,
	OVERLOAD_LOCKED = 393,
	NUM_TIMES_HERO_POWER_USED_THIS_GAME = 394,
	CURRENT_HEROPOWER_DAMAGE_BONUS = 395,
	HEROPOWER_DAMAGE = 396,
	LAST_CARD_PLAYED = 397,
	NUM_FRIENDLY_MINIONS_THAT_DIED_THIS_TURN = 398,
	NUM_CARDS_DRAWN_THIS_TURN = 399,
	AI_ONE_SHOT_KILL = 400,
	EVIL_GLOW = 401,
	HIDE_COST = 402,
	INSPIRE = 403,
	RECEIVES_DOUBLE_SPELLDAMAGE_BONUS = 404,
	HEROPOWER_ADDITIONAL_ACTIVATIONS = 405,
	HEROPOWER_ACTIVATIONS_THIS_TURN = 406,
	REVEALED = 410,
	NUM_FRIENDLY_MINIONS_THAT_DIED_THIS_GAME = 412,
	CANNOT_ATTACK_HEROES = 413,
	LOCK_AND_LOAD = 414,
	TREASURE = 415,
	SHADOWFORM = 416,
	NUM_FRIENDLY_MINIONS_THAT_ATTACKED_THIS_TURN = 417,
	NUM_RESOURCES_SPENT_THIS_GAME = 418,
	CHOOSE_BOTH = 419,
	ELECTRIC_CHARGE_LEVEL = 420,
	HEAVILY_ARMORED = 421,
	DONT_SHOW_IMMUNE = 422,
	HISTORY_PROXY_NO_BIG_CARD = 427,

	-- Only in card definitions
	Collectible = 321,
	InvisibleDeathrattle = 335,
	OneTurnEffect = 338,
	ImmuneToSpellpower = 349,
	AttackVisualType = 251,
	DevState = 268,
	GrantCharge = 355,
	HealTarget = 361,

	-- strings
	CARDTEXT_INHAND = 184,
	CARDNAME = 185,
	CardTextInPlay = 252,
	TARGETING_ARROW_TEXT = 325,
	ARTISTNAME = 342,
	LocalizationNotes = 344,
	FLAVORTEXT = 351,
	HOW_TO_EARN = 364,
	HOW_TO_EARN_GOLDEN = 365,

	-- Missing, only present in logs
	WEAPON = 334,
}
-- Add reverse lookup
local GameTagReverse = {}
for k, v in pairs(GameTag) do
	GameTagReverse[v] = k
end
-- Add Renamed Tags
GameTag.DEATH_RATTLE = GameTag.DEATHRATTLE
GameTag.DEATHRATTLE_SENDS_BACK_TO_DECK = GameTag.DEATHRATTLE_RETURN_ZONE
GameTag.RECALL = GameTag.OVERLOAD
GameTag.RECALL_OWED = GameTag.OVERLOAD_OWED
GameTag.TAG_HERO_POWER_DOUBLE = GameTag.HERO_POWER_DOUBLE
GameTag.TAG_AI_MUST_PLAY = GameTag.AI_MUST_PLAY
GameTag.OVERKILL = 380
-- Add Deleted Tags
GameTag.DIVINE_SHIELD_READY = 314
local PlayReqTag = {
	REQ_MINION_TARGET = 1,
	REQ_FRIENDLY_TARGET = 2,
	REQ_ENEMY_TARGET = 3,
	REQ_DAMAGED_TARGET = 4,
	REQ_ENCHANTED_TARGET = 5,
	REQ_FROZEN_TARGET = 6,
	REQ_CHARGE_TARGET = 7,
	REQ_TARGET_MAX_ATTACK = 8,
	REQ_NONSELF_TARGET = 9,
	REQ_TARGET_WITH_RACE = 10,
	REQ_TARGET_TO_PLAY = 11,
	REQ_NUM_MINION_SLOTS = 12,
	REQ_WEAPON_EQUIPPED = 13,
	REQ_ENOUGH_MANA = 14,
	REQ_YOUR_TURN = 15,
	REQ_NONSTEALTH_ENEMY_TARGET = 16,
	REQ_HERO_TARGET = 17,
	REQ_SECRET_CAP = 18,
	REQ_MINION_CAP_IF_TARGET_AVAILABLE = 19,
	REQ_MINION_CAP = 20,
	REQ_TARGET_ATTACKED_THIS_TURN = 21,
	REQ_TARGET_IF_AVAILABLE = 22,
	REQ_MINIMUM_ENEMY_MINIONS = 23,
	REQ_TARGET_FOR_COMBO = 24,
	REQ_NOT_EXHAUSTED_ACTIVATE = 25,
	REQ_UNIQUE_SECRET = 26,
	REQ_TARGET_TAUNTER = 27,
	REQ_CAN_BE_ATTACKED = 28,
	REQ_ACTION_PWR_IS_MASTER_PWR = 29,
	REQ_TARGET_MAGNET = 30,
	REQ_ATTACK_GREATER_THAN_0 = 31,
	REQ_ATTACKER_NOT_FROZEN = 32,
	REQ_HERO_OR_MINION_TARGET = 33,
	REQ_CAN_BE_TARGETED_BY_SPELLS = 34,
	REQ_SUBCARD_IS_PLAYABLE = 35,
	REQ_TARGET_FOR_NO_COMBO = 36,
	REQ_NOT_MINION_JUST_PLAYED = 37,
	REQ_NOT_EXHAUSTED_HERO_POWER = 38,
	REQ_CAN_BE_TARGETED_BY_OPPONENTS = 39,
	REQ_ATTACKER_CAN_ATTACK = 40,
	REQ_TARGET_MIN_ATTACK = 41,
	REQ_CAN_BE_TARGETED_BY_HERO_POWERS = 42,
	REQ_ENEMY_TARGET_NOT_IMMUNE = 43,
	REQ_ENTIRE_ENTOURAGE_NOT_IN_PLAY = 44,
	REQ_MINIMUM_TOTAL_MINIONS = 45,
	REQ_MUST_TARGET_TAUNTER = 46,
	REQ_UNDAMAGED_TARGET = 47,
	REQ_CAN_BE_TARGETED_BY_BATTLECRIES = 48,
	REQ_STEADY_SHOT = 49,
	REQ_MINION_OR_ENEMY_HERO = 50,
	REQ_TARGET_IF_AVAILABLE_AND_DRAGON_IN_HAND = 51,
	REQ_LEGENDARY_TARGET = 52,
	REQ_FRIENDLY_MINION_DIED_THIS_TURN = 53,
	REQ_FRIENDLY_MINION_DIED_THIS_GAME = 54,
	REQ_ENEMY_WEAPON_EQUIPPED = 55,
	REQ_TARGET_IF_AVAILABLE_AND_MINIMUM_FRIENDLY_MINIONS = 56,
	REQ_TARGET_WITH_BATTLECRY = 57,
	REQ_TARGET_WITH_DEATHRATTLE = 58,
	REQ_DRAG_TO_PLAY = 59,
}
-- Add reverse lookup
local PlayReqTagReverse = {}
for k, v in pairs(PlayReqTag) do
	PlayReqTagReverse[v] = k
end

local Locale = {
	[0] = "enUS",
	[1] = "enGB",
	[2] = "frFR",
	[3] = "deDE",
	[4] = "koKR",
	[5] = "esES",
	[6] = "esMX",
	[7] = "ruRU",
	[8] = "zhTW",
	[9] = "zhCN",
	[10] = "itIT",
	[11] = "ptBR",
	[12] = "plPL",
	[13] = "ptPT",
	[14] = "jaJP",
}

local dataMT =
{
	__index = function(t, key) return t[0] end,
}
setmetatable(CardClass, dataMT)
setmetatable(CardSet, dataMT)
setmetatable(CardType, dataMT)
--setmetatable(CardRarity, dataMT) -- Not on this table
setmetatable(CardRace, dataMT)


package.path = package.path..";SLAXML/?.lua"
local SLAXML = require("SLAXML.slaxdom")

local lang = "enUS"
local cards = {}
local cardsDict = {}
local buffs = {}
local buffsDict = {}

-- Localize globals
local tonumber = tonumber

-- Read XML document
local myxml = io.open("hs-data/CardDefs.xml"):read('*all')
local doc = SLAXML:dom(myxml)

local tagIDsToRead1 =
{
	["185"] = true, -- CardName
	["184"] = true, -- CardTextInHand
	["351"] = true, -- FlavorText
}
local tagIDsToRead2 =
{
	["183"] = true, -- CardSet
	["202"] = true, -- CardType
	["321"] = true, -- Collectible
	["203"] = true, -- Rarity
	["48"] = true, -- Cost
	["199"] = true, -- Class
	["47"] = true, -- Atk
	["45"] = true, -- Health
	["187"] = true, -- Durability
	["200"] = true, -- Race
}

-- Parse XML document
for _, tEntity in pairs(doc.root.kids) do
	if tEntity.type == "element" then
		--print("==== " .. tEntity.attr.CardID .. " ====")
		local newCard = { CardID = tEntity.attr.CardID }

		for __, tElement in pairs(tEntity.kids) do
			--print(__, tElement)
			if tElement.type == "element" and tElement.name == "Tag" then
				local enumID = tElement.attr.enumID
				local tagName = tElement.attr.name

				if tagIDsToRead1[enumID] then
					for k, v in pairs(tElement.kids) do
						if v.type == "element" and v.name == lang then
							--print(tagName .. ": " .. v.kids[1].value)
							newCard[tagName] = v.kids[1].value
							break
						end
					end
				elseif tagIDsToRead2[enumID] then
					--print(tagName .. ": " .. tonumber(tElement.attr.value))
					newCard[tagName] = tonumber(tElement.attr.value)
				end
			end
		end

		-- Process text
		if newCard.CardTextInHand then
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("</?b>", "")
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("</?i>", "")
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("%$(%d+)", "%1")
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("#(%d+)", "%1")
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("\n", " ")
		else
			newCard.CardTextInHand = ""
		end
		-- Process flavor text
		if newCard.FlavorText then
			newCard.FlavorText = newCard.FlavorText:gsub("</?b>", "")
			newCard.FlavorText = newCard.FlavorText:gsub("</?i>", "")
			newCard.FlavorText = newCard.FlavorText:gsub("%$(%d+)", "%1")
			newCard.FlavorText = newCard.FlavorText:gsub("#(%d+)", "%1")
			newCard.FlavorText = newCard.FlavorText:gsub("\n", " ")
		end
		-- Store lowercase name
		local lowerCardName = newCard.CardName:lower()
		newCard.CardNameLower = lowerCardName
		-- Parse Collectible
		newCard.Collectible = newCard.Collectible == 1
		-- Parse Cost
		if not newCard.Cost then newCard.Cost = 0 end

		-- Separate Enchantment cards from the others
		if newCard.CardType == 6 then
			-- Store in buffs[]
			buffs[#buffs + 1] = newCard
			-- Store in buffsDict[]
			if buffsDict[lowerCardName] then
				local size = #buffsDict[lowerCardName]
				buffsDict[lowerCardName][size + 1] = newCard
			else
				buffsDict[lowerCardName] = { newCard }
			end
			-- Allow cardID exact lookup too
			buffsDict[newCard.CardID:lower()] = { newCard }
		else
			-- Store in cards[]
			cards[#cards + 1] = newCard
			-- Store in cardsDict[]
			if cardsDict[lowerCardName] then
				local size = #cardsDict[lowerCardName]
				cardsDict[lowerCardName][size + 1] = newCard
			else
				cardsDict[lowerCardName] = { newCard }
			end
			-- Allow cardID exact lookup too
			cardsDict[newCard.CardID:lower()] = { newCard }
		end
	end
end

-- Sort the cards so that results are returned in this order
local sortFunc = function(a, b)
	 -- Sort by Collectible
	if a.Collectible == b.Collectible then
		-- Then by Rarity
		local aRarity = a.Rarity and a.Rarity or 0
		local bRarity = b.Rarity and b.Rarity or 0
		if a.Rarity == b.Rarity then
			-- Then by Card Type
			local aTypePriority = CardTypeSortPriority[a.CardType]
			local bTypePriority = CardTypeSortPriority[b.CardType]
			if aTypePriority == bTypePriority then
				return false
			else
				return aTypePriority < bTypePriority
			end
		else
			return aRarity > bRarity
		end
	else
		return a.Collectible
	end
end
-- Sort data tables
table.sort(cards, sortFunc)
table.sort(buffs, sortFunc)
for cardName, cardTable in pairs(cardsDict) do
	table.sort(cardTable, sortFunc)
end
for buffName, buffTable in pairs(buffsDict) do
	table.sort(buffTable, sortFunc)
end


local function trim(s)
	return s:match("^%s*(.*%S)") or ""
end

local function GetCardText(c)
	-- Card Name string
	local cardName = c.CardName
	if CardRarity[c.Rarity] then cardName = CardRarity[c.Rarity] .. cardName .. "" end
	-- Card Race string
	local cardRace = ""
	if c.Race then cardRace = " ("..CardRace[c.Race]..")" end
	-- FlavorText
	local flavorText = c.FlavorText and " " .. c.FlavorText .. "" or ""

	-- Format output string
	if c.CardType == 3 then -- Hero
		return ("%s [%s][%s][%s %s][%d HP]%s%s"):format(cardName, c.CardID, CardSet[c.CardSet], CardClass[c.Class], CardType[c.CardType], c.Health, cardRace, flavorText)
	elseif c.CardType == 4 then -- Minion
		return ("%s [%s][%s][%s %s][%d mana, %d/%d]: %s%s%s"):format(cardName, c.CardID, CardSet[c.CardSet], CardClass[c.Class], CardType[c.CardType], c.Cost, c.Atk, c.Health, c.CardTextInHand, cardRace, flavorText)
	elseif c.CardType == 5 or c.CardType == 10 then -- Spell or Hero Power
		return ("%s [%s][%s][%s %s][%d mana]: %s%s%s"):format(cardName, c.CardID, CardSet[c.CardSet], CardClass[c.Class], CardType[c.CardType], c.Cost, c.CardTextInHand, cardRace, flavorText)
	elseif c.CardType == 6 then -- Enchantment
		return ("%s [%s][%s][%s %s]: %s%s%s"):format(cardName, c.CardID, CardSet[c.CardSet], CardClass[c.Class], CardType[c.CardType], c.CardTextInHand, cardRace, flavorText)
	elseif c.CardType == 7 then -- Weapon
		return ("%s [%s][%s][%s %s][%d mana, %d/%d]: %s%s%s"):format(cardName, c.CardID, CardSet[c.CardSet], CardClass[c.Class], CardType[c.CardType], c.Cost, c.Atk, c.Durability, c.CardTextInHand, cardRace, flavorText)
	end

	return ("%s [%s] Unrecognized CardType: %s"):format(cardName, c.CardID, CardType[c.CardType])
end

local function FindCard(text, cards, cardsDict)
	-- Try exact match first
	if cardsDict[lowerargs] then
		return cardsDict[lowerargs]
	end

	-- Try substring search next
	local result = {}
	for i = 1, #cards do
		if cards[i].CardNameLower:find(text) then
			result[#result + 1] = cards[i]
		end
	end
	if #result > 0 then
		return result
	end

	-- Words must be in order
	local searchString = text:gsub("%s+", ".*")
	for i = 1, #cards do
		if cards[i].CardNameLower:find(searchString) then
			result[#result + 1] = cards[i]
		end
	end
	if #result > 0 then
		return result
	end

	-- Get table of input words
	local wordsSet = {}
	local uniqueWords = {}
	for word in text:gmatch("%S+") do
		if not wordsSet[word] then
			uniqueWords[#uniqueWords + 1] = word
			wordsSet[word] = true
		end
	end

	-- Words can be in any order, but must contain all of them
	for i = 1, #cards do
		local found = true
		for j = 1, #uniqueWords do
			if not cards[i].CardNameLower:find(uniqueWords[j]) then
				found = false
				break
			end
		end
		if found then
			result[#result + 1] = cards[i]
		end
	end
	if #result > 0 then
		return result
	end

	-- No result
	return nil
end

local OutputText -- Defined later, function uses "irc" local defined later
local TryCardCommand, TryBuffCommand, TryTagCommand

TryCardCommand = function(command, outputTarget)
	local start, _, index, args = command:find("!card(%d*) (.*)")
	if index and args and start == 1 then
		local showCount = false
		if index == "" then
			index = 1
		else
			index = tonumber(index)
			showCount = true
		end
		args = trim(args)
		lowerargs = args:lower()

		local retOK, cards = pcall(FindCard, lowerargs, cards, cardsDict)
		if retOK then
			if cards then
				if index > #cards then index = #cards end
				if index < 1 then index = 1 end
				if #cards > 1 then showCount = true end

				local countText = "("..index.."/"..#cards..") "
				local retOK2, cardText = pcall(GetCardText, cards[index])
				if retOK2 then
					if showCount then
						OutputText(countText..cardText, outputTarget)
					else
						OutputText(cardText, outputTarget)
					end
				else
					OutputText("Some error occured: "..(cardText or ""), outputTarget)
				end
			else
				--OutputText("No card found for \""..args.."\".", outputTarget)
				return TryBuffCommand("!buff"..index.." "..args, outputTarget)
			end
		else
			OutputText("Some error occured: "..(cards or ""), outputTarget)
		end
		return true
	end

	return false
end

TryBuffCommand = function(command, outputTarget)
	local start, _, index, args = command:find("!buff(%d*) (.*)")
	if index and args and start == 1 then
		local showCount = false
		if index == "" then
			index = 1
		else
			index = tonumber(index)
			showCount = true
		end
		args = trim(args)
		lowerargs = args:lower()

		local retOK, cards = pcall(FindCard, lowerargs, buffs, buffsDict)
		if retOK then
			if cards then
				if index > #cards then index = #cards end
				if index < 1 then index = 1 end
				if #cards > 1 then showCount = true end

				local countText = "("..index.."/"..#cards..") "
				local retOK2, cardText = pcall(GetCardText, cards[index])
				if retOK2 then
					if showCount then
						OutputText(countText..cardText, outputTarget)
					else
						OutputText(cardText, outputTarget)
					end
				else
					OutputText("Some error occured: "..(cardText or ""), outputTarget)
				end
			else
				OutputText("No buff found for \""..args.."\".", outputTarget)
			end
		else
			OutputText("Some error occured: "..(cards or ""), outputTarget)
		end
		return true
	end

	return false
end

TryTagCommand = function(command, outputTarget)
	local start, _, tag = command:find("!tag%s+(%S+)")
	if tag and start == 1 then
		-- Is tag a number?
		local isnumber = tonumber(tag)
		if isnumber and GameTagReverse[isnumber] then
			OutputText("Tag: "..GameTagReverse[isnumber].." = "..tag, outputTarget)
			return true
		end

		-- Is tag found?
		local lowerTag = tag:lower()
		local result = {}
		for k, v in pairs(GameTag) do
			if k:lower():find(lowerTag) then
				result[#result + 1] = k
			end
		end

		if #result > 0 then
			local output = "Tag: "..result[1].." = "..GameTag[result[1]]
			if #result > 1 then
				for i = 2, #result do
					output = output..", "..result[i].." = "..GameTag[result[i]]
				end
			end
			OutputText(output, outputTarget)
		else
			OutputText("No Tag found for \""..tag.."\".", outputTarget)
		end

		return true
	end

	return false
end

local function TryPlayReqCommand(command, outputTarget)
	local start, _, req = command:find("!playreq%s+(%S+)")
	if req and start == 1 then
		-- Is req a number?
		local isnumber = tonumber(req)
		if isnumber and PlayReqTagReverse[isnumber] then
			OutputText("PlayReq: "..PlayReqTagReverse[isnumber].." = "..req, outputTarget)
			return true
		end

		-- Is req found?
		local lowerReq = req:lower()
		local result = {}
		for k, v in pairs(PlayReqTag) do
			if k:lower():find(lowerReq) then
				result[#result + 1] = k
			end
		end

		if #result > 0 then
			local output = "PlayReq: "..result[1].." = "..PlayReqTag[result[1]]
			if #result > 1 then
				for i = 2, #result do
					output = output..", "..result[i].." = "..PlayReqTag[result[i]]
				end
			end
			OutputText(output, outputTarget)
		else
			OutputText("No PlayReq found for \""..req.."\".", outputTarget)
		end

		return true
	end

	return false
end


-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

local irc = require("irc")
local dcc = require("irc.dcc")

irc.DEBUG = true

--[[
local ip_prog = io.popen("get_ip")
local ip = ip_prog:read()
ip_prog:close()
irc.set_ip(ip)
]]

local function print_state()
	for chan in irc.channels() do
		print(chan..": Channel ops: "..table.concat(chan:ops(), " "))
		print(chan..": Channel voices: "..table.concat(chan:voices(), " "))
		print(chan..": Channel normal users: "..table.concat(chan:users(), " "))
		print(chan..": All channel members: "..table.concat(chan:members(), " "))
	end
end

local function on_connect()
	print("Joining channel "..CARDBOT_IRC_CHANNEL.."...")
	irc.join(CARDBOT_IRC_CHANNEL)
end
irc.register_callback("connect", on_connect)

local function on_me_join(chan)
	print("Join to " .. chan .. " complete.")
	print(chan .. ": Channel type: " .. chan.chanmode)
	if chan.topic.text and chan.topic.text ~= "" then
		print(chan .. ": Channel topic: " .. chan.topic.text)
		print("  Set by " .. chan.topic.user ..
			  " at " .. os.date("%c", chan.topic.time))
	end
	--irc.act(chan.name, "is here")
	print_state()
end
irc.register_callback("me_join", on_me_join)

--[[
local function on_join(chan, user)
	print("I saw a join to " .. chan)
	if tostring(user) ~= "doylua" then
		irc.say(tostring(chan), "Hi, " .. user)
	end
	print_state()
end
irc.register_callback("join", on_join)

local function on_part(chan, user, part_msg)
	print("I saw a part from " .. chan .. " saying " .. part_msg)
	print_state()
end
irc.register_callback("part", on_part)

local function on_nick_change(new_nick, old_nick)
	print("I saw a nick change: "  ..  old_nick .. " -> " .. new_nick)
	print_state()
end
irc.register_callback("nick_change", on_nick_change)

local function on_kick(chan, user)
	print("I saw a kick in " .. chan)
	print_state()
end
irc.register_callback("kick", on_kick)

local function on_quit(chan, user)
	print("I saw a quit from " .. chan)
	print_state()
end
irc.register_callback("quit", on_quit)

local function whois_cb(cb_data)
	print("WHOIS data for " .. cb_data.nick)
	if cb_data.user then print("Username: " .. cb_data.user) end
	if cb_data.host then print("Host: " .. cb_data.host) end
	if cb_data.realname then print("Realname: " .. cb_data.realname) end
	if cb_data.server then print("Server: " .. cb_data.server) end
	if cb_data.serverinfo then print("Serverinfo: " .. cb_data.serverinfo) end
	if cb_data.away_msg then print("Awaymsg: " .. cb_data.away_msg) end
	if cb_data.is_oper then print(nick .. "is an IRCop") end
	if cb_data.idle_time then print("Idletime: " .. cb_data.idle_time) end
	if cb_data.channels then
		print("Channel list for " .. cb_data.nick .. ":")
		for _, channel in ipairs(cb_data.channels) do print(channel) end
	end
end

local function serverversion_cb(cb_data)
	print("VERSION data for " .. cb_data.server)
	print("Version: " .. cb_data.version)
	print("Comments: " .. cb_data.comments)
end

local function ping_cb(cb_data)
	print("CTCP PING for " .. cb_data.nick)
	print("Roundtrip time: " .. cb_data.time .. "s")
end

local function time_cb(cb_data)
	print("CTCP TIME for " .. cb_data.nick)
	print("Localtime: " .. cb_data.time)
end

local function version_cb(cb_data)
	print("CTCP VERSION for " .. cb_data.nick)
	print("Version: " .. cb_data.version)
end

local function stime_cb(cb_data)
	print("TIME for " .. cb_data.server)
	print("Server time: " .. cb_data.time)
end
]]


local function on_channel_msg(chan, from, msg)
	--[[
	if from == "Xinhuan" then
		if msg == "leave" then
			irc.part(chan.name)
			return
		elseif msg:sub(1, 3) == "op " then
			chan:op(msg:sub(4))
			return
		elseif msg:sub(1, 5) == "deop " then
			chan:deop(msg:sub(6))
			return
		elseif msg:sub(1, 6) == "voice " then
			chan:voice(msg:sub(7))
			return
		elseif msg:sub(1, 8) == "devoice " then
			chan:devoice(msg:sub(9))
			return
		elseif msg:sub(1, 5) == "kick " then
			chan:kick(msg:sub(6))
			return
		elseif msg:sub(1, 5) == "send " then
			dcc.send(from, msg:sub(6))
			return
		elseif msg:sub(1, 6) == "whois " then
			irc.whois(whois_cb, msg:sub(7))
			return
		elseif msg:sub(1, 8) == "sversion" then
			irc.server_version(serverversion_cb)
			return
		elseif msg:sub(1, 5) == "ping " then
			irc.ctcp_ping(ping_cb, msg:sub(6))
			return
		elseif msg:sub(1, 5) == "time " then
			irc.ctcp_time(time_cb, msg:sub(6))
			return
		elseif msg:sub(1, 8) == "version " then
			irc.ctcp_version(version_cb, msg:sub(9))
			return
		elseif msg:sub(1, 5) == "stime" then
			irc.server_time(stime_cb)
			return
		elseif msg:sub(1, 6) == "trace " then
			irc.trace(trace_cb, msg:sub(7))
			return
		elseif msg:sub(1, 5) == "trace" then
			irc.trace(trace_cb)
			return
		end
	end
	if from ~= "doylua" then
		irc.say(chan.name, from .. ": " .. msg)
	end
	]]

	if chan.name:lower() == CARDBOT_IRC_CHANNEL then
		local foundCommand = TryCardCommand(msg, chan.name)
		if not foundCommand then
			foundCommand = TryBuffCommand(msg, chan.name)
		end
		if not foundCommand then
			foundCommand = TryTagCommand(msg, chan.name)
		end
		if not foundCommand then
			foundCommand = TryPlayReqCommand(msg, chan.name)
		end
	end
end
irc.register_callback("channel_msg", on_channel_msg)

local function on_private_msg(from, msg)
	--[[
	if from == "Xinhuan" then
		if msg == "leave" then
			irc.quit("gone")
			return
		elseif msg:sub(1, 5) == "send " then
			dcc.send(from, msg:sub(6))
			return
		end
	end
	if from ~= "doylua" then
		irc.say(from, msg)
	end
	]]

	local foundCommand = TryCardCommand(msg, from)
	if not foundCommand then
		foundCommand = TryBuffCommand(msg, from)
	end
	if not foundCommand then
		foundCommand = TryTagCommand(msg, from)
	end
	if not foundCommand then
		foundCommand = TryPlayReqCommand(msg, from)
	end
end
irc.register_callback("private_msg", on_private_msg)

--[[
local function on_channel_act(chan, from, msg)
	irc.act(chan.name, "jumps on " .. from)
end
irc.register_callback("channel_act", on_channel_act)

local function on_private_act(from, msg)
	irc.act(from, "jumps on you")
end
irc.register_callback("private_act", on_private_act)

local function on_op(chan, from, nick)
	print(nick .. " was opped in " .. chan .. " by " .. from)
	print_state()
end
irc.register_callback("op", on_op)

local function on_deop(chan, from, nick)
	print(nick .. " was deopped in " .. chan .. " by " .. from)
	print_state()
end
irc.register_callback("deop", on_deop)

local function on_voice(chan, from, nick)
	print(nick .. " was voiced in " .. chan .. " by " .. from)
	print_state()
end
irc.register_callback("voice", on_voice)

local function on_devoice(chan, from, nick)
	print(nick .. " was devoiced in " .. chan .. " by " .. from)
	print_state()
end
irc.register_callback("devoice", on_devoice)
]]

local function on_dcc_send()
	return true
end
irc.register_callback("dcc_send", on_dcc_send)


OutputText = function(text, outputTarget)
	if outputTarget then
		irc.say(outputTarget, text)
	else
		-- Approximation
		text = text:sub(1, irc.constants.IRC_MAX_MSG - 2 - #"PRIVMSG  :" - #CARDBOT_IRC_CHANNEL)
		print(text)
	end
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Connect to IRC
irc.connect({
	network = CARDBOT_IRC_SERVER,
	nick = CARDBOT_IRC_NICK,
	username = CARDBOT_IRC_NICK,
	realname = CARDBOT_IRC_NICK,
})


--[[
-- For local testing, don't connect to IRC above
--TryCardCommand("!card Anub'Rekhan")
--TryCardCommand("!card2 Anub'Rekhan")
--TryCardCommand("!card Arcane Intellect")
--TryCardCommand("!card Lord Jaraxxus")
--TryCardCommand("!card1 Lord Jaraxxus")
--TryCardCommand("!card2 Lord Jaraxxus")
--TryCardCommand("!card Doomsayer")
--TryCardCommand("!card Azure Drake")
--TryCardCommand("!card Luck of the Coin")
--TryCardCommand("!card Force of Nature")
--TryCardCommand("!card Life Tap")
--TryCardCommand("!card Shield Block")
--TryCardCommand("!card inner rage")
--TryCardCommand("!card chillwind")
TryCardCommand("!card spellbender")
TryCardCommand("!card2 spellbender")
TryTagCommand("!tag DIVINE_SHIELD")
TryTagCommand("!tag   CHarGE forWard")
TryTagCommand("!tag dddd")
TryTagCommand("!tag 194")
TryTagCommand("!tag 197")
TryTagCommand("!tag 197 198")
TryTagCommand("!tag a")
TryPlayReqCommand("!playreq 5")
TryPlayReqCommand("!playreq enemy")
]]
--[[
TryBuffCommand("!buff humility")
TryBuffCommand("!buff buff")
TryBuffCommand("!buff2 buff")
TryBuffCommand("!buff GVG_104a")
]]
