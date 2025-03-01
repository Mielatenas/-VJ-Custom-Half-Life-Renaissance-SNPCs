local meta = FindMetaTable("Angle")
/*
function meta:Normalize() -- Overrides the gmod angle normalizer do not use
	return Angle(math.NormalizeAngle(self.p), math.NormalizeAngle(self.y), math.NormalizeAngle(self.r))
end
*/
function meta:CustomHLRClamp() -- clamp on vectors, left here to see later
	while self.p < 0 do self.p = self.p +360 end
	while self.y < 0 do self.y = self.y +360 end
	while self.r < 0 do self.r = self.r +360 end
	
	while self.p > 360 do self.p = self.p -360 end
	while self.y > 360 do self.y = self.y -360 end
	while self.r > 360 do self.r = self.r -360 end
end

meta = FindMetaTable( "NPC" )
function meta:CustomHLRenaissanceGetCenter()
	return self:GetPos() +self:OBBCenter()
end

function meta:CustomHLRenaissanceGetHeadPos()
	local iBone
	local tblBones = {"Bip01 Head", "ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine4"}
	for k, v in pairs(tblBones) do
		local _iBone = self:LookupBone(v)
		if _iBone then iBone = _iBone; break end
	end
	if !iBone then return self:CustomHLRenaissanceGetCenter() end
	local pos, ang = self:GetBonePosition(iBone)
	return pos
end

meta = FindMetaTable("Entity")
function meta:GetConstrictedDirection(posStart, iLimitPitch, iLimitYaw, posEnd)
	posStart = posStart || self:GetPos()
	iLimitPitch = iLimitPitch || 45
	iLimitYaw = iLimitYaw || 45
	local angSelf = self:GetAngles()
	local ang = angSelf -(posEnd -posStart):Angle()
	while ang.p > 0 do ang.p = ang.p -360 end
	while ang.p < -360 do ang.p = ang.p +360 end
	while ang.y > 0 do ang.y = ang.y -360 end
	while ang.y < -360 do ang.y = ang.y +360 end
	local angEnd = (posEnd -posStart):Angle()
	if ang.p > -360 +iLimitPitch && ang.p < -90 then
		angEnd.p = angEnd.p +(ang.p -iLimitPitch)
	elseif ang.p < -iLimitPitch && ang.p >= -90 then
		angEnd.p = angEnd.p +(ang.p +iLimitPitch)
	end
	if ang.y < -iLimitYaw then
		if ang.y > -180 then
			angEnd.y = angEnd.y +(ang.y +iLimitYaw)
		elseif ang.y > -360 +iLimitYaw then
			angEnd.y = angEnd.y +(ang.y -iLimitYaw)
		end
	end
	return angEnd:Forward()
end

function meta:CustomHLRenaissanceGetAttPos(att) --unused
	if type(att) == "string" then
		att = self:LookupAttachment(att)
	end
	if !att || att <= 0 then return end
	return self:GetAttachment(att).Pos
end

function meta:CustomHLRenaissanceGetAttAng(att) --unused
	if type(att) == "string" then
		att = self:LookupAttachment(att)
	end
	if !att || att <= 0 then return end
	return self:GetAttachment(att).Ang
end

function meta:CustomHLRenaissanceGetPredictedPos(flDelay) --unused
	flDelay = flDelay || 1
	return self:GetPos() +self:GetVelocity() *flDelay
end

function meta:CustomHLRenaissanceDistance(TArg) -- unused
	local pos
	if type(TArg) == "Vector" then pos = TArg
	else pos = TArg:GetPos() end
	return self:GetPos():Distance(pos)
end

function meta:CustomHLRenaissanceOBBDistance(ent)
	local posTarget = ent:NearestPoint(self:GetPos() +ent:OBBCenter())
	local posSelf = self:NearestPoint(ent:GetPos() +self:OBBCenter())
	posTarget.z = ent:GetPos().z
	posSelf.z = self:GetPos().z
	return posSelf:Distance(posTarget)
end

function meta:CustomHLRenaissancePosInViewCone(pos, fDeg) --unused
	fDeg = fDeg || 45
	local i = 0
	local ang
	if self:IsPlayer() then ang = self:GetAimVector():Angle() end
	ang = self:GetAngleToPos(pos,ang)
	return (ang.p <= fDeg || ang.p >= 360 -fDeg) && (ang.y <= fDeg || ang.y >= 360 -fDeg)
end

function meta:CustomHLRenaissanceEntInViewCone(ent, fDeg)
	return self:CustomHLRenaissancePosInViewCone(ent:GetPos(), fDeg)
end
/*
local tblEntsNoCollide = {}
local tblEntsNoCollideByClass = {}
hook.Add("OnEntityCreated", "HLR_Collisions_EntCheckForClass", function(entA)
	timer.Simple(0, function()
		if IsValid(entA) then
			local sClass = entA.ClassName || entA:GetClass()
			for entB, tbl in pairs(tblEntsNoCollideByClass) do
				if IsValid(entB) then
					if tbl[sClass] then
						entB:NoCollide(entA)
					end
				else tblEntsNoCollideByClass[entB] = nil end
			end
		end
	end)
end)

if SERVER then
	hook.Add("PlayerInitialSpawn", "SLV_UpdateCollisions", function(ply)
		if !IsValid(ply) then return end
		timer.Simple(0.5, function() -- Let the entities initialize clientside
			if !IsValid(ply) then return end
			for entA, dat in pairs(tblEntsNoCollide) do
				if !IsValid(entA) then tblEntsNoCollide[entA] = nil
				else
					for entB, _ in pairs(dat) do if !IsValid(ent) then tblEntsNoCollide[entA][ent] = nil end end
				end
			end
			for ent, dat in pairs(tblEntsNoCollideByClass) do
				if !IsValid(ent) then tblEntsNoCollide[ent] = nil end
			end
			
			umsg.Start("SLV_UpdateCollisions", ply)
				umsg.Short(table.Count(tblEntsNoCollide))
				for entA, dat in pairs(tblEntsNoCollide) do
					umsg.Entity(entA)
					umsg.Short(table.Count(dat))
					for entB, _ in pairs(dat) do
						umsg.Entity(entB)
					end
				end
				umsg.Short(table.Count(tblEntsNoCollideByClass))
				for ent, dat in pairs(tblEntsNoCollideByClass) do
					umsg.Entity(ent)
					umsg.Short(table.Count(dat))
					for class, _ in pairs(dat) do
						umsg.String(class)
					end
				end
			umsg.End()
		end)
	end)
end

function meta:NoCollide(ent)
	tblEntsNoCollide[self] = tblEntsNoCollide[self] || {}
	if type(ent) != "string" then
		if tblEntsNoCollide[self][ent] then return end
		tblEntsNoCollide[self][ent] = true
		
		if CLIENT then return end
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		
		umsg.Start("HLR_EntsCollide", rp)
			umsg.Entity(self)
			umsg.Entity(ent)
			umsg.Bool(false)
		umsg.End()
		return
	end
	if tblEntsNoCollideByClass[self] && tblEntsNoCollideByClass[self][ent] then return end
	for _, ent in pairs(ents.FindByClass(ent)) do
		tblEntsNoCollide[self][ent] = true
	end
	for ent, _ in pairs(tblEntsNoCollide[self]) do if !IsValid(ent) then tblEntsNoCollide[self][ent] = nil end end
	if table.Count(tblEntsNoCollide[self]) == 0 then tblEntsNoCollide[self] = nil end
	tblEntsNoCollideByClass[self] = tblEntsNoCollideByClass[self] || {}
	tblEntsNoCollideByClass[self][ent] = true
	
	if CLIENT then return end
	umsg.Start("HLR_EntsCollideClass")
		umsg.Entity(self)
		umsg.String(ent)
		umsg.Bool(false)
	umsg.End()
end

function meta:Collide(ent)
	if type(ent) == "string" then
		if tblEntsNoCollide[self] then
			for _ent, _ in pairs(tblEntsNoCollide[self]) do
				if IsValid(_ent) && _ent:GetClass() == ent then
					tblEntsNoCollide[self][_ent] = nil
				end
			end
			for ent, _ in pairs(tblEntsNoCollide[self]) do if !IsValid(ent) then tblEntsNoCollide[self][ent] = nil end end
			if table.Count(tblEntsNoCollide[self]) == 0 then tblEntsNoCollide[self] = nil end
		end
		if tblEntsNoCollideByClass[self] then
			tblEntsNoCollideByClass[self][ent] = nil
			if table.Count(tblEntsNoCollideByClass[self]) == 0 then tblEntsNoCollideByClass[self] = nil end
		end
		if CLIENT then return end
		umsg.Start("HLR_EntsCollideClass")
			umsg.Entity(self)
			umsg.String(ent)
			umsg.Bool(true)
		umsg.End()
		return
	end
	if tblEntsNoCollide[self] then for ent, _ in pairs(tblEntsNoCollide[self]) do if !IsValid(ent) then tblEntsNoCollide[self][ent] = nil end end end
	if tblEntsNoCollide[self] && tblEntsNoCollide[self][ent] then
		tblEntsNoCollide[self][ent] = nil
		if SERVER then
			umsg.Start("HLR_EntsCollide")
				umsg.Entity(self)
				umsg.Entity(ent)
				umsg.Bool(true)
			umsg.End()
		end
		if table.Count(tblEntsNoCollide[self]) == 0 then tblEntsNoCollide[self] = nil end
	elseif tblEntsNoCollide[ent] && tblEntsNoCollide[ent][self] then
		tblEntsNoCollide[ent][self] = nil
		if SERVER then
			umsg.Start("HLR_EntsCollide")
				umsg.Entity(self)
				umsg.Entity(ent)
				umsg.Bool(true)
			umsg.End()
		end
		if table.Count(tblEntsNoCollide[ent]) == 0 then tblEntsNoCollide[ent] = nil end
	end
end

function meta:CanCollide(ent)
	return (!tblEntsNoCollide[self] || !tblEntsNoCollide[self][ent]) && (!tblEntsNoCollide[ent] || !tblEntsNoCollide[ent][self])
end
*/
function meta:CustomHLRenaissanceIsPhysicsEntity()
	if !self:IsNPC() && !self:IsPlayer() && !self:IsWorld() && IsValid(self:GetPhysicsObject()) then return true end
	return false
end
function meta:CustomHLRenaissanceGetAngleToPos(pos, _ang, bDontClamp)
	local _pos
	if self:IsPlayer() then
		_pos = self:GetShootPos()
		if !_ang then
			_ang = self:GetAimVector():Angle()
		end
	else
		_ang = _ang || self:GetAngles()
		_pos = self:GetPos()
	end
	local ang = _ang -(pos -_pos):Angle()
	if !bDontClamp then ang:CustomHLRClamp() end
	return ang
end

meta = FindMetaTable("Player")
function meta:CustomHLRenaissanceGetHeadPos()
	local pos = self:GetPos()
	if !self:Crouching() then
		pos.z = pos.z +self:OBBMaxs().z -15
	else
		pos.z = pos.z +self:OBBMaxs().z -20
	end
	return pos
end
