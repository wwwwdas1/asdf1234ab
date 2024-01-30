return function (self,state) 
---@type MobTemplate
local template = self.Template
if (template == nil) then
	-- not initialized yet
	--log("Not initialized yet")
	return
end
local left = self:IsFacingLeft()
local triggerBox
if (left) then
	triggerBox = template.TriggerBox[state]
else
	triggerBox = template.TriggerBoxFlip[state]
end
local mob = self.Entity
local triggerComponent = mob.TriggerComponent

local colliderOffset = triggerBox[1]
local boxSize = triggerBox[2]
local max = math.max

triggerComponent.ColliderOffset = colliderOffset
triggerComponent.BoxSize = boxSize
if (isvalid(self.Entity.ColliderVisualizer)) then
	self.Entity.ColliderVisualizer:OnRefresh(TriggerComponent)
end

local bodyAttackEntity = self.BodyAttack
if (isvalid(bodyAttackEntity) and bodyAttackEntity.Enable) then
	local ba = bodyAttackEntity.TriggerComponent
	
	local t = -max(1, (boxSize.y * 50) - 30)
	local b = max(1, (boxSize.y * 50) - 10)
	local r = max(1, (boxSize.x * 50) - 25)
	local l = -max(1, (boxSize.x * 50) - 25)
	local oc, os = _NumberUtils:GetTriggerBoxFromLtRb(Vector2(l, t), Vector2(r, b), left)
	ba.ColliderOffset = oc + colliderOffset
	ba.BoxSize = os
	
	if (isvalid(bodyAttackEntity.ColliderVisualizer)) then
		bodyAttackEntity.ColliderVisualizer:OnRefresh(TriggerComponent)
	end
end
end