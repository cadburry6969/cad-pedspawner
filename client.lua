local function loadModel(model)
	local _model = joaat(model)
	if HasModelLoaded(_model) then
		return _model
	end
	RequestModel(_model)
	while not HasModelLoaded(_model) do
		Wait(50)
	end
	return _model
end

local function loadAnim(dict)
	if HasAnimDictLoaded(dict) then
		return dict
	end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(50)
	end
	return dict
end

local function spawnPed(name)
	local Ped = PedList[name]
	local _model = loadModel(Ped.model)
	local coords = Ped.coords
	local _ped = CreatePed(PedTypes[Ped.type], _model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
	PedList[name].ped = _ped

	SetEntityAlpha(_ped, 0, false)
	FreezeEntityPosition(_ped, Ped.states?.freeze or false)
	SetEntityInvincible(_ped, Ped.states?.invincible or false)
	SetBlockingOfNonTemporaryEvents(_ped, Ped.states?.blockevents or false)

	if Ped.animation then
		local dict = Ped.animation?.dict
    	local anim = Ped.animation?.anim
		if dict and anim then
			loadAnim(dict)
			TaskPlayAnim(_ped, dict, anim, 8.0, 0, -1, Ped.animation?.flag or 1, 0, false, false, false)
			if Ped.animation?.duration and Ped.animation?.duration > 0 then
				SetTimeout(Ped.animation.duration, function() StopAnimTask(_ped, dict, anim, 1.0) end)
			end
		end

		if Ped.animation.scenario then
			TaskStartScenarioInPlace(_ped, Ped.animation.scenario, 0, true)
		end
	end

	if Ped.prop then
		local _prop = Ped.prop
		local model = joaat(_prop.model)
		loadModel(model)
		local entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
		PedList[name].prop.entity = entity

		AttachEntityToEntity(
			entity,
			_ped,
			GetPedBoneIndex(_ped, _prop.bone),
			_prop.rotation.x,
			_prop.rotation.y,
			_prop.rotation.z,
			_prop.offset.x,
			_prop.offset.y,
			_prop.offset.z,
			true, true, false, true, 0, true
		)
	end

	if Ped.target then
		local optionNames = {}
		for i in pairs(Ped.target) do
			local _name = name..i
			Ped.target[i].name = _name
			optionNames[i] = _name
		end
		PedList[name].targetNames = optionNames
		exports.target:addLocalEntity(_ped, Ped.target)
	end

	if Ped.onSpawn then
		Ped:onSpawn()
	end

    for alpha = 0, 255, 51 do
        Wait(50)
        SetEntityAlpha(_ped, alpha, false)
    end
end

local function removePed(name)
	local Ped = PedList[name]
	local _ped = PedList[name].ped

	if Ped.prop?.entity then
		DeleteEntity(Ped.prop.entity)
		Ped.prop.entity = nil
	end

	if Ped.target and Ped.targetNames then
		exports.target:removeLocalEntity(_ped, Ped.targetNames)
		PedList[name].targetNames = nil
	end

	if Ped.onDespawn then
		Ped:onDespawn()
	end

	for alpha = 255, 0, -51 do
		Wait(50)
		SetEntityAlpha(_ped, alpha, false)
	end
	DeleteEntity(_ped)

	PedList[name].ped = nil
end

CreateThread(function()
	for _, data in pairs(PedList) do
		if data.interaction then
			local point = lib.points.new({
				coords = data.coords.xyz,
				distance = data.interaction?.distance or 2.0,
				label = data.interaction?.label or 'Interact',
				key = data.interaction?.key or 38,
				onPressed = data.interaction?.onPressed
			})

			function point:onEnter()
				lib.showTextUI(self.label)
			end

			function point:onExit()
				lib.hideTextUI()
			end

			function point:nearby()
				if self.currentDistance < self.distance and IsControlJustPressed(0, self.key) then
					self:onPressed()
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1000)
		local playerCoords = GetEntityCoords(PlayerPedId())
		for name, data in pairs(PedList) do
			local pdist = #(playerCoords - data.coords.xyz)
			local rdist = data.distance or 15.0

			if pdist < rdist then
				if not data.ped then spawnPed(name) end
			else
				if data.ped then removePed(name) end
			end
		end
	end
end)

---@class PedData
---@field model string 'ig_barry'
---@field coords vector4 vec4(0, 0, 0, 0)
---@field type string 'male' | 'female'
---@field distance? number render distance
---@field states? table { freeze: boolean, blockevents: boolean, invincible: boolean }
---@field animation? table { dict: string, anim: string, flag: number, scenario: string }
---@field prop? table { model: string, bone: number, rotation: vec3(0, 0, 0), offset: vec3(0, 0, 0) }
---@field textUI? table { label: string, distance: number, key: number, onPressed: fun() }
---@field target? table target options
---@field onSpawn? fun(self: table) callback function which triggers on ped spawn
---@field onDespawn? fun(self: table) callback function which triggers when ped despawns
---@param name string
---@param data PedData
function AddPed(name, data)
    PedList[name] = data
end
exports("AddPed", AddPed)

---@param name string ped index name
function DeletePed(name)
    if PedList[name] then
        PedList[name] = nil
    end
end
exports("DeletePed", DeletePed)