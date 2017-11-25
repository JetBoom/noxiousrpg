AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.KnockedDown = self

	self.PrevOnGround = true

	if self.OldDieTime then
		self.DieTime = math.max(self.DieTime, self.OldDieTime)
	end
	self.OldDieTime = self.DieTime

	self.LastThink = CurTime()

	if bExists then
		self.AppliedWallDamage = nil
		self:SetState(0)
	else
		pPlayer:SoftFreeze(true)
		pPlayer:ResetJumpPower()

		if 1 <= pPlayer:Health() and pPlayer:Alive() and not pPlayer:CallMonsterFunction("HandleKnockDownRagdoll", self) then
			--if pPlayer:IsMonster() then
				pPlayer:CreateRagdoll()
			--end
		end

		self.Created = CurTime()
	end

	self:SetEndTime(self.DieTime)

	pPlayer:StatusWeaponHook3("PlayerKnockedDown", self, bExists, self:GetEndTime())
	pPlayer:CallMonsterFunction("PlayerKnockedDown", self, bExists, self:GetEndTime())
end

function ENT:Think()
	local ct = CurTime()
	local delta = ct - self.LastThink
	self.LastThink = ct

	local owner = self:GetOwner()

	local wallfreeze = self:GetWallFreeze()
	if 0 < wallfreeze then
		if wallfreeze <= ct then
			self:SetWallFreeze(0)
		else
			owner:SetLocalVelocity(Vector(0, 0, 0))
		end
	end

	if not self.GettingUp and owner:KeyDown(IN_JUMP) and (not self.AppliedWallDamage or owner:IsSubmerged()) and gamemode.Call("PlayerCanGetUp", owner) then
		DEBUG(tostring(owner).." getting up.")
		self.GettingUp = true
		self:SetEndTime(ct + 0.35)
		owner:EmitSound("physics/nearmiss/whoosh_huge2.wav", 75, math.Rand(235, 255))
	end

	if self.AppliedWallDamage then
		if owner:IsOnGround() then
			self:SetState(0)
			self:SetEndTime(ct + 1)
			self.AppliedWallDamage = false
			self.GettingUp = true
		end
	elseif not self.GettingUp or ct + 0.2 <= self.DieTime then
		local heading = owner:GetVelocity()
		local speed = heading:Length()
		if FORCE_KNOCKDOWN_NOGETUP <= speed then
			heading:Normalize()
			local startpos = owner:GetPos()
			local tr = util.TraceHull({start = startpos, endpos = startpos + speed * FrameTime() * 2 * heading, mask = MASK_PLAYERSOLID, filter = owner, mins = owner:OBBMins(), maxs = owner:OBBMaxs()})
			if tr.Hit and tr.HitNormal.z < 0.65 and 0 < tr.HitNormal:Length() and not (tr.Entity:IsValid() and tr.Entity:IsPlayer()) and not owner:CallMonsterFunction("KnockDownWallSlam", self, tr) then
				self.AppliedWallDamage = true
				self:SetState(1)
				self:SetEndTime(ct + 9999)
				self:SetWallFreeze(ct + 0.5)

				local eyeangs = owner:EyeAngles()
				owner:SetEyeAngles(Angle(eyeangs.pitch, tr.HitNormal:Angle().yaw, eyeangs.roll))

				local effectdata = EffectData()
					effectdata:SetNormal(tr.HitNormal)
					effectdata:SetEntity(owner)
					effectdata:SetOrigin(tr.HitPos)
				util.Effect("wallslam", effectdata)

				owner:SetLocalVelocity(Vector(0, 0, 0))
				util.ScreenShake(tr.HitPos, 20, 0.5, 1, 128)

				owner:TakeSpecialDamage(math.Clamp(speed * 0.025, 5, 30), DGMTYPE_IMPACT, owner:GetLastAttacker() or self, self, tr.HitPos)

				owner:CallMonsterFunction("OnKnockDownWallSlam", self, tr)
			end
		end
	end

	if self.DieTime <= ct then
		self:Remove()
	else
		--[[if owner:IsOnGround() and owner:GetVelocity():Length() < 400 then
			if not self.PrevOnGround then
				self.PrevOnGround = true
				owner:StopLuaAnimation("thrown")
				owner:SetLuaAnimation("onground")
			end
		elseif self.PrevOnGround then
			self.PrevOnGround = false
			owner:StopLuaAnimation("onground")
			owner:SetLuaAnimation("thrown")
		end]]

		self:NextThink(ct)
		return true
	end
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		--[[parent:StopLuaAnimation("onground")
		parent:StopLuaAnimation("thrown")]]

		--if parent:IsMonster() then
			parent:SetNoDraw(false)
		--end
		parent.KnockedDown = nil
		parent:SoftFreeze(false)
		parent:ResetJumpPower()

		parent:CallMonsterFunction("EndKnockDown", self)

		if parent:Alive() then
			if self.ResetViewModel then
				parent:DrawViewModel(true)
			end

			if self.ResetWorldModel then
				parent:DrawWorldModel(true)
			end

			local rag = parent:GetRagdollEntity()
			if rag and rag:IsValid() then
				rag:Remove()
			end
		end
	end
end
