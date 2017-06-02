class "Thresh"
 
require = 'DamageLib'

function Thresh:__init()
	if myHero.charName ~= "Thresh" then return end
PrintChat("Thresh - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["ThreshIcon"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/b/b5/Thresh_OriginalLoading.jpg",
["Q"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/d/d5/Death_Sentence.png",
["W"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/4/44/Dark_Passage.png",
["E"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/7/71/Flay.png",
["R"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c1/The_Box.png",
["EXH"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/4/4a/Exhaust.png"
}

function Thresh.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Thresh:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Thresh", name = "Thresh", leftIcon = Icons["ThreshIcon"]})

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
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawR", name = "Draw R Range", value = true})
end

function Thresh:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		end
end

function Thresh:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawings.drawR:Value())then
		Draw.Circle(myHero, R.range, 3, Draw.Color(225, 225, 0, 10))
	end
end
--Combo aka spacebar
function Thresh:Combo()
	if _G.SDK.TargetSelector:GetTarget(1150) == nil then return end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(pred)
	end

	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end
	
	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:CastR(rtarg)
    end
 
    if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
		self:Exhaust(xtarg)
	end
--Face of the Mountain
	local htarg = _G.SDK.TargetSelector:GetTarget(550)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3401) >= 1 and myHero.health/myHero.maxHealth <= .7 and htarg then 
		if self:IsReady(GetItemSlot(myHero, 3401)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3401)], self)
		end 
	end
-- Locket of the Iron Solari
	local starg = _G.SDK.TargetSelector:GetTarget(550)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3190) >= 1 and myHero.health/myHero.maxHealth <= 0.35 and starg then 
		if self:IsReady(GetItemSlot(myHero, 3190)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3190)], self)
		end 
	end

end

function Thresh:Harass()
	if _G.SDK.TargetSelector:GetTarget(1150) == nil then return end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(pred)
	end

	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
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

function Thresh:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 875 
end

function Thresh:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Thresh:Exhaust(target)
	local xtarg = _G.SDK.TargetSelector:GetTarget(350)
	if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
	if xtarg then 
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
end

local function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 
end

function Thresh:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 200 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Thresh:CastQ(pred)
	local qtarg = _G.SDK.TargetSelector:GetTarget(1000)
	if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local pred=qtarg:GetPrediction(Q.speed,.50 + Game.Latency()/1000)
			Control.CastSpell(HK_Q,pred)
	end
return false
end

function Thresh:CastW(target) --nearest ally
	for i,ally in pairs(self.GetAllyHeroes()) do
		if self:IsValidTarget(ally,W.range) and myHero.pos:DistanceTo(ally.pos) < 950 then
			if not ally.isMe then
				for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
					if hero.team == myHero.team and not hero.isMe then
						if self.Menu.Combo.UseW:Value() and self:CanCast(_W) and not ally.isMe then
							Control.CastSpell(HK_W,ally)
						end
					end
				end
			end
		end
	end
end					

function Thresh:CastE(target)
	local etarg = _G.SDK.TargetSelector:GetTarget(400)
	if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		local pred=etarg:GetPrediction(E.speed,.25 + Game.Latency()/1000)
		--local pred=etarg:GetPrediction(E.speed,E.delay)
		Control.CastSpell(HK_E, myHero.pos:Extended(etarg.pos, -100))
		
	end
end

function Thresh:CastR(target)
	local rtarg = _G.SDK.TargetSelector:GetTarget(420)
	if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
		if self:CountEnemys(420) >= self.Menu.Combo.ER:Value() then
			if not rtarg.dead and not rtarg.isImmune then
				if rtarg.distance<=420 then
					Control.CastSpell(HK_R)
				end
			end
		end
	end
return false
end

function Thresh:GetAllyHeroes()
	local _AllyHeroes
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly then
      table.insert(_AllyHeroes, unit)
    end
	end
	return _AllyHeroes
end

function Thresh:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Thresh:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Thresh()
end