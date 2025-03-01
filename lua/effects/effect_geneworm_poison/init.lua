function EFFECT:Init(data)
	local pos = data:GetStart()
	local posStart = self:GetTracerShootPos(pos,data:GetEntity(),data:GetAttachment())
	local ang = data:GetNormal()
	
	local emitter = ParticleEmitter(posStart)
			local particle = emitter:Add("particle/particle_spray",posStart)
			particle:SetVelocity(ang *1500)
			particle:SetDieTime(0.4)
			particle:SetStartAlpha(math.random(100,200))
			particle:SetStartSize(math.random(2,6))
			particle:SetEndSize(math.random(200.0,260.0))
			particle:SetRoll(math.random(0,360))
			particle:SetRollDelta(math.random(-1.00,1.00))
			particle:SetColor(0,255,0)
			particle:VelocityDecay(false)
			particle:SetCollide(true)
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end