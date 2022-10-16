-- Generated from template


if CHoteTest == nil then
	CHoteTest = class({})
end

--nil will not force a hero selection
local forceHero = "npc_dota_hero_axe"

function Precache( context )
		--Precache things we know we'll use.  Possible file types include (but not limited to):
			--PrecacheResource( "modifiers", "*.lua", context )
			--PrecacheResource( "soundfile", "*.vsndevts", context )
			--PrecacheResource( "particle", "*.vpcf", context )
			--PrecacheResource( "particle_folder", "particles/folder", context )

end

require("hote_game_spawner")
require("timers")
require("jungle_boss_spawner")
--require("modifiersjungle_boss_modifier")

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CHoteTest()
	GameRules.AddonTemplate:InitGameMode()
end

function CHoteTest:InitGameMode()
	print( "Template addon is loaded." )

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

    GameRules:EnableCustomGameSetupAutoLaunch(true)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)


	self:_ReadGameConfiguration()
    --GameRules:SetHeroSelectionTime(10)
	GameRules:SetHeroSelectionTime(5)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
	--disable some setting which are annoying then testing
	
	self._GameMode = GameRules:GetGameModeEntity()
	--self._GameMode:SetCustomGameForceHero(forceHero)

	self._GameMode:SetAnnouncerDisabled(true)
	self._GameMode:SetKillingSpreeAnnouncerDisabled(true)
	self._GameMode:SetDaynightCycleDisabled(true)
	self._GameMode:DisableHudFlip(true)
	self._GameMode:SetDeathOverlayDisabled(true)
	self._GameMode:SetWeatherEffectsDisabled(true)

	--disable music events
	GameRules:SetCustomGameAllowHeroPickMusic(false)
	GameRules:SetCustomGameAllowMusicAtGameStart(false)
	GameRules:SetCustomGameAllowBattleMusic(false)

	--multiple players can pick the same hero
	GameRules:SetSameHeroSelectionEnabled(true)

	--listen to game state event
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self)
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( self, 'OnEntityKilled' ), self )
end


function CHoteTest:OnStateChange()
	--random hero once we reach strategy phase
	local nNewState = GameRules:State_Get()
	if  nNewState ==DOTA_GAMERULES_STATE_HERO_SELECTION then
		CHoteTest:RandomForNoHeroSelected()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

		if self._UnitSpawned == nil or self._UnitSpawned == 0 then

			for _, value in pairs(self._vJungleBosses) do
				value:Begin()
			end

			-- local radiantSpawner = Entities:FindByName(nil, "test_spawner")
			-- local radiantLocation = radiantSpawner:GetAbsOrigin()
			-- local radiantUnit = CreateUnitByName( "npc_dota_creature_gnoll_assassin", radiantLocation, true, nil, nil, DOTA_TEAM_NEUTRALS )
			self._UnitSpawned = 1
		end


		self._flPrepTimeEnd = GameRules:GetGameTime() + 5
	end
  end
  
  function CHoteTest:RandomForNoHeroSelected()
    --NOTE: GameRules state must be in HERO_SELECTION or STRATEGY_TIME to pick heroes
    --loop through each player on every team and random a hero if they haven't picked
  local maxPlayers = 5
  for teamNum = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
    for i=1, maxPlayers do
      local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNum, i)
      if playerID ~= nil then
        if not PlayerResource:HasSelectedHero(playerID) then

          local hPlayer = PlayerResource:GetPlayer(playerID)

          if hPlayer ~= nil then
            --hPlayer:MakeRandomHeroSelection()
			 local hero = CreateHeroForPlayer('npc_dota_hero_queenofpain', hPlayer)
			 	while hero:GetLevel() < 25 do
					hero:HeroLevelUp( false )
				end
          end
        end
      end
    end
  end
end

function CHoteTest:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print(self._flPrepTimeEnd) --FIX less updates
		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentSpawn ~= nil then
			self._currentSpawn:Think()
			if self._currentSpawn:IsFinishedSpawning() then
				--self._currentSpawn:End()
				self._currentSpawn = nil
				self._flPrepTimeEnd = GameRules:GetGameTime() + 10
			end

		end

		-- --Radiant spawner
		-- local radiantSpawner = Entities:FindByName(nil, "radiant_spawner")
		-- local radiantLocation = radiantSpawner:GetAbsOrigin()
		-- local radiantWayPoint = Entities:FindByName(nil, "radiant_path_1")
		-- local radiantUnit = CreateUnitByName( "npc_dota_creature_gnoll_assassin", radiantLocation, true, nil, nil, DOTA_TEAM_GOODGUYS )
		-- radiantUnit:SetInitialGoalEntity( radiantWayPoint )

		-- --Dire spawner
		-- local direSpawner = Entities:FindByName(nil, "dire_spawner")
		-- local direLocation = direSpawner:GetAbsOrigin()
		-- local direWayPoint = Entities:FindByName(nil, "dire_path_1")
		-- local direUnit = CreateUnitByName( "npc_dota_creature_gnoll_assassin", direLocation, true, nil, nil, DOTA_TEAM_BADGUYS )
		-- direUnit:SetInitialGoalEntity(direWayPoint )

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CHoteTest:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd and self._bUnitSpawnEnabled == 1 then
		self._flPrepTimeEnd = nil

		self._currentSpawn = self._vTroups[1] -- self.vTroupNumber
		self._currentSpawn:Begin(self._vRandomSpawnsList)
	end
end

function CHoteTest:_ReadGameConfiguration()
	local kv = LoadKeyValues("scripts/maps/hote_default.txt")
	kv = kv or {}

	self._flTimeBetweenSpawns = tonumber(kv.TimeBetweenSpawns or 0)
	self._bUnitSpawnEnabled = tonumber(kv.UnitSpawnEnabled or 0)

	self:_ReadUnitSpawnsConfiguration(kv["UnitSpawners"]) -- Populates _vRandomSpawnsList table
	self:_ReadUnitTroupConfiguration(kv) -- Populates _vTroups table
	self:_ReadJungleBossConfiguration(kv)	--Populates _vJungleBosses table
end

function CHoteTest:_ReadUnitSpawnsConfiguration(kvSpawns)
	self._vRandomSpawnsList = {}
	if type(kvSpawns) ~="table" then
		return
	end

	for _,sp in pairs(kvSpawns) do
		table.insert(self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		})
	end
end	

function CHoteTest:_ReadUnitTroupConfiguration(kv)
	self._vTroups = {}
	kv = kv["Troups"]

	--local szDireTroupName = string.format("Dire%d", #self._vTroups + 1)
	local kvTroupData = kv["Radiant"]
	if kvTroupData == nil then
		print("Data for troup ".. szRadiantTroupName .. "not found")
		return
	end
	local radiantSpawn =  self._vRandomSpawnsList[2]

	local troupObj = CHoteGameSpawner()
	troupObj:ReadConfiguration(kvTroupData, radiantSpawn.szSpawnerName, radiantSpawn.szFirstWaypoint)
	table.insert(self._vTroups, troupObj)
end

function CHoteTest:_ReadJungleBossConfiguration(kv)
	self._vJungleBosses = {}
	kv = kv["JungleBosses"]

	while true do
		local kvJungleBossName = string.format("BossId_%d", #self._vJungleBosses + 1)
		local kvJungleBossData = kv[kvJungleBossName]
		if kvJungleBossData == nil	then
			print("Data for BossId " .. kvJungleBossName .. " nor found")
			return
		end
		local bossObj = CJungleBossSpawner()
		bossObj:ReadConfiguration(kvJungleBossData)
		table.insert(self._vJungleBosses, bossObj)
		--self._vJungleBosses[kvJungleBossName] = bossObj
	end
end

function CHoteTest:OnEntityKilled( event )
	print("OnEntityKilled - " .. event.entindex_killed)

	local killedUnit = EntIndexToHScript( event.entindex_killed )

	if killedUnit and killedUnit:IsCreep() then
		
		for _, value in pairs(self._vJungleBosses) do
			print("JungleBossId" .. value._nEntityIndex)
			if(value._nEntityIndex == event.entindex_killed) then
				print("got a match")
				print(value._sNextBossId)
				local currentBossID = Split(value._sNextBossId, "_")[2]

				self._GameMode:SetContextThink( string.format( "BossThink_%d", event.entindex_killed ), function() return self:Think_RespawnBoss( value, tonumber(currentBossID) ) end, value._tNextBossRespawnTime )

				return
			end
		end
		--self._GameMode:SetContextThink( string.format( "CreatureThink_%d", event.entindex_killed ), function() return self:Think_RespawnCreature( killedUnit ) end, 5 )

		--killedUnit:RespawnUnit()
	end
end

function CHoteTest:Think_RespawnCreature(killedUnit )
	print("Think_RespawnCreature")
	killedUnit:RespawnUnit()

end

function CHoteTest:Think_RespawnBoss(killedUnit,  currentBossID)
	killedUnit:SpawnNextBoss(self._vJungleBosses[currentBossID])
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end