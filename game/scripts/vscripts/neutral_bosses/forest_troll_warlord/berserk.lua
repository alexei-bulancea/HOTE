

function AutoCastAbility(event)
    local caster= event.caster
    local ability = event.ability
    local casterIndex = caster:GetEntityIndex()
    --local manaCost = caster:GetSpecialValueFor("mana_cost")
    print( ability:GetAutoCastState()) -- "autocast state : "..
    print(caster:GetMana()) -- "mana : ".. 
    print( caster:IsAttacking()) -- "is attacking  : "..
    if ability:GetAutoCastState() and caster:GetMana() > 10 and caster:IsAttacking() then
        --ability:ApplyDataDrivenModifier(caster, caster, "modifier_troll_warlord_berserk", {})
        caster:CastAbilityNoTarget(ability,casterIndex)
    end

   -- caster:CastAbilityToggle(ability, casterIndex);

end

function ToggleAbility(event)

    local caster= event.caster
    local ability = event.ability
    local casterIndex = caster:GetEntityIndex()

    ability:ToggleAutoCast()
end