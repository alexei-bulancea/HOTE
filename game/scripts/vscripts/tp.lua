function tp1(event)
    print("trigger")
    local unit = event.activator
    local wws= "spider_lane_1_stack_position" -- вот та сама точка, куда мы будем телепортировать героя, мы её указали в скрипте
 
    local ent = Entities:FindByName( nil, wws) --строка ищет как раз таки нашу точку pnt1
    local point = ent:GetAbsOrigin() --эта строка выясняет где находится pnt1 и получает её координаты
    event.activator:SetAbsOrigin( point ) -- получили координаты, теперь меняем место героя на pnt1
    FindClearSpaceForUnit(event.activator, point, false) --нужно чтобы герой не застрял
    event.activator:Stop() --приказываем ему остановиться, иначе он побежит назад к предыдущей точке
 end