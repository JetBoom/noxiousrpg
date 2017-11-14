AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:EmitSound(self.StartSound)

	--[[if not bExists and self.StartThoughtText then
		pPlayer:Thought(self.StartThoughtText)
	end]]
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		if not self.SilentRemove then
			parent:EmitSound(self.EndSound)
		end
		--[[if self.EndThoughtText then
			parent:Thought(self.EndThoughtText)
		end]]
	end
end
