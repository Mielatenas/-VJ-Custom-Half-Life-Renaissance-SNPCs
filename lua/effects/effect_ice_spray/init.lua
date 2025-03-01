function EFFECT:Init(data)
	local pos = data:GetStart()
	local posStart = self:GetTracerShootPos(pos,data:GetEntity(),data:GetAttachment())
	local ang = data:GetNormal()
	
	local emitter = ParticleEmitter(posStart)
			local particle = emitter:Add("particle/particle_icespray",posStart)
			
			particle:SetVelocity(ang *1000)
			particle:SetDieTime(0.4)
			particle:SetStartAlpha(math.random(100,200))
			particle:SetStartSize(math.random(1,5))
			particle:SetEndSize(math.random(100.0,160.0))
			particle:SetRoll(math.random(0,360))
			particle:SetRollDelta(math.random(-1.00,1.00))
			particle:SetColor(255,255,255)
			particle:SetAirResistance(0.1)
			particle:SetCollide(true)
			//particle:SetCollideCallback(function(part,pos,ang) if (math.random(0,4) == 4) then util.Decal("FireExt",pos + ang,pos - ang) end part:SetDieTime(0) end)
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end