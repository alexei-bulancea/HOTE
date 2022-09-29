function StartRaining( event )

       -- Variables
       local caster = event.caster
       local ability = event.ability
       local point = event.target_points[1]
       local duration =  ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  )
       local stun_duration =  ability:GetLevelSpecialValueFor( "stun_duration" , ability:GetLevel() - 1  )
        local particleName = "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf"

       caster.dummy = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())

       local projTable = {
        duration = duration
       }
       local stunTable = {
        duration = stun_duration
       }
       event.ability:ApplyDataDrivenModifier(caster, caster.dummy, "modifier_rain_of_fire", projTable)
       event.ability:ApplyDataDrivenModifier(caster, caster.dummy, "modifier_rain_of_fire_animation", projTable)


	Timers:CreateTimer(duration, function() caster.dummy:RemoveSelf() end)

end
-- Keep track of the targeted point to make the rockets
function RainingAnimation( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
	local point = target:GetAbsOrigin()

    local particleName = "particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf"
    local radius =  ability:GetLevelSpecialValueFor( "radius" , ability:GetLevel() - 1  )

    local nFXIndex = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    

    ParticleManager:SetParticleControl( nFXIndex, 0, point )
    ParticleManager:SetParticleControl( nFXIndex, 4, Vector( tonumber(radius), 0, 0 ) )
end
