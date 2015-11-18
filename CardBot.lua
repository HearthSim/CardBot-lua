#!/usr/bin/lua

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
			newCard.CardTextInHand = newCard.CardTextInHand:gsub("\n", " ")
		else
			newCard.CardTextInHand = ""
		end
		-- Process flavor text
		if newCard.FlavorText then
			newCard.FlavorText = newCard.FlavorText:gsub("</?b>", "")
			newCard.FlavorText = newCard.FlavorText:gsub("</?i>", "")
			newCard.FlavorText = newCard.FlavorText:gsub("%$(%d+)", "%1")
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
table.sort(cards, function(a, b)
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
end)

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

local function TryCardCommand(command, outputTarget)
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
				OutputText("No card found for \""..args.."\".", outputTarget)
			end
		else
			OutputText("Some error occured: "..(cards or ""), outputTarget)
		end
		return true
	end

	return false
end

local function TryBuffCommand(command, outputTarget)
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
	print("Joining channel #hearthsim...")
	irc.join("#hearthsim")
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

	if chan.name:lower() == "#hearthsim" then
		local foundCommand = TryCardCommand(msg, chan.name)
		if not foundCommand then
			foundCommand = TryBuffCommand(msg, chan.name)
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
		print(text)
	end
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Connect to IRC
irc.connect({
	network = "irc.freenode.net",
	nick = "CardBot",
	username = "CardBot",
	realname = "CardBot",
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
]]
--[[
TryBuffCommand("!buff humility")
TryBuffCommand("!buff buff")
TryBuffCommand("!buff2 buff")
TryBuffCommand("!buff GVG_104a")
]]
