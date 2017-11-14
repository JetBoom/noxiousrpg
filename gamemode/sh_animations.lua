function GM:CalcMainActivity(ply, velocity)
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	if not (ply:CallMonsterFunction("CalcMainActivity", velocity) or self:HandlePlayerDriving( ply ) or self:HandlePlayerJumping( ply, velocity ) or self:HandlePlayerDucking( ply, velocity ) or self:HandlePlayerSwimming( ply )) then
		local len2d = velocity:Length2D()

		if len2d > 165 then
			ply.CalcIdeal = ACT_MP_RUN
		elseif len2d > 0.5 then
			ply.CalcIdeal = ACT_MP_WALK
		end
	end
	
	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	if pl:CallMonsterFunction("UpdateAnimation", velocity, maxseqgroundspeed) then return end

	if pl:IsGhost() then
		pl:SetPoseParameter("breathing", 0)
	else
		pl:SetPoseParameter("breathing", 2 - pl:Health() / pl:GetMaxHealth())
	end

	local len2d = velocity:Length2D()
	if len2d > 0.5 then
		pl:SetPlaybackRate(math.min(len2d / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end
end

function GM:DoAnimationEvent(pl, event, data)
	return pl:CallMonsterFunction("DoAnimationEvent", event, data) or self.BaseClass:DoAnimationEvent(pl, event, data)
end
