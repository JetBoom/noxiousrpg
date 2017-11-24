stat = {}

local VALUE = 0
local VALMUL = 1

function stat.Start(val)
	VALUE = val or 0
	VALMUL = 1
end

function stat.SetValue(val)
	VALUE = val
end
stat.Set = stat.SetValue

function stat.SetMul(mul)
	VALMUL = mul
end

function stat.Add(amount)
	VALUE = VALUE + amount
end

function stat.Sub(amount)
	stat.Add(-amount)
end

function stat.Mul(mul)
	VALUE = VALUE * mul
end

function stat.Div(div)
	VALUE = VALUE / div
end

function stat.AddMul(amount)
	VALMUL = VALMUL + amount
end

function stat.AddMulPercent(percent)
	VALMUL = VALMUL + percent / 100
end

function stat.SubMul(amount)
	stat.AddMul(-amount)
end

function stat.SubMulPercent(percent)
	stat.AddMulPercent(-percent)
end

function stat.Get()
	return VALUE * VALMUL
end
