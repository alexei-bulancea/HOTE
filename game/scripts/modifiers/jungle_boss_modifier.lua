jungle_boss_modifier = class({})

function jungle_boss_modifier:OnDeath( params )
	-- if IsServer() then
	-- 	if params.unit == self:GetParent() then
	-- 		EmitSoundOn( "Hero_Tusk.IceShards.Penguin", self:GetParent() )
	-- 		if params.attacker ~= nil then
	-- 			local gameEvent = {}
	-- 			gameEvent["team_number"] = DOTA_TEAM_GOODGUYS
	-- 			gameEvent["locstring_value"] = params.attacker:GetUnitName()
	-- 			gameEvent["message"] = "#Dungeon_PenguinKilled"
	-- 			FireGameEvent( "dota_combat_event_message", gameEvent )
	-- 		end
			
	-- 		if self.hFollowEnt ~= nil then
	-- 			self.hFollowEnt.hFollower = nil
	-- 			self:GetParent().hFollower = nil
	-- 		end
	-- 	end
	-- end
    print("jungle_boss_modifier:OnDeath")
	return 0 
end