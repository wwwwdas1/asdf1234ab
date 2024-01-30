return function (self,_dd,appearType,delay) 
-- 네트워크로 전송받은 테이블 캐스팅
---@type Drop
local drop = _dd;

--local entity = self._objectPool.ChildObjectPoolComponent:Get(drop.Position)
--entity.DropComponent.ObjectPool = self._objectPool
--local entity = _SpawnService:SpawnByModelId("model://b9b74107-fdd9-4548-9bf1-09ce4b8affbf", "Drop-"..drop.ItemId, drop.Position, self._objectPool)

local Filters = {
    1302000, -- 검
    1312004, -- 손 도끼
    1322005, -- 몽둥이
    1332005, -- 도루코 대거
    1332007, -- 후루츠 대거
    1002014, -- 빨간색 머리띠
    1002066, -- 검은색 머리띠
    1002067, -- 연두색 머리띠
    1002068, -- 노란색 머리띠
    1002069, -- 파란색 머리띠
	1040006, -- 하얀 면 나시
	1041046, -- 분홍색 면 나시
	1072001, -- 빨간색 고무 장화
	1072005, -- 가죽 샌들
	1072037, -- 노란색 고무 장화
	1072038, -- 파란색 고무 장화
    1002008, -- 갈색 가죽 모자
    1002053, -- 초록색 가죽 모자
    1002054, -- 붉은색 가죽 모자
    1060002, -- 파란 청 반바지
    1060006, -- 갈색 면 반바지
    1002103, -- 핑크문 고깔모자 (콜드아이 잡템)
    2060000, -- 활 전용 화살 
    2061000, -- 석궁 전용 화살
    4030000, -- 슬라임 오목알
    4030001, -- 버섯 오목알
    4030009, -- 바둑판
    4030010, -- 옥토퍼스 오목알
    4030011, -- 돼지 오목알
    4030012  -- 몬스터 카드
}

local function contains(Filters, val)
    for i = 1, #Filters do
        if Filters[i] == val then
            return true
        end
    end
    return false
end

-- 퀘스트템은 안보여요 3_3
-------------------------------------------------------------
if zz_y7.use_filter then 
    if (drop.Quest > 0 or contains(Filters, drop.ItemId)) then  
	    if (not _UserQuestLogic:CanPickUpQuestItem(_UserService.LocalPlayer.WsCharacterData, drop.ItemId, drop.Quest)) then
		    return
        end
	end
else
    if (drop.Quest > 0) then
        if (not _UserQuestLogic:CanPickUpQuestItem(_UserService.LocalPlayer.WsCharacterData, drop.ItemId, drop.Quest)) then
            return
        end
    end
end

local function showDrop()
	---@type Entity
	local entity
	local returnPool
	if (drop.ItemId == 0) then
		returnPool = self._mesoObjectPool
		entity = _ObjectPool:Pick(returnPool, "PooledMeso", "model://35623b2c-7d42-4a33-83dc-faa1350af08a", Vector3(0,0,10000), self._dropsGroup)
	else
		returnPool = self._dropObjectPool
		entity = _ObjectPool:Pick(returnPool, "PooledDrop", "model://b9b74107-fdd9-4548-9bf1-09ce4b8affbf", Vector3(0,0,10000), self._dropsGroup)
	end
	
	entity.DropComponent:EnterField(appearType, drop, returnPool)
	
	self._clientDropMap[drop.ObjectId] = entity
	--log("first pos:", entity.TransformComponent.WorldPosition)
	--log("opos:", entity.DropComponent.OriginalPosition, "pos:",entity.DropComponent.Position)
end

if (delay > 0) then
	_TimerService:SetTimerOnce(showDrop, delay)
else
	showDrop()
end
end