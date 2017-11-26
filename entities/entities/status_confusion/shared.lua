DEFINE_BASECLASS("status__base")

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

util.PrecacheSound("nox/stunon.wav")
util.PrecacheSound("nox/stunoff.wav")

function ENT:Initialize()
	BaseClass.Initialize(self)

	hook.Add("Move", self, self.Move)
end

function ENT:Move(pl, move)
	if pl == self:GetOwner() then
		move:SetSideSpeed(move:GetSideSpeed() * -1)
		move:SetForwardSpeed(move:GetForwardSpeed() * -1)
	end
end
