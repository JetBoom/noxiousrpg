AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.m_NextTick = 0
function ENT:Think()
	if CurTime() >= self.m_NextTick then
		self.m_NextTick = CurTime() + 1
		self:Tick()
	end
end

function ENT:Tick()
	if self:IsDrowning() then
		self:GetOwner():TakeSpecialDamage(3, DMG_DROWN, GetWorldEntity(), self)
	end
end
