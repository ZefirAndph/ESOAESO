EAT = {}
EAT.name = "EarthSea Order Housing"
EAT.debugstate = false
EAT.UISTATE = false

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
	--	local ctrl = GetControl("EATPorter")
	--	LINKHOUSE[itr].btn = WINDOW_MANAGER:CreateControl(name, EATMAIN, CT_BUTTON)
	--
	--	LINKHOUSE[itr].btn:SetEdgeColor(0.4,0.4,0.4)
	--	LINKHOUSE[itr].btn:SetCenterColor(0.1,0.1,0.1)
	--	LINKHOUSE[itr].btn:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
	--	LINKHOUSE[itr].btn:SetDimensions(450,600)
	--	LINKHOUSE[itr].btn:SetAlpha(1)
	--	LINKHOUSE[itr].btn:SetDrawLayer(0)
	--	local control = GetControl("EATPorter"):CreateControl(name, CL_BUTTON)
	--	control.SetAnchor(TOPRIGHT, GetControl("EATPorter"), TOPLEFT, HELP_ICON_SIZE, 0)
  	--	dd(LINKHOUSE[itr].name)
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



EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_ADD_ON_LOADED, EAT.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(EAT.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, EAT.ShowUIChange)