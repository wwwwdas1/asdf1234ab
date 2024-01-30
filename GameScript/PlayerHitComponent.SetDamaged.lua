return function (self,damage,hitByLeft,fromMob,attackIndex,reflect) 
local user = self.Entity
local regularAttack = not fromMob or attackIndex <= 0
self.HitTime = _UtilLogic.ServerElapsedSeconds + 7
self.HitDamage = damage
local templateId = 0
if (isvalid(fromMob)) then
	templateId = fromMob.MobComponent:GetLinkOriginTemplateId()
end
self:ShowHitDamage(damage, 0, templateId, attackIndex, not hitByLeft, "")
if (damage > 0) then
	user.AvatarRendererComponent:PlayEmotion(EmotionalType.Hit, 5)
	--self:SetImpact(hitByLeft, not regularAttack and damage > 0, 1)
	user.CharacterActionComponent:EnableAlertMode(5)
end
local p = fromMob.TransformComponent.WorldPosition:ToVector2()
self:OnUserHitServer(damage, 0, fromMob, p, attackIndex, not hitByLeft, reflect, self.HitTime)
end