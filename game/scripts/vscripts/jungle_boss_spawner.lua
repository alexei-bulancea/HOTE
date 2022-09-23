if CJungleBossSpawner == nil then
    CJungleBossSpawner = class({})
end

function CJungleBossSpawner:ReadConfiguration(kvJungleBoss)
    self._sName = kvJungleBoss.BossName or ""
    self._sSpawnLocation = kvJungleBoss.SpawnLocation or ""
    self._sNextBossId = kvJungleBoss.NextBossId or ""
    self._tRespawnTime = tonumber(kvJungleBoss.RespawnTime or 0) 
    self._tNextBossRespawnTime = tonumber(kvJungleBoss.NextBossRespawnTime or 0)
    self._bSpawnedOnGameStart = tonumber(kvJungleBoss.SpawnedOnGameStart or 0)
end

function CJungleBossSpawner:Begin()
    print("BEgin for jungle boss")

    if self._bSpawnedOnGameStart == 1 then
        local radiantSpawner = Entities:FindByName(nil, self._sSpawnLocation)
        local radiantLocation = radiantSpawner:GetAbsOrigin()
        local radiantUnit = CreateUnitByName( self._sName, radiantLocation, true, nil, nil, DOTA_TEAM_NEUTRALS )

        --radiantUnit:AddNewModifier( radiantUnit, nil, "jungle_boss_modifier", {} )	

        self._nEntityIndex = radiantUnit:GetEntityIndex()
        print(self._nEntityIndex)
    end 
end

function CJungleBossSpawner:SpawnNextBoss(bossInfo)
    print("Spawn next boss")

    local radiantSpawner = Entities:FindByName(nil, bossInfo._sSpawnLocation)
    local radiantLocation = radiantSpawner:GetAbsOrigin()
    local radiantUnit = CreateUnitByName( bossInfo._sName, radiantLocation, true, nil, nil, DOTA_TEAM_NEUTRALS )

    --radiantUnit:AddNewModifier( radiantUnit, nil, "jungle_boss_modifier", {} )	

    bossInfo._nEntityIndex = radiantUnit:GetEntityIndex()
end