Config = {}

Config.EnableOffsets = false --If enabled you can play around with the offsets to see what offset values you might need for attaching objects to bones or something


local ShowPlayerBones = false
local ShowClosestPedBones = false

--I used the URL below to add the most common bones found on almost all peds. You can always add more.

boneIndex = { --- https://github.com/femga/rdr3_discoveries/blob/master/boneNames/player_zero__boneNames.lua
[21030] = {index = "skel_head", visible = true},
[55120] = {index = "skel_l_calf", visible = true},
[43312] = {index = "skel_r_calf", visible = true},
[14283] = {index = "skel_neck0", visible = true},
[14284] = {index = "skel_neck1", visible = true},
[14285] = {index = "SKEL_Neck2", visible = true},
[30226] = {index = "skel_l_clavicle", visible = true},
[45454] = {index = "skel_l_foot", visible = true},
[33646] = {index = "skel_r_foot", visible = true},
[53675] = {index = "skel_l_forearm", visible = true},
[54187] = {index = "skel_r_forearm", visible = true},
[34606] = {index = "skel_l_hand", visible = true},
[22798] = {index = "skel_r_hand", visible = true},
[65478] = {index = "skel_l_thigh", visible = true},
[6884] =  {index = "skel_r_thigh", visible = true},
[37873] = {index = "skel_l_upperarm", visible = true},
[56200] = {index = "skel_pelvis", visible = true},
[14410] = {index = "skel_spine0", visible = true},
}



RegisterCommand("bones", function(source, args, rawCommand) --  COMMAND

WarMenu.OpenMenu('id_bones')

end)

--Getting NPC/Other Player bones
Citizen.CreateThread(function()
	while true do
		Wait(2)		
		if ShowClosestPedBones then	
			local closestPed = GetClosestPed(PlayerPedId(),10.0)
			local x_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local y_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local z_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local heading = GetEntityHeading(closestPed)
			for k, v in pairs(boneIndex) do
			if v.visible then
				local boneCoords = GetWorldPositionOfEntityBone(closestPed,GetPedBoneIndex(closestPed, k))
				local offset = GetObjectOffsetFromCoords(boneCoords.x, boneCoords.y, boneCoords.z, heading,0.0,0.15,0.0)
					Draw3DText(boneCoords.x,boneCoords.y,boneCoords.z,v.index,0.2)
					if Config.EnableOffsets then
						Draw3DText(offset.x,offset.y,offset.z,"offset: "..v.index,0.2)		
					end
				end	
			end	
		end		
	end
end)


Citizen.CreateThread(function()
	WarMenu.CreateMenu("id_bones", "Bone Dev")
	WarMenu.CreateSubMenu('PlayerBones',"id_bones" ,"Toggle Player Ped Bones")
	WarMenu.CreateSubMenu('ClosestBones',"id_bones" ,"Toggle Closest Ped Bones")
	WarMenu.CreateSubMenu('PedBones',"id_bones" ,"Ped Bones")
	WarMenu.SetMenuWidth('id_bones', 0.24)

	WarMenu.SetMenuMaxOptionCountOnScreen('PedBones', 10)
	--WarMenu.SetMenuY('PedBones', 20)
	repeat
		if WarMenu.IsMenuOpened('id_bones') then
			WarMenu.Display()			
			if WarMenu.MenuButton('Ped Bones', "PedBones") then	
			elseif WarMenu.Button('[Player Ped Bones]: '..tostring(ShowPlayerBones)) then
			ShowPlayerBones = not ShowPlayerBones
			elseif WarMenu.Button('[Closest Ped Bones]: '..tostring(ShowClosestPedBones)) then
			ShowClosestPedBones = not ShowClosestPedBones
			end
		elseif WarMenu.IsMenuOpened('PedBones') then 
		WarMenu.Display()
				if WarMenu.Button('Enable All') then		
					for k,v in pairs(boneIndex) do
							v.visible = true
					end
				end				
				if WarMenu.Button('Disable All') then		
					for k,v in pairs(boneIndex) do
							v.visible = false
					end
				end
				for k,v in pairs(boneIndex) do
						if WarMenu.Button("["..v.index.."]: ".. tostring(v.visible)) then
							v.visible = not v.visible
							--WarMenu.CloseMenu()
						end
				end
		end
		Citizen.Wait(0)
	until false
end)

--Getting PlayerPed bones
Citizen.CreateThread(function()
	while true do
		Wait(2)
		if ShowPlayerBones then
			local ped = PlayerPedId()
			local x_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local y_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local z_offset = 0.2 -- Config.EnableOffsets needs to be enabled before messing with these
			local heading = GetEntityHeading(ped)
			for k, v in pairs(boneIndex) do
			if v.visible then
				local boneCoords = GetWorldPositionOfEntityBone(ped,GetPedBoneIndex(ped, k))
				local offset = GetObjectOffsetFromCoords(boneCoords.x, boneCoords.y, boneCoords.z, heading,0.0,0.15,0.0)
					Draw3DText(boneCoords.x,boneCoords.y,boneCoords.z,v.index,0.2)
					if Config.EnableOffsets then
						Draw3DText(offset.x,offset.y,offset.z,"offset: "..v.index,0.2)		
					end
				end	
			end		
		end
	end
end)


function Draw3DText(x, y, z, text, size)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    
    SetTextScale(size, size)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 150
    --DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end



function GetClosestPed(playerPed, radius)
	local playerCoords = GetEntityCoords(playerPed)

	local itemset = CreateItemset(true)
	local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, radius, itemset, 1, Citizen.ResultAsInteger())

	local closestPed
	local minDist = radius

	if size > 0 then
		for i = 0, size - 1 do
			local ped = GetIndexedItemInItemset(i, itemset)
			if playerPed ~= ped then  	
					local pedCoords = GetEntityCoords(ped)
					local distance = #(playerCoords - pedCoords)
					if distance < minDist then
						closestPed = ped
						minDist = distance
					end
			end
		end
	end

	if IsItemsetValid(itemset) then
		DestroyItemset(itemset)
	end

	return closestPed
end