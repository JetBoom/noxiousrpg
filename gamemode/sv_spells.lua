--todo
local entity = FindMetaTable("Entity")
if not entity then return end

SpellChannel = (function()
  local meta = {}

  local function OnComplete(self)
    if not self:IsValid() then return end
    
    -- let the first caller (the timer) remove time cast time restrictions
    self.CastTime = 0

    if not self.CompletedFlag then return end

    self.Spell:OnCasted(self.Entity)
    self:__delete()
  end

  function meta:Bind(ent, spell)
    local new = setmetatable({}, meta)
    self.__index = self

    new.Entity = ent
    new.Spell = spell
    new.CastTime = os.clock() + spell.CastTime
    new.CompletedFlag = false

    -- note the cyclic reference
    ent.SpellChannel = new

    timer.Simple(spell.CastTime, function() OnComplete(new) end)

    -- ents will not hold channel time longer than necessary
    if not ent:IsPlayer() then new:Complete() end
  end

  --[[ __delete
       remove cyclic references ]]--
  function meta:__delete()
    assert(self:IsValid(), "Tried to delete an invalid casting bind")

    self.Entity.SpellChannel = nil
    self.Entity = nil
  end

  function meta:CanCompleteCast()
    return self.CastTime <= os.clock()
  end

  -- finish casting if possible, otherwise finish ASAP
  function meta:CompleteCast()
    self.CompletedFlag = true

    if self:CanCompleteCast() then
      OnComplete(self)
    end
  end

  -- cleanup, don't continue or complete casting
  function meta:Cancel()
    self:__delete()
  end

  function meta:IsValid()
    return self.Spell and self.Entity and self.Entity.SpellChannel == self and self.Entity:IsValid()
  end

  return meta
end)()

function entity:CastSpell(spell_name)
  if not spell_name then return end
  
  local spell = SPELLS[spell_name]
  if not spell then return end

  SpellChannel:Bind(self, spell)
  self.SpellChannel:CompleteCast()
end

function entity:StartCastSpell(spell_name)
  if not spell_name then return end
  
  local spell = SPELLS[spell_name]
  if not spell then return end

  SpellChannel:Bind(self, spell)
end

function entity:CompleteCastSpell()
  if not self.SpellChannel then return end
  self.SpellChannel:CompleteCast()
end

function entity:CancelCastSpell()
  if not self.SpellChannel then return end
  self.SpellChannel:Cancel()
end

-- Cast without chance to channel
concommand.Add("rpg_cast", function(sender, command, arguments)
  local spell_name = arguments[1]
  sender:CastSpell(spell_name)
end)

-- Player begins 'channeling' (holding) cast
concommand.Add("rpg_cast_start", function(sender, command, arguments)
  local spell_name = arguments[1]
  sender:StartCastSpell(spell_name)
end)

-- Player is no longer channeling spell
concommand.Add("rpg_cast_complete", function(sender, command, arguments)
  sender:CompleteCastSpell()
end)

-- Player has cancelled casting
concommand.Add("rpg_cast_cancel", function(sender, command, arguments)
  sender:CancelCastSpell()
end)