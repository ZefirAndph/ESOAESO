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


EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_ADD_ON_LOADED, EAT.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, EAT.ShowUIChange)

---- TEST ZONE --- 
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
	

SLASH_COMMANDS['/eatdrain'] = EAT.DrainNODES

SLASH_COMMANDS['/eatloadhouses'] = EAT.GetKnownHomes
