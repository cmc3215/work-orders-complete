--------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize Variables
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
--
NS.initialized = false;
--
NS.lastTimeShipmentRequest = nil;
NS.lastTimeShipmentRequestSent = nil;
NS.lastTimeUpdateAll = nil;

NS.minimapButtonFlash = nil;
NS.alertFlashing = false;
NS.selectedCharacterKey = nil;
--
NS.allCharacters = {
	buildings = {},
	garrisonCache = {},
	nextOutFullSeconds = { buildings = nil, garrisonCache = nil, },
	allOutFullSeconds = { buildings = nil, garrisonCache = nil, },
};
--
NS.currentCharacter = {
	name = UnitName( "player" ) .. "-" .. GetRealmName(),
	race = UnitRace( "player" ),
	sex = UnitSex( "player" ) == 2 and "male" or "female", -- unknown = 1, male = 2, female = 3 / Players will only be male or female
	faction = UnitFactionGroup( "player" ), -- Updated later with character for Pandaren
	key = nil,
	buildings = {},
	garrisonCache = {},
	nextOutFullSeconds = { buildings = nil, garrisonCache = nil, },
	allOutFullSeconds = { buildings = nil, garrisonCache = nil, },
};
--
NS.currentCharacter.TexCoords = function()
	-- Grid: 8 columns, 4 rows
	local xStep = 1 / 8; -- 0.125
	local yStep = 1 / 4; -- 0.25
	--
	local XY = {
		-- Alliance
		["Alliance:Draenei"] = { male = { 5, 1 }, female = { 5, 3 } },
		["Alliance:Dwarf"] = { male = { 2, 1 }, female = { 2, 3 } },
		["Alliance:Gnome"] = { male = { 3, 1 }, female = { 3, 3 } },
		["Alliance:Human"] = { male = { 1, 1 }, female = { 1, 3 } },
		["Alliance:Night Elf"] = { male = { 4, 1 }, female = { 4, 3 } },
		["Alliance:Worgen"] = { male = { 6, 1 }, female = { 6, 3 } },
		["Alliance:Pandaren"] = { male = { 7, 1 }, female = { 7, 3 } },
		-- Horde
		["Horde:Blood Elf"] = { male = { 5, 2 }, female = { 5, 4 } },
		["Horde:Goblin"] = { male = { 6, 2 }, female = { 6, 4 } },
		["Horde:Orc"] = { male = { 4, 2 }, female = { 4, 4 } },
		["Horde:Tauren"] = { male = { 1, 2 }, female = { 1, 4 } },
		["Horde:Troll"] = { male = { 3, 2 }, female = { 3, 4 } },
		["Horde:Undead"] = { male = { 2, 2 }, female = { 2, 4 } },
		["Horde:Pandaren"] = { male = { 7, 2 }, female = { 7, 4 } },
		-- Neutral
		["Neutral:Pandaren"] = { male = { 7, 1 }, female = { 7, 3 } }, -- Reuses Alliance:Pandaren
	};
	local xPos, yPos = unpack( XY[NS.currentCharacter.faction .. ":" .. NS.currentCharacter.race][NS.currentCharacter.sex] );
	--
	local left = ( xPos - 1 ) * xStep;
	local right = xPos * xStep;
	local top = ( yPos - 1 ) * yStep;
	local bottom = yPos * yStep;
	--
	return left, right, top, bottom;
end
--
NS.buildingInfo = {
	--
	-- Small - 4
	--
	["Gem Boutique"] = { icon = "Interface\\ICONS\\inv_misc_gem_01", type = 4 },
	["Salvage Yard"] = { icon = "Interface\\ICONS\\garrison_building_salvageyard", type = 4 },
	["Storehouse"] = { icon = "Interface\\ICONS\\garrison_building_storehouse", type = 4 },
	["Alchemy Lab"] = { icon = "Interface\\ICONS\\trade_alchemy", type = 4 },
	["Enchanter's Study"] = { icon = "Interface\\ICONS\\trade_engraving", type = 4 },
	["Engineering Works"] = { icon = "Interface\\ICONS\\trade_engineering", type = 4 },
	["Scribe's Quarters"] = { icon = "Interface\\ICONS\\inv_inscription_tradeskill01", type = 4 },
	["Tailoring Emporium"] = { icon = "Interface\\ICONS\\trade_tailoring", type = 4 },
	["The Forge"] = { icon = "Interface\\ICONS\\trade_blacksmithing", type = 4 },
	["The Tannery"] = { icon = "Interface\\ICONS\\inv_misc_armorkit_17", type = 4 },
	--
	-- Medium - 3
	--
	--["Lunarfall Inn"]
	--["Frostwall Tavern"]
	["Trading Post"] = { icon = "Interface\\ICONS\\garrison_building_tradingpost", type =3 },
	["Barn"] = { icon = "Interface\\ICONS\\garrison_building_barn", type = 3 },
	["Gladiator's Sanctum"] = { icon = "Interface\\ICONS\\garrison_building_sparringarena", type = 3 },
	["Lumber Mill"] = { icon = "Interface\\ICONS\\garrison_building_lumbermill", type = 3 },
	--
	-- Large - 2
	--
	--["Barracks"]
	["Dwarven Bunker / War Mill"] =  { icon = "Interface\\ICONS\\garrison_building_armory", type = 2 },
	["Gnomish Gearworks / Goblin Workshop"] = { icon = "Interface\\ICONS\\garrison_building_workshop", type = 2 },
	["Mage Tower / Spirit Lodge"] = { icon = "Interface\\ICONS\\garrison_building_magetower", type = 2 },
	--["Stables"]
	--
	-- Prebuilt - 1
	--
	["Lunarfall Excavation / Frostwall Mines"] = { icon = "Interface\\ICONS\\trade_mining", type = 1 },
	["Herb Garden"] = { icon = "Interface\\ICONS\\inv_misc_herb_sansamroot", type = 1 },
	--["Pet Menagerie"]
	--["Fishing Shack"]
};
--------------------------------------------------------------------------------------------------------------------------------------------
-- SavedVariables(PerCharacter)
--------------------------------------------------------------------------------------------------------------------------------------------
NS.DefaultSavedVariables = function()
	return {
		["version"] = NS.version,
		["characters"] = {},
		["alertType"] = "next",
		["alertSeconds"] = ( 8 * 3600 ), -- 8 hr
		["showCharacterRealms"] = true,
	};
end

--
NS.DefaultSavedVariablesPerCharacter = function()
	return {
		["version"] = NS.version,
		["showMinimapButton"] = true,
		["minimapButtonPosition"] = 45,
	};
end

--
NS.Upgrade = function()
	local vars = NS.DefaultSavedVariables();
	local version = NS.db["version"];
	-- 1.3
	if version < 1.3 then
		NS.db["showCharacterRealms"] = vars["showCharacterRealms"];
	end
	--
	NS.db["version"] = NS.version;
end

--
NS.UpgradePerCharacter = function()
	local varspercharacter = NS.DefaultSavedVariablesPerCharacter();
	local version = NS.dbpc["version"];
	-- 1.x
	--if version < 1.x then
		-- No upgrades
	--end
	--
	NS.dbpc["version"] = NS.version;
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------------------------------------------------------------------
NS.SecondsToStrTime = function( seconds ) -- REDEFINED FOR COLORING
	local originalSeconds = seconds;
	-- Seconds In Min, Hour, Day
    local secondsInAMinute = 60;
    local secondsInAnHour  = 60 * secondsInAMinute;
    local secondsInADay    = 24 * secondsInAnHour;
    -- Days
    local days = math.floor( seconds / secondsInADay );
    -- Hours
    local hourSeconds = seconds % secondsInADay;
    local hours = math.floor( hourSeconds / secondsInAnHour );
    -- Minutes
    local minuteSeconds = hourSeconds % secondsInAnHour;
    local minutes = floor( minuteSeconds / secondsInAMinute );
    -- Seconds
    local remainingSeconds = minuteSeconds % secondsInAMinute;
    local seconds = math.ceil( remainingSeconds );
	--
	local strTime = ( days > 0 and hours == 0 and days .. " day" ) or ( days > 0 and days .. " day " .. hours .. " hr" ) or ( hours > 0 and minutes == 0 and hours .. " hr" ) or ( hours > 0 and hours .. " hr " .. minutes .. " min" ) or ( minutes > 0 and minutes .. " min" ) or seconds .. " sec";
	-- COLORING - RED/GREEN
	return ( originalSeconds < NS.db["alertSeconds"] and NS.db["alertType"] ~= "disabled" ) and RED_FONT_COLOR_CODE .. strTime .. FONT_COLOR_CODE_CLOSE or GREEN_FONT_COLOR_CODE .. strTime .. FONT_COLOR_CODE_CLOSE;
end

--
NS.BuildingName = function( name )
	local sharedNames = {
		-- Prebuilt
		["Lunarfall Excavation"] = "Lunarfall Excavation / Frostwall Mines",
		["Frostwall Mines"] = "Lunarfall Excavation / Frostwall Mines",
		-- Large
		["Dwarven Bunker"] =  "Dwarven Bunker / War Mill",
		["War Mill"] =  "Dwarven Bunker / War Mill",
		["Gnomish Gearworks"] = "Gnomish Gearworks / Goblin Workshop",
		["Goblin Workshop"] = "Gnomish Gearworks / Goblin Workshop",
		["Mage Tower"] = "Mage Tower / Spirit Lodge",
		["Spirit Lodge"] = "Mage Tower / Spirit Lodge",
	};
	return sharedNames[name] and sharedNames[name] or name;
end

--
NS.FactionBuildingName = function( faction, name )
	local sharedNames = {
		-- Prebuilt
		["Alliance:Lunarfall Excavation / Frostwall Mines"] = "Lunarfall Excavation",
		["Horde:Lunarfall Excavation / Frostwall Mines"] = "Frostwall Mines",
		-- Large
		["Alliance:Dwarven Bunker / War Mill"] =  "Dwarven Bunker",
		["Horde:Dwarven Bunker / War Mill"] =  "War Mill",
		["Alliance:Gnomish Gearworks / Goblin Workshop"] = "Gnomish Gearworks",
		["Horde:Gnomish Gearworks / Goblin Workshop"] = "Goblin Workshop",
		["Alliance:Mage Tower / Spirit Lodge"] = "Mage Tower",
		["Horde:Mage Tower / Spirit Lodge"] = "Spirit Lodge",
	};
	return sharedNames[faction .. ":" .. name] and sharedNames[faction .. ":" .. name] or name;
end

--
NS.OrdersReady = function( ordersReady, ordersTotal, ordersDuration, ordersNextSeconds, lastTimeUpdated )
	-- Calculate how many orders could have completed in the time past, which could not be larger than the
	-- amount of orders in progress ( i.e. total - ready ), then we just add the orders that were already ready
	if not ordersTotal then return 0 end
	return math.min( math.floor( ( time() - lastTimeUpdated + ( ordersDuration - ordersNextSeconds ) ) / ordersDuration ), ( ordersTotal - ordersReady ) ) + ordersReady;
end

--
NS.OrdersInProgress = function( ordersTotal, ordersReady )
	if not ordersTotal then return 0 end
	return ordersTotal - ordersReady;
end

--
NS.ordersOutSeconds = function( ordersDuration, ordersTotal, ordersReady, ordersNextSeconds, lastTimeUpdated )
	if not ordersTotal then return 0 end
	local seconds = ordersDuration * ( ordersTotal - ordersReady ) - ( ordersDuration - ( ordersNextSeconds - ( time() - lastTimeUpdated ) ) );
	return seconds > 0 and seconds or 0;
end

--
NS.GCache = function( gCacheSize, gCacheLastTimeLooted )
	local gCache = math.floor( ( time() - gCacheLastTimeLooted ) / 600 ); -- Seconds past since looted divided by 600 seconds (1 GR is created every 10 min)
	return gCache > gCacheSize and gCacheSize or gCache;
end

--
NS.GCacheFullSeconds = function( gCacheSize, gCacheLastTimeLooted )
	local gCacheSecondsRemaining = ( 600 * gCacheSize ) - ( time() - gCacheLastTimeLooted ); -- Seconds left to fill cache, may be negative is already full (1 GR is created every 10 min or 600)
	return gCacheSecondsRemaining >= 0 and gCacheSecondsRemaining or 0; -- Zero if 0 or negative
end
--
NS.ToggleAlert = function()
	if not NS.minimapButtonFlash then
		NS.minimapButtonFlash = WOCMinimapButton:CreateAnimationGroup();
		NS.minimapButtonFlash:SetLooping( "REPEAT" );
		local a1 = NS.minimapButtonFlash:CreateAnimation( "Alpha" );
		a1:SetDuration( 0.5 );
		a1:SetChange( -1 );
		a1:SetOrder( 1 );
		local a2 = NS.minimapButtonFlash:CreateAnimation( "Alpha" );
		a2:SetDuration( 0.5 );
		a2:SetChange( 1 );
		a2:SetOrder( 2 );
	end
	--
	if	NS.dbpc["showMinimapButton"] and (
			-- Next Out / Full (All Characters ONLY)
			( NS.db["alertType"] == "next" and (
				( NS.allCharacters.nextOutFullSeconds.buildings and NS.allCharacters.nextOutFullSeconds.buildings <= NS.db["alertSeconds"] ) or -- Building
				( NS.allCharacters.nextOutFullSeconds.garrisonCache and NS.allCharacters.nextOutFullSeconds.garrisonCache <= NS.db["alertSeconds"] ) -- Garrison Cache
			) ) or
			-- All Out / Full (All Characters ONLY)
			( NS.db["allOutAlertSeconds"] == "all" and (
				( NS.allCharacters.allOutFullSeconds.buildings and NS.allCharacters.allOutFullSeconds.buildings <= NS.db["alertSeconds"] ) or
				( NS.allCharacters.allOutFullSeconds.garrisonCache and NS.allCharacters.allOutFullSeconds.garrisonCache <= NS.db["alertSeconds"] )
			) )
		) then
		if not NS.alertFlashing then
			NS.alertFlashing = true;
			NS.minimapButtonFlash:Play();
		end
	else
		if NS.alertFlashing then
			NS.alertFlashing = false;
			NS.minimapButtonFlash:Stop();
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Updates
--------------------------------------------------------------------------------------------------------------------------------------------
NS.UpdateCharacter = function()
	local newCharacter = false;
	-- Find/Add Character
	local k = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ) or #NS.db["characters"] + 1;
	if not NS.db["characters"][k] then
		newCharacter = true; -- Flag for sort
		NS.db["characters"][k] = {
			["name"] = NS.currentCharacter.name,-- No need to update, if name changes, it'll be added as a new character
			["realm"] = GetRealmName(),			-- No need to update, if realm changes, it'll be added as a new character
			--["faction"] = nil,				-- Set below each update
			--["buildings"] = {},				-- Set below each update
			["monitor"] = { ["gCache"] = true },-- Garrison Cache monitored by default, false when unchecked
			["gCacheLastTimeLooted"] = time(),	-- Not looted yet
			--["gCacheSize"] = nil,				-- Set below each update, used for deciding whether character is used throughout addon
		};
	end
	-- Update Faction - Pandaren start neutral and some players will pay for a faction change, the first update after choosing or changing factions will correct their faction
	NS.currentCharacter.faction = UnitFactionGroup( "player" );
	NS.db["characters"][k]["faction"] = NS.currentCharacter.faction;
	-- Update gCacheSize - Quests may be completed later, in patch 6.2 cache is upgradeable to 1000 from 500 via an item that flags quest 37485 as complete
	NS.db["characters"][k]["gCacheSize"] = IsQuestFlaggedCompleted( 37485 ) and 1000 or ( ( IsQuestFlaggedCompleted( 35176 ) or IsQuestFlaggedCompleted( 34824 ) ) and 500 ) or 0; -- Faction quests complete for use of Garrison Cache?
	-- Buildings
	NS.db["characters"][k]["buildings"] = {}; -- Out with the old, new awaits us below
	--
	for _,building in ipairs( C_Garrison.GetBuildings() ) do
		local buildingID,buildingName,_,_,_,rank,_,_,_,_,_,_,_,_,_,_,_,_,_,_,isBeingBuilt,_,_,_,_ = C_Garrison.GetOwnedBuildingInfo( building.plotID );
		local _,_,shipmentCapacity,shipmentsReady,shipmentsTotal,_,duration,timeleftString,_,_,_,_ = C_Garrison.GetLandingPageShipmentInfo( buildingID );
		buildingName = NS.BuildingName( buildingName ); -- Resolves shared names
		if shipmentCapacity and NS.buildingInfo[buildingName] then -- Only store expected buildings with Work Orders
			table.insert( NS.db["characters"][k]["buildings"], {
				["id"] = buildingID,											-- 145, etc.
				["name"] = buildingName,										-- Trading Post, etc.
				["type"] = NS.buildingInfo[buildingName].type,					-- 1, 2, 3, 4 ( Prebuilt, Large, Medium, Small )
				["ordersCapacity"] = shipmentCapacity,
				["ordersReady"] = shipmentsReady,								-- nil if no orders
				["ordersTotal"] = shipmentsTotal,								-- nil if no orders
				["ordersDuration"] = duration,									-- nil if no orders
				["ordersNextSeconds"] = ( function()							-- 0 if no orders
					local ordersNextSeconds = NS.StrTimeToSeconds( timeleftString );
					if duration and ordersNextSeconds > duration then
						-- Rebuilt buildings with more than one preexisting Work Order in progress have all orders lumped into one large order.
						-- This may make Orders Ready calculations inaccurate temporarily, but will correct itself when the lumped order completes.
						ordersNextSeconds = duration - 1;
					end
					return ordersNextSeconds;
				end )(),
				["lastTimeUpdated"] = time(),
			} );
			--
			if NS.db["characters"][k]["monitor"][buildingName] == nil then
				NS.db["characters"][k]["monitor"][buildingName] = true; -- All buildings monitored by default, false when unchecked
			end
		end
	end
	-- Sort character's buildings, this order trickles down thru other tables using this building data
	table.sort ( NS.db["characters"][k]["buildings"], -- Sort buildings by type, name for Characters tab check button consistency
		function ( b1, b2 )
			if b1["type"] == b2["type"] then
				return b1["name"] < b2["name"];
			else
				return b1["type"] < b2["type"];
			end
		end
	);
	-- Sort if New Character added
	if newCharacter then
		table.sort ( NS.db["characters"],
			function ( char1, char2 )
				if char1["realm"] == char2["realm"] then
					return char1["name"] < char2["name"];
				else
					return char1["realm"] < char2["realm"];
				end
			end
		);
	end
end

--
NS.UpdateBuildings = function()
	-- All Characters
	local buildings = {};
	local nextOutFullSeconds = { buildings = nil };
	local allOutFullSeconds = { buildings = nil };
	-- Current Character
	local currentCharacter = {
		buildings = {},
		nextOutFullSeconds = { buildings = nil },
		allOutFullSeconds = { buildings = nil },
	};
	-- Loop thru each character adding to or creating a building-specific table, which includes account-wide and character-specific data
	for _,character in ipairs( NS.db["characters"] ) do
		for _,b in ipairs( character["buildings"] ) do -- b is for building
			if character["monitor"][b["name"]] then
				-- Add/Find account-wide building data building by name
				local k = NS.FindKeyByName( buildings, b["name"] ) or #buildings + 1;
				if not buildings[k] then
					buildings[k] = {
						["name"] = b["name"],
						["characters"] = {},
						["ordersReady"] = 0,
						["ordersInProgress"] = 0,
						["ordersCapacity"] = 0,
						["ordersAllOutSeconds"] = 0,
						["ordersNextOutSeconds"] = nil,
						["no"] = 0,
					};
				end
				-- Add character-specific data to building
				local ck = #buildings[k]["characters"] + 1; -- Manually setting characters with integer keys for sort/ipairs display
				buildings[k]["characters"][ck] = {
					["name"] = character["name"],
					["ordersReady"] = 0,
					["ordersInProgress"] = 0,
					["ordersCapacity"] = 0,
					["ordersOutSeconds"] = 0,
				};
				buildings[k]["no"] = buildings[k]["no"] + 1; -- Increment no. of that building
				-- Orders Ready (Character and Building)
				buildings[k]["characters"][ck]["ordersReady"] = NS.OrdersReady( b.ordersReady, b.ordersTotal, b.ordersDuration, b.ordersNextSeconds, b.lastTimeUpdated );
				buildings[k]["ordersReady"] = buildings[k]["ordersReady"] + buildings[k]["characters"][ck]["ordersReady"];
				-- Orders In Progress (Character and Building)
				buildings[k]["characters"][ck]["ordersInProgress"] = NS.OrdersInProgress( b.ordersTotal, buildings[k]["characters"][ck]["ordersReady"] );
				buildings[k]["ordersInProgress"] = buildings[k]["ordersInProgress"] + buildings[k]["characters"][ck]["ordersInProgress"];
				-- Orders Capacity (Character and Building)
				buildings[k]["characters"][ck]["ordersCapacity"] = b.ordersCapacity;
				buildings[k]["ordersCapacity"] = buildings[k]["ordersCapacity"] + buildings[k]["characters"][ck]["ordersCapacity"];
				-- Orders Out Seconds (Character ONLY)
				buildings[k]["characters"][ck]["ordersOutSeconds"] = NS.ordersOutSeconds( b.ordersDuration, b.ordersTotal, b.ordersReady, b.ordersNextSeconds, b.lastTimeUpdated );
				-- Orders All Out Seconds (Building ONLY)
				buildings[k]["ordersAllOutSeconds"] = math.max( buildings[k]["ordersAllOutSeconds"], buildings[k]["characters"][ck]["ordersOutSeconds"] );
				-- Orders Next Out Seconds (Building ONLY)
				buildings[k]["ordersNextOutSeconds"] = buildings[k]["ordersNextOutSeconds"] and math.min( buildings[k]["ordersNextOutSeconds"], buildings[k]["characters"][ck]["ordersOutSeconds"] ) or buildings[k]["characters"][ck]["ordersOutSeconds"];
				-- Orders Next/All Out Seconds (All Buildings, All Characters)
				nextOutFullSeconds.buildings = nextOutFullSeconds.buildings and math.min( nextOutFullSeconds.buildings, buildings[k]["ordersNextOutSeconds"] ) or buildings[k]["ordersNextOutSeconds"];
				allOutFullSeconds.buildings = allOutFullSeconds.buildings and math.max( allOutFullSeconds.buildings, buildings[k]["ordersOutSeconds"] ) or buildings[k]["ordersOutSeconds"];
				-- Current Character
				if character["name"] == NS.currentCharacter.name then
					local characterBuilding = CopyTable( buildings[k]["characters"][ck] );
					characterBuilding["name"] = b["name"]; -- Replace character name with building name
					table.insert( currentCharacter.buildings, characterBuilding );
				end
			end
		end
	end
	-- Sort and save to namespace
	-- All Characters
	for k = 1, #buildings do
		NS.Sort( buildings[k]["characters"], "ordersOutSeconds", "ASC" ); -- Sort characters of each building
	end
	NS.Sort( buildings, "ordersNextOutSeconds", "ASC" ); -- Sort buildings
	NS.allCharacters.buildings = buildings;
	NS.allCharacters.nextOutFullSeconds.buildings = nextOutFullSeconds.buildings;
	NS.allCharacters.allOutFullSeconds.buildings = allOutFullSeconds.buildings;
	-- Current Character
	NS.Sort( currentCharacter.buildings, "ordersOutSeconds", "ASC" ); -- Sort current character's buildings
	NS.currentCharacter.buildings = currentCharacter.buildings;
	NS.currentCharacter.nextOutFullSeconds.buildings = #currentCharacter.buildings > 0 and currentCharacter.buildings[1]["ordersOutSeconds"] or nil;
	NS.currentCharacter.allOutFullSeconds.buildings = #currentCharacter.buildings > 0 and currentCharacter.buildings[#currentCharacter.buildings]["ordersOutSeconds"] or nil;
end

--
NS.UpdateGarrisonCache = function()
	-- All Characters
	local garrisonCache = {
		["characters"] = {},
	};
	local nextOutFullSeconds = { garrisonCache = nil };
	local allOutFullSeconds = { garrisonCache = nil };
	-- Current Character
	local currentCharacter = {
		garrisonCache = {},
		nextOutFullSeconds = { garrisonCache = nil },
		allOutFullSeconds = { garrisonCache = nil },
	};
	-- Loop thru each character adding to account-wide table if they have a Garrison Cache and checked it for monitoring
	for _,character in ipairs( NS.db["characters"] ) do
		if character["gCacheSize"] > 0 and character["monitor"]["gCache"] then
			-- Add character data to account-wide table
			local ck = #garrisonCache["characters"] + 1; -- Manually setting characters with integer keys for sort/ipairs display
			garrisonCache["characters"][ck] = {
				["name"] = character["name"],
				["gCache"] = 0,
				["fullSeconds"] = 0,
			};
			-- Character-specific seconds until Garrison Cache is full
			garrisonCache["characters"][ck]["gCache"] = NS.GCache( character["gCacheSize"], character["gCacheLastTimeLooted"] );
			garrisonCache["characters"][ck]["fullSeconds"] = NS.GCacheFullSeconds( character["gCacheSize"], character["gCacheLastTimeLooted"] );
			-- Account-wide min/max seconds until Garrison Cache is full
			nextOutFullSeconds.garrisonCache = nextOutFullSeconds.garrisonCache and math.min( nextOutFullSeconds.garrisonCache, garrisonCache["characters"][ck]["fullSeconds"] ) or garrisonCache["characters"][ck]["fullSeconds"];
			allOutFullSeconds.garrisonCache = allOutFullSeconds.garrisonCache and math.max( allOutFullSeconds.garrisonCache, garrisonCache["characters"][ck]["fullSeconds"] ) or garrisonCache["characters"][ck]["fullSeconds"];
			-- Current Character
			if character["name"] == NS.currentCharacter.name then
				currentCharacter.garrisonCache = CopyTable( garrisonCache["characters"][ck] );
			end
		end
	end
	-- Sort and save to namespace
	-- All Characters
	NS.Sort( garrisonCache["characters"], "fullSeconds", "ASC" );
	NS.allCharacters.garrisonCache = garrisonCache;
	NS.allCharacters.nextOutFullSeconds.garrisonCache = nextOutFullSeconds.garrisonCache;
	NS.allCharacters.allOutFullSeconds.garrisonCache = allOutFullSeconds.garrisonCache;
	-- Current Character
	NS.currentCharacter.garrisonCache = currentCharacter.garrisonCache;
	NS.currentCharacter.nextOutFullSeconds.garrisonCache = currentCharacter.garrisonCache["fullSeconds"] and currentCharacter.garrisonCache["fullSeconds"] or nil;
	NS.currentCharacter.allOutFullSeconds.garrisonCache = currentCharacter.garrisonCache["fullSeconds"] and currentCharacter.garrisonCache["fullSeconds"] or nil;
end
--
NS.UpdateAll = function( forceUpdate )
	-- Stop and delay attempted regular update if a forceUpdate has run recently
	if not forceUpdate then
		local lastSecondsUpdateAll = time() - NS.lastTimeUpdateAll;
		if lastSecondsUpdateAll < 10 then
			C_Timer.After( ( 10 - lastSecondsUpdateAll ), NS.UpdateAll );
			return; -- Stop function
		end
	end
	-- Updates
	NS.UpdateCharacter();
	NS.UpdateBuildings();
	NS.UpdateGarrisonCache();
	NS.lastTimeUpdateAll = time();
	-- Schedule next regular update, repeats every 10 seconds
	if not forceUpdate or not NS.initialized then -- Initial call is forced, regular updates are not
		C_Timer.After( 10, NS.UpdateAll );
	end
	-- Initialize
	if not NS.initialized then
		NS.currentCharacter.key = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ); -- Must be reset when character is deleted
		NS.selectedCharacterKey = NS.db["characters"][NS.currentCharacter.key]["gCacheSize"] > 0 and NS.currentCharacter.key or nil; -- Sets selected character to current character if they will be included on character dropdown
		--
		WOCEventsFrame:RegisterEvent( "GARRISON_SHIPMENT_RECEIVED" ); -- Fires when using one of the Rush Order items
		hooksecurefunc( "LootWonAlertFrame_SetUp", NS.OnLootGarrisonCache ); -- Fires anytime you get the loot alert frame, but restricts updating to looting the Garrison Cache
		--
		NS.initialized = true;
	end
	-- Alert
	NS.ToggleAlert(); -- Always attempt to turn on/off alerts after updating
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------------------------------------------------------------------
NS.MinimapButton( "WOCMinimapButton", "Interface\\ICONS\\inv_letter_03", {
	dbpc = "minimapButtonPosition",
	tooltip = function()
		GameTooltip:SetText( HIGHLIGHT_FONT_COLOR_CODE .. NS.title .. FONT_COLOR_CODE_CLOSE .. " v" .. NS.versionString );
		GameTooltip:AddLine( L["Left-Click to open and close"] );
		GameTooltip:AddLine( L["Drag to move this button"] );
		GameTooltip:Show();
	end,
	OnLeftClick = function( self )
		NS.SlashCmdHandler();
	end,
} );
--------------------------------------------------------------------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------------------------------------------------------------------
NS.SlashCmdHandler = function( cmd )
	if not NS.initialized then return end
	--
	if NS.UI.MainFrame:IsShown() then
		NS.UI.MainFrame:Hide();
	elseif not cmd or cmd == "" or cmd == "monitor" then
		NS.UI.MainFrame:ShowTab( 1 );
	elseif cmd == "characters" then
		NS.UI.MainFrame:ShowTab( 2 );
	elseif cmd == "options" then
		NS.UI.MainFrame:ShowTab( 3 );
	elseif cmd == "help" then
		NS.UI.MainFrame:ShowTab( 4 );
	else
		NS.UI.MainFrame:ShowTab( 4 );
		NS.Print( L["Unknown command, opening Help"] );
	end
end
--
SLASH_WORKORDERSCOMPLETE1 = "/workorderscomplete";
SLASH_WORKORDERSCOMPLETE2 = "/woc";
SlashCmdList["WORKORDERSCOMPLETE"] = function( msg ) NS.SlashCmdHandler( msg ) end;
--------------------------------------------------------------------------------------------------------------------------------------------
-- Event/Hook Handlers
--------------------------------------------------------------------------------------------------------------------------------------------
NS.OnAddonLoaded = function( event ) -- ADDON_LOADED
	if IsAddOnLoaded( NS.addon ) then
		WOCEventsFrame:UnregisterEvent( event );
		-- SavedVariables
		if not WORKORDERSCOMPLETE_SAVEDVARIABLES then
			WORKORDERSCOMPLETE_SAVEDVARIABLES = NS.DefaultSavedVariables();
		end
		-- SavedVariablesPerCharacter
		if not WORKORDERSCOMPLETE_SAVEDVARIABLESPERCHARACTER then
			WORKORDERSCOMPLETE_SAVEDVARIABLESPERCHARACTER = NS.DefaultSavedVariablesPerCharacter();
		end
		-- Localize SavedVariables
		NS.db = WORKORDERSCOMPLETE_SAVEDVARIABLES;
		NS.dbpc = WORKORDERSCOMPLETE_SAVEDVARIABLESPERCHARACTER;
		-- Upgrade db
		if NS.db["version"] < NS.version then
			NS.Upgrade();
		end
		-- Upgrade dbpc
		if NS.dbpc["version"] < NS.version then
			NS.UpgradePerCharacter();
		end
	end
end

--
NS.OnPlayerLogin = function( event ) -- PLAYER_LOGIN
	WOCEventsFrame:UnregisterEvent( event );
	NS.ShipmentRequestHandler( event ); -- Initial shipment request
	NS.ShipmentRequestHandler(); -- Start handler/ticker
	-- Minimap Button
	WOCMinimapButton:UpdatePos(); -- Resets to last drag position
	if not NS.dbpc["showMinimapButton"] then
		WOCMinimapButton:Hide(); -- Hide if unchecked in options
	end
end

--
NS.ShipmentInfoUpdated = function( event )
	-- RequestLandingPageShipmentInfo() -> GARRISON_LANDINGPAGE_SHIPMENTS
	WOCEventsFrame:UnregisterEvent( event );
	NS.UpdateAll( "forceUpdate" );
end

--
NS.ShipmentRequestHandler = function( event )
	-- Ticker
	if not event then
		-- When inside the Garrison, shipment requests are made automatically every 2 seconds
		-- When outside the Garrison, shipment requests are only made 2 seconds after an event fires
		local shipmentRequestTimePast = NS.lastTimeShipmentRequest and ( time() - NS.lastTimeShipmentRequest ) or 0;
		local shipmentRequestSentTimePast = C_Garrison.IsOnGarrisonMap() and NS.lastTimeShipmentRequestSent and ( time() - NS.lastTimeShipmentRequestSent ) or 0; -- Set to zero to ignore time past if not inside Garrison
		--
		if math.max( shipmentRequestTimePast, shipmentRequestSentTimePast ) >= 2 then
			-- Send shipment request
			NS.lastTimeShipmentRequest = nil;
			NS.lastTimeShipmentRequestSent = time();
			WOCEventsFrame:RegisterEvent( "GARRISON_LANDINGPAGE_SHIPMENTS" );
			C_Garrison.RequestLandingPageShipmentInfo();
		end
		--
		C_Timer.After( 0.5, NS.ShipmentRequestHandler ); -- Emulate ticker, handling shipment requests every half-second
	-- Events
	else
		NS.lastTimeShipmentRequest = time();
	end
end

--
NS.OnLootGarrisonCache = function( _,_,_,_,_,_,_,_,lootSource )
	if lootSource == 10 then -- Garrison Cache = 10
		NS.db["characters"][NS.currentCharacter.key]["gCacheLastTimeLooted"] = time();
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- WOCEventsFrame
--------------------------------------------------------------------------------------------------------------------------------------------
NS.Frame( "WOCEventsFrame", UIParent, {
	topLevel = true,
	OnEvent = function ( self, event, ... )
		if		event == "GARRISON_LANDINGPAGE_SHIPMENTS"	then	NS.ShipmentInfoUpdated( event );
		elseif	event == "GARRISON_SHIPMENT_RECEIVED"		then	NS.ShipmentRequestHandler( event );
		elseif	event == "ADDON_LOADED"						then	NS.OnAddonLoaded( event );
		elseif	event == "PLAYER_LOGIN"						then	NS.OnPlayerLogin( event );
		end
	end,
	OnLoad = function( self )
		self:RegisterEvent( "ADDON_LOADED" );
		self:RegisterEvent( "PLAYER_LOGIN" );
	end,
} );
