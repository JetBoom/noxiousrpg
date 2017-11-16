include("shared.lua")

local function refreshfootsteps(pl)
	if pl:IsValid() then
		pl:RefreshFootSteps()
	end
end

local function empty() end
function ENT:OnInitialize()
	if not self.Model then
		self:SetNoDraw(true)
		self.Draw = empty
	end
	if self.RenderBounds then
		self:SetRenderBoundsNumber(self.RenderBounds)
	end

	timer.Simple(0.5, function() refreshfootsteps(self:GetOwner()) end)
end

function ENT:OnRemove()
	timer.Simple(0.5, function() refreshfootsteps(self:GetOwner()) end)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local rag = owner:GetRagdollEntity()
	if rag then
		owner = rag
	elseif not owner:Alive() then return end

	local r,g,b,a = owner:GetColor()

	local pos, ang

	if self.BoneName then
		pos, ang = owner:GetBonePosition(owner:LookupBone(self.BoneName))
	elseif self.AnimAttachment then
		local posang = owner:GetAttachment(owner:LookupAttachment(self.AnimAttachment))
		if posang then
			pos, ang = posang.Pos, posang.Ang
		end
	end

	if pos then
		if self.Move then
			pos = pos + ang:Up() * self.Move.z + ang:Forward() * self.Move.x + ang:Right() * self.Move.y
		end
		self:SetPos(pos)
		if self.Rotate then
			ang:RotateAroundAxis(ang:Up(), self.Rotate.yaw)
			ang:RotateAroundAxis(ang:Right(), self.Rotate.pitch)
			ang:RotateAroundAxis(ang:Forward(), self.Rotate.roll)
		end
		self:SetAngles(ang)
	end

	self:SetColor(255, 255, 255, math.max(1, a))
	if self.ModelScale then
		self:SetModelScale(self.ModelScale, 0)
	end
	self:DrawModel()
end
