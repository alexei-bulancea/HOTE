if CHoteGameSpawner == nil then
        CHoteGameSpawner = class ({})
end

function CHoteGameSpawner:ReadConfiguration(kvTroups, spawnerName, spawnerTargetName)
		print( "CHoteGameSpawner:ReadConfiguration")

        self._tListOfUnits = {}

        for _, value in pairs(kvTroups) do
            table.insert( self._tListOfUnits, {
                sNPCName = value.NPCName or "",
                nDefaultCount = tonumber(value.DefaultCount or 0)
            })
        end

        self._szSpawnerName = spawnerName
        self._szFirstWaypoint = spawnerTargetName

        self._nChampionLevel = 1
        self._nChampionMax = 1
        self._nCreatureLevel = 1
        self._nTotalUnitsToSpawn = 10
        self._nUnitsPerSpawn = 5
    
        self._flChampionChance = 0
        self._flInitialWait = 5
        self._flSpawnInterval = 30
    
        -- self._bDontGiveGoal = ( tonumber( kv.DontGiveGoal or 0 ) ~= 0 )
        -- self._bDontOffsetSpawn = ( tonumber( kv.DontOffsetSpawn or 0 ) ~= 0 )
end

function CHoteGameSpawner:PostLoad(name, kv, gameRound)
    print( "CHoteGameSpawner:PostLoad")
end

function CHoteGameSpawner:Precache(name, kv, gameRound)
    print( "CHoteGameSpawner:Precache")
end

function CHoteGameSpawner:Begin()
    print( "CHoteGameSpawner:Begin")

		--Radiant spawner

		-- local radiantSpawner = Entities:FindByName(nil, "radiant_spawner")
		-- local radiantLocation = radiantSpawner:GetAbsOrigin()
		-- local radiantWayPoint = Entities:FindByName(nil, "radiant_path_1")

        if self._waitForUnit ~= nil or self._GroupWithUnit ~= nil then
            self.flNextSpawnTime = nil
        else    
            self._flNextSpawnTime = GameRules:GetGameTime() + self._flInitialWait
        end

end

function CHoteGameSpawner:End()
    print( "CHoteGameSpawner:end")
end

function CHoteGameSpawner:ParentSpawned()
    print( "CHoteGameSpawner:ParentSpawned")
end

function CHoteGameSpawner:Think()
    --print( "CHoteGameSpawner:Think")

	if not self._flNextSpawnTime then
		return
	end

	if GameRules:GetGameTime() >= self._flNextSpawnTime then
		self:_DoSpawn()

		if self:IsFinishedSpawning() then
			self._flNextSpawnTime = nil
		else
			self._flNextSpawnTime = self._flNextSpawnTime + self._flSpawnInterval
		end
	end

end

function CHoteGameSpawner:IsFinishedSpawning()
	return self._groupWithUnit ~= nil
end

function CHoteGameSpawner:_GetSpawnLocation()
    print( "CHoteGameSpawner:_GetSpawnLocation")
end

function CHoteGameSpawner:_GetSpawnWaypoint()
    print( "CHoteGameSpawner:_GetSpawnWaypoint")
end

function CHoteGameSpawner:_UpdateRandomSpawn()
    print( "CHoteGameSpawner:_UpdateRandomSpawn")
end


function CHoteGameSpawner:_DoSpawn()
    print( "CHoteGameSpawner:_DoSpawn")

    local radiantSpawner = Entities:FindByName(nil, self._szSpawnerName)
    local radiantLocation = radiantSpawner:GetAbsOrigin()
    local radiantWayPoint = Entities:FindByName(nil, self._szFirstWaypoint)

    local nUnitsSpawned = 0
    local nTimeBetweenSpawns = 1 -- 1 sec
    local groupOfUnitGenerated = 1 -- Unit type id which is currently created
    local currentTypeOfUnit = self._tListOfUnits[groupOfUnitGenerated]

    self.spawnTimer = Timers:CreateTimer(nTimeBetweenSpawns, function()

        if currentTypeOfUnit.nDefaultCount == 0 then                        --forced check for entities that can be spawned later but now are 0
            groupOfUnitGenerated = groupOfUnitGenerated + 1
            currentTypeOfUnit = self._tListOfUnits[groupOfUnitGenerated]
            if currentTypeOfUnit == nil then
                return nil
            end
            return nTimeBetweenSpawns
        end

        local radiantUnit = CreateUnitByName( currentTypeOfUnit.sNPCName, radiantLocation, true, nil, nil, DOTA_TEAM_GOODGUYS )
        if radiantUnit ~= nil then
            radiantUnit:SetInitialGoalEntity( radiantWayPoint )
            nUnitsSpawned = nUnitsSpawned + 1
        end

        if nUnitsSpawned >= currentTypeOfUnit.nDefaultCount then --We iterate through all available types of units
            groupOfUnitGenerated = groupOfUnitGenerated + 1
            currentTypeOfUnit = self._tListOfUnits[groupOfUnitGenerated]
            if currentTypeOfUnit == nil then
                return nil
            end
            return nTimeBetweenSpawns
        else
            return nTimeBetweenSpawns
        end
    end)

    -- for iUnit = 1, self._nMeleeCount do
    --     local radiantUnit = CreateUnitByName( self._szMeleeNPCName, radiantLocation, true, nil, nil, DOTA_TEAM_GOODGUYS )
    --     radiantUnit:SetInitialGoalEntity( radiantWayPoint )
    -- end

    -- for iUnit = 1, self._nRangedCount do
    --     local radiantUnit = CreateUnitByName( self._szRangedNPCName, radiantLocation, true, nil, nil, DOTA_TEAM_GOODGUYS )
    --     radiantUnit:SetInitialGoalEntity( radiantWayPoint )
    -- end
end