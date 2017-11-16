include("shared.lua")

function ENT:OnInitialize()
	self:SetRenderBoundsNumber(72)

	self.Created = CurTime()

	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.KnockedDown = self
		if not owner:CallMonsterFunction("KnockDownShouldDraw", self) then
			owner:SetNoDraw(true)
		end
		owner:SoftFreeze(true)

		owner:StatusWeaponHook3("PlayerKnockedDown", self, false, self:GetEndTime())
		owner:CallMonsterFunction("PlayerKnockedDown", self, false, self:GetEndTime())
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.KnockedDown = nil
		owner:SetNoDraw(false)
		owner:SoftFreeze(false)
	end
end

function ENT:Think()
	local ct = CurTime()
	local owner = self:GetOwner()
	if owner:IsValid() and 0 < owner:Health() then
		local wallfreeze = self:GetWallFreeze()
		if 0 < wallfreeze then
			if wallfreeze <= ct then
				self:SetWallFreeze(0)
			else
				owner:SetLocalVelocity(Vector(0, 0, 0))
			end
		end

		local rag = owner:GetRagdollEntity()
		if rag and rag:IsValid() then
			self:SetPos(rag:EyePos())

			rag:SetColor(owner:GetColor())
			rag:SetMaterial(owner:GetMaterial())

			if self:GetState() == 1 then
				local hitnormal = self.WallFreezeHitNormal
				if hitnormal then
					local hitpos = owner:GetPos() + hitnormal * -8
					local hitang = hitnormal:Angle()

					local up = hitang:Up()
					local right = hitang:Right()
					--local forward = hitang:Forward()

					local torsopos = hitpos + up * 48

					local ft = FrameTime()
					local timtoarriv = ft * 20

					local phys = rag:GetPhysicsObjectNum(1)
					if phys and phys:IsValid() then
						local ownerangles = Angle(hitang.pitch, hitang.yaw, hitang.roll)
						ownerangles:RotateAroundAxis(ownerangles:Right(), 90)
						ownerangles:RotateAroundAxis(ownerangles:Forward(), 270)
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = torsopos, angle = ownerangles, maxangular = 3000, maxangulardamp = 100, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
					end

					-- Right foot
					phys = rag:GetPhysicsObjectNum(14)
					if phys and phys:IsValid() then
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = hitpos + right * 24 + up * 8, angle = phys:GetAngle(), maxangular = 1000, maxangulardamp = 500, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
					end

					-- Left foot
					phys = rag:GetPhysicsObjectNum(13)
					if phys and phys:IsValid() then
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = hitpos + right * -24 + up * 8, angle = phys:GetAngle(), maxangular = 1000, maxangulardamp = 500, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
						--phys:SetPos(leftfootpos)
					end

					-- Head
					phys = rag:GetPhysicsObjectNum(10)
					if phys and phys:IsValid() then
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = hitpos + up * 58, angle = phys:GetAngle(), maxangular = 1000, maxangulardamp = 500, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
					end

					-- Right hand
					phys = rag:GetPhysicsObjectNum(7)
					if phys and phys:IsValid() then
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = torsopos + right * 35, angle = phys:GetAngle(), maxangular = 1000, maxangulardamp = 500, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
					end

					-- Left hand
					phys = rag:GetPhysicsObjectNum(5)
					if phys and phys:IsValid() then
						phys:Wake()
						phys:ComputeShadowControl({secondstoarrive = timtoarriv, pos = torsopos + right * -35, angle = phys:GetAngle(), maxangular = 1000, maxangulardamp = 500, maxspeed = 1000, maxspeeddamp = 500, dampfactor = 0.85, teleportdistance = 40, deltatime = ft})
					end

					self:NextThink(ct)
					return true
				end
			end

			local endtime = self:GetEndTime()
			if endtime - 0.65 <= ct then
				local playerpos = owner:GetPos()
				local delta = math.max(0.01, endtime - ct)
				for i = 0, rag:GetPhysicsObjectCount() do
					local translate = owner:TranslatePhysBoneToBone(i)
					if translate and 0 < translate then
						local pos, ang = owner:GetBonePosition(translate)
						if pos and ang then
							local phys = rag:GetPhysicsObjectNum(i)
							if phys and phys:IsValid() then
								phys:Wake()
								phys:ComputeShadowControl({secondstoarrive = math.max(delta, delta * pos:Distance(playerpos) * 0.1), pos = pos, angle = ang, maxangular = 1000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = ft})
							end
						end
					end
				end
			else
				local phys = rag:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:ComputeShadowControl({secondstoarrive = FrameTime() * 5, pos = owner:GetPos() + Vector(0, 0, 12), angle = rag:GetPhysicsObject():GetAngle(), maxangular = 2000, maxangulardamp = 10000, maxspeed = 5000, maxspeeddamp = 1000, dampfactor = 0.85, teleportdistance = 200, deltatime = ft})
				end
			end
		else
			self:SetPos(owner:EyePos())
		end
	end

	self:NextThink(ct)
	return true
end

function ENT:Draw()
end
