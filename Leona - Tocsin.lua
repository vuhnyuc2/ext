class "Leona"
 
require = 'DamageLib'

function Leona:__init()
	if myHero.charName ~= "Leona" then return end
PrintChat("Leona - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["LeonaIcon"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/7/74/Leona_OriginalLoading.jpg",
["Q"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/c/c6/Shield_of_Daybreak.png",
["W"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/c/c5/Eclipse.png",
["E"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/9/91/Zenith_Blade.png",
["R"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/5/5c/Solar_Flare.png",
["EXH"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/4/4a/Exhaust.png"
}

function Leona.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Leona:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Leona", name = "Leona", leftIcon = Icons["LeonaIcon"]})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
	self.Menu.Combo:MenuElement({id = "Exhaust", name = "Use Exhaust", value = true, leftIcon = Icons.EXH})
--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})

--[[LastHit nah we support brah

	--self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	--self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})

--JungleClear Nah we support brah
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.JungleClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.JungleClear:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	self.Menu.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 30, min = 0, max = 100})
--]]
--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawE", name = "Draw E Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawR", name = "Draw R Range", value = true})
end

function Leona:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		end
end

function Leona:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawE:Value())then
		Draw.Circle(myHero, 875, 3, Draw.Color(255, 225, 255, 10))
	end
	if(self.Menu.Drawings.drawR:Value())then
		Draw.Circle(myHero, R.range, 3, Draw.Color(225, 225, 0, 10))
	end
end

function Leona:Combo()
	local etarg = _G.SDK.TargetSelector:GetTarget(825)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			self:CastE(etarg)
		end

	local wtarg = _G.SDK.TargetSelector:GetTarget(275)
		if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
			Control.CastSpell(HK_W)
		end

	local qtarg = _G.SDK.TargetSelector:GetTarget(Q.range)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
			local castPosition = etarg
			self:CastQ(castPosition)
		end
	
	local  rtarg = _G.SDK.TargetSelector:GetTarget(R.range) 
		if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    		if self:CountEnemys(500) >= self.Menu.Combo.ER:Value() then
    			self:CastR(rtarg)
      		end
    	end	

    local xtarg = _G.SDK.TargetSelector:GetTarget(600)
		if xtarg and self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
			self:Exhaust(xtarg)
		end

	local htarg = _G.SDK.TargetSelector:GetTarget(350)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3401) >= 1 and myHero.health/myHero.maxHealth <= .7 then 
		if self:IsReady(GetItemSlot(myHero, 3401)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3401)], self)
		end 
	end

	local starg = _G.SDK.TargetSelector:GetTarget(350)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3190) >= 1 and myHero.health/myHero.maxHealth <= 0.35 then 
		if self:IsReady(GetItemSlot(myHero, 3190)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3190)], self)
		end 
	end

end

function Leona:Harass()
	local etarg = _G.SDK.TargetSelector:GetTarget(825)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			self:CastE(etarg)
		end

	local wtarg = _G.SDK.TargetSelector:GetTarget(275)
		if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
			Control.CastSpell(HK_W)
		end

	local qtarg = _G.SDK.TargetSelector:GetTarget(Q.range)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local castPosition = etarg
			self:CastQ(castPosition)
		end

	local htarg = _G.SDK.TargetSelector:GetTarget(350)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3401) >= 1 and myHero.health/myHero.maxHealth <= .7 then 
		if self:IsReady(GetItemSlot(myHero, 3401)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3401)], self)
		end 
	end

	local starg = _G.SDK.TargetSelector:GetTarget(350)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3190) >= 1 and myHero.health/myHero.maxHealth <= 0.35 then 
		if self:IsReady(GetItemSlot(myHero, 3190)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3190)], self)
		end 
	end

end

function Leona:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 875 
end

function Leona:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Leona:Exhaust(target)
	if target then 
   		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and self:IsReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= 0.4 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and self:IsReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= 0.4 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
		end
	end
end

local function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 
end

function Leona:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 250 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Leona:CastE(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=825 then
				local pred=target:GetPrediction(E.speed,E.delay)
				Control.CastSpell(HK_E,pred)
			end
		end
	end
return false
end

function Leona:CastW(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=W.range then
				Control.CastSpell(HK_W)
			end
		end
	end
return false
end

function Leona:CastQ(position)
	if position then
		Control.SetCursorPos(position)
		Control.CastSpell(HK_Q, position)
	end
end

function Leona:CastR(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=R.range then
				local pred=target:GetPrediction(R.speed,R.delay)
					Control.CastSpell(HK_R,pred)
			end
		end
	end
return false
end

function Leona:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Leona:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Leona()
end