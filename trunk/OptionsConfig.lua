--------------------------------------------------------------------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------------------------------------------------------------------
local NS = select( 2, ... );
local L = NS.localization;
--------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------------------------------------------------------------------
NS.options.cfg = {
	--
	mainFrame = {
		width		= 585,
		height		= 403,
		frameStrata	= "HIGH",
		frameLevel	= 2,
		Init		= function( MainFrame ) end,
		OnShow		= function( MainFrame )
			MainFrame:ClearAllPoints();
			MainFrame:SetPoint( "CENTER", 0, 0 );
		end,
		OnHide		= function( MainFrame )
			StaticPopup_Hide( "WOC_CHARACTER_DELETE" );
		end,
	},
	--
	subFrameTabs = {
		{
			-- Monitor
			mainFrameTitle	= NS.title,
			tabText			= "Monitor",
			Init			= function( SubFrame )
				NS.Button( "IconColumnHeaderButton", SubFrame, "B", {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 30, 19 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 7, -8 },
				} );
				NS.Button( "ReadyColumnHeaderButton", SubFrame, "" .. L["Ready"], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 82, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "InProgressColumnHeaderButton", SubFrame, "" .. L["In Prog."], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 82, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "CapacityColumnHeaderButton", SubFrame, "" .. L["Capacity"], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 82, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "NextOutColumnHeaderButton", SubFrame, "" .. L["Next Out"], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 102, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "AllOutColumnHeaderButton", SubFrame, "" .. L["All Out"], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 102, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "NoColumnHeaderButton", SubFrame, "" .. L["No."], {
					template = "WOCColumnHeaderButtonTemplate",
					size = { 52, 19 },
					setPoint = { "TOPLEFT", "#sibling", "TOPRIGHT", -2, 0 },
				} );
				NS.Button( "RefreshButton", SubFrame, L["Refresh"], {
					size = { 96, 20 },
					setPoint = { "BOTTOMRIGHT", "#sibling", "TOPRIGHT", 2, 15 },
					fontObject = "GameFontNormalSmall",
					OnClick = function()
						SubFrame:Refresh();
						NS.Print( "Monitor tab refreshed" );
					end,
				} );
				NS.ScrollFrame( "ScrollFrame", SubFrame, {
					size = { 520, ( 26 * 10 - 5 ) },
					setPoint = { "TOPLEFT", "$parentIconColumnHeaderButton", "BOTTOMLEFT", 1, -3 },
					buttonTemplate = "WOCScrollFrameButtonTemplate",
					udpate = {
						numToDisplay = 10,
						buttonHeight = 26,
						alwaysShowScrollBar = true,
						UpdateFunction = function( sf )
							local items = NS.allCharacters.buildings; -- Items are buildings, in this case
							local numItems = #items;
							local sfn = SubFrame:GetName();
							--_G[sfn .. "ItemsNumText"]:SetText( numItems ); -- Set characters in bottom right
							FauxScrollFrame_Update( sf, numItems, sf.numToDisplay, sf.buttonHeight, nil, nil, nil, nil, nil, nil, sf.alwaysShowScrollBar );
							for num = 1, sf.numToDisplay do
								local bn = sf.buttonName .. num; -- button name
								local b = _G[bn]; -- button
								local k = FauxScrollFrame_GetOffset( sf ) + num; -- key
								b:UnlockHighlight();
								if k <= numItems then
									local IconOnEnter = function( self )
										GameTooltip:SetOwner( self, "ANCHOR_RIGHT" );
										GameTooltip:SetText( "|T" .. NS.buildingInfo[items[k]["name"]].icon .. ":16|t " .. items[k]["name"] );
										for _,c in ipairs( items[k]["characters"] ) do
											local cn = NS.db["hideCharacterRealms"] and strsplit( "-", c["name"], 2 ) or c["name"];
											GameTooltip:AddLine( cn, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
										end
										GameTooltip:Show();
										b:LockHighlight();
									end
									local DataButtonOnEnter = function( self, column )
										GameTooltip:SetOwner( self, "ANCHOR_TOP" );
										GameTooltip:SetText( "|T" .. NS.buildingInfo[items[k]["name"]].icon .. ":16|t " .. items[k]["name"] .. " - " .. column );
										for _,c in ipairs( items[k]["characters"] ) do
											local cn = NS.db["hideCharacterRealms"] and strsplit( "-", c["name"], 2 ) or c["name"];
											if column == "Ready" then
												GameTooltip:AddDoubleLine( cn, c["ordersReady"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b );
											elseif column == "In. Prog" then
												GameTooltip:AddDoubleLine( cn, c["ordersInProgress"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
											elseif column == "Capacity" then
												GameTooltip:AddDoubleLine( cn, c["ordersCapacity"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
											elseif column == "Next Out" then
												GameTooltip:AddDoubleLine( cn, NS.SecondsToStrTime( c["ordersOutSeconds"] ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
											elseif column == "All Out" then
												GameTooltip:AddDoubleLine( cn, NS.SecondsToStrTime( c["ordersOutSeconds"] ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
											end
										end
										GameTooltip:Show();
										b:LockHighlight();
									end
									local OnLeave = function( self )
										GameTooltip_Hide();
										b:UnlockHighlight();
									end
									_G[bn .. "_IconTexture"]:SetNormalTexture( NS.buildingInfo[items[k]["name"]].icon );
									_G[bn .. "_IconTexture"]:SetScript( "OnEnter", IconOnEnter );
									_G[bn .. "_IconTexture"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_ReadyText"]:SetText( BATTLENET_FONT_COLOR_CODE .. items[k]["ordersReady"] .. FONT_COLOR_CODE_CLOSE );
									_G[bn .. "_Ready"]:SetScript( "OnEnter", function( self ) DataButtonOnEnter( self, "Ready" ); end );
									_G[bn .. "_Ready"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_InProgressText"]:SetText( items[k]["ordersInProgress"] );
									_G[bn .. "_InProgress"]:SetScript( "OnEnter", function( self ) DataButtonOnEnter( self, "In. Prog" ); end );
									_G[bn .. "_InProgress"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_CapacityText"]:SetText( items[k]["ordersCapacity"] );
									_G[bn .. "_Capacity"]:SetScript( "OnEnter", function( self ) DataButtonOnEnter( self, "Capacity" ); end );
									_G[bn .. "_Capacity"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_NextOutText"]:SetText( NS.SecondsToStrTime( items[k]["ordersNextOutSeconds"] ) );
									_G[bn .. "_NextOut"]:SetScript( "OnEnter", function( self ) DataButtonOnEnter( self, "Next Out" ); end );
									_G[bn .. "_NextOut"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_AllOutText"]:SetText( NS.SecondsToStrTime( items[k]["ordersAllOutSeconds"] ) );
									_G[bn .. "_AllOut"]:SetScript( "OnEnter", function( self ) DataButtonOnEnter( self, "All Out" ); end );
									_G[bn .. "_AllOut"]:SetScript( "OnLeave", OnLeave );
									--
									_G[bn .. "_No"]:SetText( items[k]["no"] );
									b:Show();
								else
									b:Hide();
								end
							end
						end
					},
				} );
				NS.Button( "GarrisonCache", SubFrame, nil, {
					template = false,
					size = { 32, 32 },
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -12 },
					normalTexture = "Interface\\ICONS\\inv_garrison_resource",
					tooltip = function()
						GameTooltip:SetText( "|TInterface\\ICONS\\inv_garrison_resource:16|t " .. L["Garrison Cache - Ready for pickup"] );
						for _,c in ipairs( NS.allCharacters.garrisonCache["characters"] ) do -- Adding all characters with a cache that are being monitored
							local cn = NS.db["hideCharacterRealms"] and strsplit( "-", c["name"], 2 ) or c["name"];
							GameTooltip:AddDoubleLine( cn, c["gCache"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b );
						end
						if #NS.allCharacters.garrisonCache["characters"] == 0 then -- No characters with a cache being monitored
							GameTooltip:AddLine( L["No characters being monitored"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
						end
					end,
					OnLoad = function( self )
						self.tooltipAnchor = { self, "ANCHOR_RIGHT" };
					end,
				} );
				NS.Button( "GarrisonCacheNextAll", SubFrame, nil, {
					template = false,
					size = { 170, 32 },
					setPoint = { "LEFT", "#sibling", "RIGHT", 10, 0 },
					tooltip = function()
						GameTooltip:SetText( "|TInterface\\ICONS\\inv_garrison_resource:16|t " .. L["Garrison Cache - Time Remaining"] );
						for _,c in ipairs( NS.allCharacters.garrisonCache["characters"] ) do -- Adding all characters with a cache that are being monitored
							local cn = NS.db["hideCharacterRealms"] and strsplit( "-", c["name"], 2 ) or c["name"];
							GameTooltip:AddDoubleLine( cn, NS.SecondsToStrTime( c["fullSeconds"] ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
						end
						if #NS.allCharacters.garrisonCache["characters"] == 0 then -- No characters with a cache being monitored
							GameTooltip:AddLine( L["No characters being monitored"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
						end
					end,
					OnLoad = function( self )
						self.tooltipAnchor = { self, "ANCHOR_TOP" };
						local fs = self:CreateFontString( "$parentText" );
						fs:SetAllPoints();
						fs:SetFontObject( "GameFontNormal" );
						fs:SetJustifyH( "LEFT" );
					end,
				} );
				NS.Button( "CurrentCharacterNextAll", SubFrame, nil, {
					template = false,
					size = { 170, 32 },
					setPoint = { "TOPRIGHT", "$parentScrollFrame", "BOTTOMRIGHT", 31, -12 },
					tooltip = function()
						local cn = NS.db["hideCharacterRealms"] and strsplit( "-", NS.currentCharacter.name, 2 ) or NS.currentCharacter.name;
						GameTooltip:SetText( cn .. " - " .. L["Time Remaining"] );
						for _,building in ipairs( NS.currentCharacter.buildings ) do -- Adding all buildings that are being monitored
							GameTooltip:AddDoubleLine( "|T" .. NS.buildingInfo[building["name"]].icon .. ":16|t " .. NS.FactionBuildingName( NS.currentCharacter.faction, building["name"] ), NS.SecondsToStrTime( building["ordersOutSeconds"] ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
						end
						if NS.currentCharacter.garrisonCache["gCache"] then -- Character has a cache and it's being monitored
							GameTooltip:AddDoubleLine( "|TInterface\\ICONS\\inv_garrison_resource:16|t " .. L["Garrison Cache"], NS.SecondsToStrTime( NS.currentCharacter.nextOutFullSeconds.garrisonCache ), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
						end
						if #NS.currentCharacter.buildings == 0 and not NS.currentCharacter.garrisonCache["gCache"] then -- Nothing being monitored
							GameTooltip:AddLine( L["Nothing being monitored"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
						end
					end,
					OnLoad = function( self )
						self.tooltipAnchor = { self, "ANCHOR_TOP" };
						local fs = self:CreateFontString( "$parentText" );
						fs:SetAllPoints();
						fs:SetFontObject( "GameFontNormal" );
						fs:SetJustifyH( "LEFT" );
					end,
				} );
				NS.Button( "CurrentCharacter", SubFrame, nil, {
					template = false,
					size = { 32, 32 },
					setPoint = { "RIGHT", "#sibling", "LEFT", -10, 0 },
					normalTexture = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES",
					tooltip = function()
						local cn = NS.db["hideCharacterRealms"] and strsplit( "-", NS.currentCharacter.name, 2 ) or NS.currentCharacter.name;
						GameTooltip:SetText( cn .. " - " .. L["Ready for pickup"] );
						for _,building in ipairs( NS.currentCharacter.buildings ) do
							GameTooltip:AddDoubleLine( "|T" .. NS.buildingInfo[building["name"]].icon .. ":16|t " .. NS.FactionBuildingName( NS.currentCharacter.faction, building["name"] ), building["ordersReady"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b );
						end
						if NS.currentCharacter.garrisonCache["gCache"] then -- Character has a cache and it's being monitored
							GameTooltip:AddDoubleLine( "|TInterface\\ICONS\\inv_garrison_resource:16|t " .. L["Garrison Cache"], NS.currentCharacter.garrisonCache["gCache"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b );
						end
						if #NS.currentCharacter.buildings == 0 and not NS.currentCharacter.garrisonCache["gCache"] then -- Nothing being monitored
							GameTooltip:AddLine( L["Nothing being monitored"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
						end
					end,
					OnLoad = function( self )
						self.tooltipAnchor = { self, "ANCHOR_RIGHT" };
					end,
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				--
				_G[sfn .. "ScrollFrame"]:Reset();
				-- Garrison Cache - Next/All Full
				local gcNextOutFullSeconds = #NS.allCharacters.garrisonCache["characters"] > 0 and NS.SecondsToStrTime( NS.allCharacters.nextOutFullSeconds.garrisonCache ) or "-";
				local gcAllOutFullSeconds = #NS.allCharacters.garrisonCache["characters"] > 0 and NS.SecondsToStrTime( NS.allCharacters.allOutFullSeconds.garrisonCache ) or "-";
				_G[sfn .. "GarrisonCacheNextAllText"]:SetText( "Next Full: " .. gcNextOutFullSeconds .. "\n   All Full: " .. gcAllOutFullSeconds );
				-- Current Character - Fix My Face
				_G[sfn .. "CurrentCharacter"]:GetNormalTexture():SetTexCoord( NS.currentCharacter.TexCoords() ); -- Set TexCoords for proper faction/race/sex combo
				-- Current Character - Next Out/Full
				local ccNextOutFullSeconds;
				if NS.currentCharacter.nextOutFullSeconds.buildings and NS.currentCharacter.nextOutFullSeconds.garrisonCache then
					ccNextOutFullSeconds =  math.min( NS.currentCharacter.nextOutFullSeconds.buildings, NS.currentCharacter.nextOutFullSeconds.garrisonCache );
				elseif NS.currentCharacter.nextOutFullSeconds.buildings and not NS.currentCharacter.nextOutFullSeconds.garrisonCache then
					ccNextOutFullSeconds = NS.currentCharacter.nextOutFullSeconds.buildings;
				elseif NS.currentCharacter.nextOutFullSeconds.garrisonCache then
					ccNextOutFullSeconds = NS.currentCharacter.nextOutFullSeconds.garrisonCache;
				end
				-- Current Character - All Out/Full
				local ccAllOutFullSeconds;
				if NS.currentCharacter.allOutFullSeconds.buildings and NS.currentCharacter.allOutFullSeconds.garrisonCache then
					ccAllOutFullSeconds =  math.max( NS.currentCharacter.allOutFullSeconds.buildings, NS.currentCharacter.allOutFullSeconds.garrisonCache );
				elseif NS.currentCharacter.allOutFullSeconds.buildings and not NS.currentCharacter.allOutFullSeconds.garrisonCache then
					ccAllOutFullSeconds = NS.currentCharacter.allOutFullSeconds.buildings;
				elseif NS.currentCharacter.allOutFullSeconds.garrisonCache then
					ccAllOutFullSeconds = NS.currentCharacter.allOutFullSeconds.garrisonCache;
				end
				--
				ccNextOutFullSeconds = ccNextOutFullSeconds and NS.SecondsToStrTime( ccNextOutFullSeconds ) or "-";
				ccAllOutFullSeconds = ccAllOutFullSeconds and NS.SecondsToStrTime( ccAllOutFullSeconds ) or "-";
				_G[sfn .. "CurrentCharacterNextAllText"]:SetText( "Next Out/Full: " .. ccNextOutFullSeconds .. "\n   All Out/Full: " .. ccAllOutFullSeconds );
			end,
		},
		{
			-- Characters
			mainFrameTitle	= NS.title,
			tabText			= "Characters",
			Init			= function( SubFrame )
				NS.TextFrame( "Character", SubFrame, L["Character:"], {
					size = { 60, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.DropDownMenu( "CharacterDropDownMenu", SubFrame, {
					setPoint = { "LEFT", "#sibling", "RIGHT", -12, -1 },
					buttons = function()
						local t = {};
						for ck,character in ipairs( NS.db["characters"] ) do
							if character["gCacheSize"] > 0 then -- Exclude characters without a Garrison Cache
								local cn = NS.db["hideCharacterRealms"] and strsplit( "-", character["name"], 2 ) or character["name"];
								tinsert( t, { cn, ck } );
							end
						end
						return t;
					end,
					OnClick = function( info )
						NS.selectedCharacterKey = info.value;
						SubFrame:Refresh();
					end,
					width = 195,
				} );
				-- There are 9 total buildings a player could have that use
				-- Work Orders, so make enough check buttons for all of them
				for i = 1, 9 do
					NS.CheckButton( "BuildingCheckButton" .. i, SubFrame, L[""], {
						setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", ( i == 1 and 16 or 0 ), -1 },
						OnClick = function( checked, cb )
							NS.db["characters"][NS.selectedCharacterKey]["monitor"][cb.buildingName] = checked;
							NS.UpdateAll( "forceUpdate" );
						end,
					} );
				end
				NS.CheckButton( "GCacheCheckButton", SubFrame, L["|TInterface\\ICONS\\inv_garrison_resource:16|t Garrison Cache"], {
					setPoint = { "TOPLEFT", "$parentCharacterDropDownMenu", "TOPRIGHT", -2, -1 },
					OnClick = function( checked )
						NS.db["characters"][NS.selectedCharacterKey]["monitor"]["gCache"] = checked;
						NS.UpdateAll( "forceUpdate" );
					end,
				} );
				NS.Button( "DeleteCharacterButton", SubFrame, L["Delete Character"], {
					size = { 126, 22 },
					setPoint = { "BOTTOMRIGHT", "$parent", "BOTTOMRIGHT", -8, -14 },
					OnClick = function()
						StaticPopup_Show( "WOC_CHARACTER_DELETE", NS.db["characters"][NS.selectedCharacterKey]["name"], nil, { ["ck"] = NS.selectedCharacterKey, ["name"] = NS.db["characters"][NS.selectedCharacterKey]["name"] } );
					end,
				} );
				StaticPopupDialogs["WOC_CHARACTER_DELETE"] = {
					text = L["Delete character? %s"];
					button1 = YES,
					button2 = NO,
					OnAccept = function ( self, data )
						if data["ck"] == NS.currentCharacter.key then return end
						-- Delete
						table.remove( NS.db["characters"], data["ck"] );
						NS.Print( RED_FONT_COLOR_CODE .. string.format( L["%s deleted"], data["name"] ) .. FONT_COLOR_CODE_CLOSE );
						-- Reset keys (Exactly like initialize)
						NS.currentCharacter.key = NS.FindKeyByName( NS.db["characters"], NS.currentCharacter.name ); -- Must be reset when a character is deleted because the keys shift up one
						NS.selectedCharacterKey = NS.db["characters"][NS.currentCharacter.key]["gCacheSize"] > 0 and NS.currentCharacter.key or nil; -- Sets selected character to current character if they will be included on character dropdown
						-- Update and refresh
						NS.UpdateAll( "forceUpdate" );
						SubFrame:Refresh();
					end,
					OnCancel = function ( self ) end,
					OnShow = function ( self, data )
						if data["name"] == NS.currentCharacter.name then
							NS.Print( RED_FONT_COLOR_CODE .. L["You cannot delete the current character"] .. FONT_COLOR_CODE_CLOSE );
							self:Hide();
						end
					end,
					showAlert = 1,
					hideOnEscape = 1,
					timeout = 0,
					exclusive = 1,
					whileDead = 1,
				};
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				-- If current character has no Garrison Cache, select the first character that does
				if not NS.selectedCharacterKey then
					for ck,character in ipairs( NS.db["characters"] ) do
						if character["gCacheSize"] > 0 then
							NS.selectedCharacterKey = ck; -- First character key to have a Garrison Cache
							break; -- Stop looking
						end
					end
					-- NO CHARACTERS HAVE A GARRISON CACHE
					-- Print a message, go to Help tab, and stop right here
					if not NS.selectedCharacterKey then
						NS.Print( L["No characters found with at least a Garrison Cache"] );
						NS.options.MainFrame:ShowTab( 4 );
						return; -- Stop function
					end
				end
				--
				_G[sfn .. "CharacterDropDownMenu"]:Reset( NS.selectedCharacterKey );
				_G[sfn .. "GCacheCheckButton"]:SetChecked( NS.db["characters"][NS.selectedCharacterKey]["monitor"]["gCache"] );
				-- Initalize and show check buttons for the selected character's buildings
				-- Hide any of the 9 check buttons that are unused
				for i = 1, 9 do
					local cbn = sfn .. "BuildingCheckButton" .. i; -- Check Button Name
					if i <= #NS.db["characters"][NS.selectedCharacterKey]["buildings"] then
						local buildingName = NS.db["characters"][NS.selectedCharacterKey]["buildings"][i]["name"];
						_G[cbn]:SetChecked( NS.db["characters"][NS.selectedCharacterKey]["monitor"][buildingName] );
						_G[cbn .. "Text"]:SetText( "|T" .. NS.buildingInfo[buildingName].icon .. ":16|t " .. NS.FactionBuildingName( NS.db["characters"][NS.selectedCharacterKey]["faction"], buildingName ) );
						_G[cbn].buildingName = buildingName; -- Used in OnClick to set monitor boolean
						_G[cbn]:Show();
					else
						_G[cbn]:Hide();
					end
				end
			end,
		},
		{
			-- Options
			mainFrameTitle	= NS.title,
			tabText			= "Options",
			Init			= function( SubFrame )
				NS.TextFrame( "Alert", SubFrame, string.format( L["Alert - Turns time remaining %sred|r and makes the Minimap button blink"], RED_FONT_COLOR_CODE ), {
					size = { 500, 16 },
					setPoint = { "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
				} );
				NS.DropDownMenu( "AlertTypeDropDownMenu", SubFrame, {
					db = "alertType",
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", -12, -2 },
					buttons = {
						{ L["Disabled"], "disabled" },
						{ L["Next Out/Full"], "next" },
						{ L["All Out/Full"], "all" },
					},
					tooltip = string.format( L["%sDisabled:|r\nNo %sred|r time remaining,\nMinimap button won't blink\n\n%sNext Out/Full:|r\nOne or more building\nor cache is out/full\n\n%sAll Out/Full:|r\nAll buildings or all\ncaches are out/full"], HIGHLIGHT_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, HIGHLIGHT_FONT_COLOR_CODE, HIGHLIGHT_FONT_COLOR_CODE ),
					OnClick = function()
						NS.UpdateAll( "forceUpdate" );
					end,
					width = 90,
				} );
				NS.DropDownMenu( "AlertSecondsDropDownMenu", SubFrame, {
					db = "alertSeconds",
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -2 },
					buttons = {
						{ L["0 sec"], 0 },
						{ L["4 hr or less"], ( 4 * 3600 ) },
						{ L["8 hr or less"], ( 8 * 3600 ) },
						{ L["12 hr or less"], ( 12 * 3600 ) },
						{ L["16 hr or less"], ( 16 * 3600 ) },
						{ L["20 hr or less"], ( 20 * 3600 ) },
						{ L["1 day or less"], ( 24 * 3600 ) },
					},
					tooltip = L["Choose time remaining\nto start the Alert"],
					OnClick = function()
						NS.UpdateAll( "forceUpdate" );
					end,
					width = 90,
				} );
				NS.TextFrame( "MiscLabel", SubFrame, L["Miscellaneous"], {
					size = { 100, 16 },
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 12, -8 },
				} );
				NS.CheckButton( "showMinimapButtonCheckButton", SubFrame, L["Show Minimap Button"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 3, -1 },
					tooltip = L["Show or hide the\nbutton on the Minimap\n\n(Character Specific)"],
					OnClick = function( checked )
						NS.UpdateAll( "forceUpdate" );
						if not checked then
							WOCMinimapButton:Hide();
						else
							WOCMinimapButton:Show();
						end
					end,
					dbpc = "showMinimapButton",
				} );
				NS.CheckButton( "hideCharacterRealmsCheckButton", SubFrame, L["Hide Character Realms"], {
					setPoint = { "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -1 },
					tooltip = L["Removes realm after name"],
					db = "hideCharacterRealms",
				} );
			end,
			Refresh			= function( SubFrame )
				local sfn = SubFrame:GetName();
				_G[sfn .. "AlertTypeDropDownMenu"]:Reset( NS.db["alertType"] );
				_G[sfn .. "AlertSecondsDropDownMenu"]:Reset( NS.db["alertSeconds"] );
				_G[sfn .. "showMinimapButtonCheckButton"]:SetChecked( NS.dbpc["showMinimapButton"] );
				_G[sfn .. "hideCharacterRealmsCheckButton"]:SetChecked( NS.db["hideCharacterRealms"] );
			end,
		},
		{
			-- Help
			mainFrameTitle	= NS.title,
			tabText			= "Help",
			Init			= function( SubFrame )
				NS.TextFrame( "Description", SubFrame, string.format( L["%s version %s"], NS.title, NS.stringVersion ), {
					setPoint = {
						{ "TOPLEFT", "$parent", "TOPLEFT", 8, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontRedSmall",
				} );
				NS.TextFrame( "SlashCommandsHeader", SubFrame, string.format( L["%sSlash Commands|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "SlashCommands", SubFrame, string.format( L["%s/woc|r - Open and close this frame"], NORMAL_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "GettingStartedHeader", SubFrame, string.format( L["%sGetting Started|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "GettingStarted", SubFrame, string.format(
						L["%s1.|r Login to a character you want to monitor.\n" ..
						"%s2.|r Loot your Garrison Cache to provide a baseline time.\n" ..
						"%s3.|r Go to the Characters tab above and uncheck what you don't want to monitor.\n" ..
						"%s4.|r Repeat 1-3 for all characters you want included in this addon.\n" ..
						"%s5.|r Go to the Options tab above and select if/when you want to be alerted."],
						NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE, NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
				NS.TextFrame( "NeedMoreHelpHeader", SubFrame, string.format( L["%sNeed More Help?|r"], BATTLENET_FONT_COLOR_CODE ), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -18 },
						{ "RIGHT", 0 },
					},
					fontObject = "GameFontNormalLarge",
				} );
				NS.TextFrame( "NeedMoreHelp", SubFrame, string.format(
						L["%sQuestions, comments, and suggestions can be made on Curse.\nPlease submit bug reports on CurseForge.|r\n\n" ..
						"http://www.curse.com/addons/wow/work-orders-complete\n" ..
						"http://wow.curseforge.com/addons/work-orders-complete/tickets/"],
						NORMAL_FONT_COLOR_CODE
					), {
					setPoint = {
						{ "TOPLEFT", "#sibling", "BOTTOMLEFT", 0, -8 },
						{ "RIGHT", -8 },
					},
					fontObject = "GameFontHighlight",
				} );
			end,
			Refresh			= function( SubFrame ) return end,
		},
	},
};
