AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetTrigger(true)

	self:PhysicsInitBox(self.CollisionBoundsMin, self.CollisionBoundsMax)
	self:SetCollisionBounds(self.CollisionBoundsMin, self.CollisionBoundsMax)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions(false)
		phys:EnableMotion(false)
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	--self:SetNotSolid(true)
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:IsGhost() then
		if ent:IsCriminal() and not self:IsChaos() then
			ent:SendMessage("The gate appears to not respond to your defiled soul.~sweapons/physcannon/energy_sing_flyby2.wav", "COLOR_RED")
		else
			local effectdata = EffectData()
				effectdata:SetEntity(ent)
				effectdata:SetOrigin(ent:EyePos())
			util.Effect("resurrection", effectdata)

			ent:Respawn()
		end
	end
end

function ENT:OnSave(tab)
	tab.Chaos = self:IsChaos()
end

function ENT:OnLoaded(tab)
	if tab.Chaos ~= nil then
		self:SetChaos(tab.Chaos)
	end
end
