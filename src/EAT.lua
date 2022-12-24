EAT = {}
EAT.name = "EarthSea Order Housing"
EAT.debugstate = false
EAT.UISTATE = false

function EAT.ltrim(s)
	return s:match'^%s*(.*)'
end

function EAT.Split(str, sep) 
	local result = {} 
	local regex = ("([^%s]+)"):format(sep) 
	for each in str:gmatch(regex) do 
		table.insert(result, each) 
	end	
	return result 
end

function EAT.LoadHouses() 
	local retv = {}
	for i=1,GetNumGuildMembers(736992),1 do 
		local name, note, rank, status, off = GetGuildMemberInfo(736992,i) 
		if note == "" then note = nil end 
		if note then retv[#retv+1] = {pl=name, houses=note} end
	end
	return retv
end

function EAT.TranslateHouse(nstr) local lines = EAT.Split(nstr, "\n") local retv = {} for i=1,#lines,1 do local pars = EAT.Split(lines[i], ":") retv[#retv+1] = {showname=pars[1], housename=EAT.ltrim(pars[2])} end return retv end

function EAT.SearchID(name)
	for key,value in pairs(HOUSES) do 
		if HOUSES[key] == name then return key end
	end
	return nil
end

function EAT.GetKnownHomes()
	local retv = {}
	local hses = EAT.LoadHouses() 
	for i=1,#hses,1 do 
		local homes = EAT.TranslateHouse(hses[i].houses)
		for o=1,#homes,1 do
			retv[#retv+1] = {owner=hses[i].pl, name=homes[o].showname, houseid=EAT.SearchID(homes[o].housename)}
		end
	end
	return retv
end


--- OLD ADDON BEGIN ---
function dd(msg)
	if EAT.debugstate == true then
		d(msg)
	end
end
function EAT:OnClicked(control)
	dd("EAT:OnClicked - ")
	dd(control.name)
	if GetDisplayName() == control.owner then
		RequestJumpToHouse(control.houseid)
	else
		JumpToSpecificHouse(control.owner, control.houseid)
	end
end

function EAT:OnMouseEnter(control)
	dd("EAT:OnMouseEnter: ")
	dd(control.name)
	dd(control.text)
    InitializeTooltip(InformationTooltip, control, TOP, 0, 0)
    SetTooltipText(InformationTooltip, control.tooltiptext)
end

function EAT:OnMouseExit(control)
	dd("EAT:OnMouseExit: ")
	dd(control.name)
    ClearTooltip(InformationTooltip)
end

function EAT.VyrobCudle()
	dd("EAT.VyrobCudle")
	local ctrl = GetControl("EATPorter")
	for itr = 1, #LINKHOUSE do
		local name = "EAT_HOUSE_" .. itr
		dd("Know: " .. name)
		local btn = ctrl:GetNamedChild(name)
		btn.name = LINKHOUSE[itr].name
		btn.owner = LINKHOUSE[itr].owner
		btn.houseid = LINKHOUSE[itr].houseid
		btn.tooltiptext = LINKHOUSE[itr].name
	end

end

function EAT.ShowUIChange(code)
	dd("EAT.ShowUIChange")

	if EAT.UISTATE == false then
		EAT.VyrobCudle()
		EAT.UISTATE = true
	end

	if IsGameCameraUIModeActive() then
        -- UI mode
		EATPorter:SetHidden(false)
		dd("CHECK OPEN")
    else
        -- Not UI mode
		EATPorter:SetHidden(true)
		dd("CHECK CLOSE")
    end
end

function EAT.Initialize()
	dd("EAT.Initialize")
	EATPorter:SetHidden(true)
	EAT.VyrobCudle()
end

function EAT.OnAddOnLoaded(event, addonName)
	if addonName == EAT.name then
		dd("EAT.OnAddOnLoaded")
		EAT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(EAT.name, EVENT_ADD_ON_LOADED)
	end
end
function EAT.AddButton(title, owner, houseId)
	d("Adding button: " ..title.." as "..owner.."&"..houseId)
	local ctrl = GetControl("EATPorter")
	ctrl:AddChild(atNode, nbtn, childIndent)
end
function EAT.UPDATE()
	-- clear button then add new 
	local data = EAT.GetKnownHomes()
	for i=1,#data,1 do 
		EAT.AddButton(data[i].name, data[i].owner, data[i].houseid)
	end
end



function EAT.RollDice(args)
	if args == "" then args = 20 end
	local value = math.max(1, math.floor((math.random()*args)+0.5))
	d(zo_strformat("|H0:EAT:Roll:<<1>>:<<2>>:<<3>>|h[Rolled d<<1>> with result <<2>>]|h", args, value, GetTimeStamp()))
	--return value;
end
-- /script function EAT.RollDice(args)	local value = math.max(1, math.floor((math.random()*args)+0.5)) return value end

----- TEST ENVIRONMENT -----
function EAT.DrainNODES()
	EAT.Data = ZO_SavedVars:NewAccountWide("EATNodesData", nil, nil, nil)
	local totalNodes = GetNumFastTravelNodes()
	d("TotalNodes: "..totalNodes)
	local i = 1
	while i <= totalNodes do
		EATData = GetFastTravelNodeInfo(i)
		i = i + 1
	end

end

----- HANDLE EAT LINKS -----
function EAT.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, ...)
	if linkType == "EAT" then
		if mouseButton == 2 then
			CHAT_SYSTEM.textEntry:InsertLink(rawLink)
			return true
		else
			local subType = ...
			if subType == "Roll" then
				local _, dice, val, time = ...
				-- Handle for foll links
				if tonumber(time) < (GetTimeStamp()) then
					d("Roll Verified!")
				else
					d("Cannot verify this roll!")
				end
				return true
			end
			if subType == "JumpToHouse" then
				-- jump links
				local _, owner, hid = ...
				d("Teleport do domu: |cffff00"..rawLink.."|r")

				if GetDisplayName() == owner then
					RequestJumpToHouse(hid)
				else
					JumpToSpecificHouse(owner, hid)
				end
				return true
			end

			d("Nelze rozeznat odkaz EAT. Zkuste EAT aktualizovat.")
			return true
		end
	end
end
  
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, EAT.HandleClickEvent) --as for Update 4 default ingame GUI uses this event
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, EAT.HandleClickEvent)  --this event still can be used, so the best practise is registering both events

EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_ADD_ON_LOADED, EAT.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, EAT.ShowUIChange)

----- CHAT COMMANDS -----
SLASH_COMMANDS['/eatupdate'] = EAT.UPDATE -- Update House porting buttons

SLASH_COMMANDS['/eatdrain'] = EAT.DrainNODES -- test loading Travel Nodes

if nil == SLASH_COMMANDS[ "/roll" ] then 
	SLASH_COMMANDS[ "/roll" ] = function( args ) EAT.RollDice( args ) end
elseif nil == SLASH_COMMANDS[ "/eroll" ] then
	SLASH_COMMANDS[ "/eroll" ] = function( args ) EAT.RollDice( args ) end
else
	SLASH_COMMANDS[ "/eatroll" ] = function( args ) EAT.RollDice( args ) end
end


