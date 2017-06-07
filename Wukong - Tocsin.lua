class "Wukong"
 
require = 'DamageLib'

function Wukong:__init()
	if myHero.charName ~= "MonkeyKing" then return end
PrintChat("Wukong - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["WukongIcon"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/7/78/Wukong_OriginalLoading.jpg",
["Q"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/1/10/Crushing_Blow.png",
["W"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/b/bb/Decoy.png",
["E"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/e/e0/Nimbus_Strike.png",
["R"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/7/79/Cyclone.png",
["EXH"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/4/4a/Exhaust.png"
}

function Wukong.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Wukong:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Wukong", name = "Wukong", leftIcon = Icons["WukongIcon"]})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = false, leftIcon = Icons.W})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
	--self.Menu.Combo:MenuElement({id = "Exhaust", name = "Use Exhaust", value = true, leftIcon = Icons.EXH})
--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = false, leftIcon = Icons.W})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})

--KS
	self.Menu:MenuElement({type = MENU, id = "Killsteal", name = "Killsteal"})
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Killsteal:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})

--[[LastHit -Turned off for time being(need to add E check for >=2 minion last hit to make it worth)

	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.LastHit:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.LastHit:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
--]]
--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.JungleClear:MenuElement({id = "W", name = "Use W", value = false, leftIcon = Icons.W})
  	self.Menu.JungleClear:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	self.Menu.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 30, min = 0, max = 100})

--misc
--	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
--		if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
--			self.Menu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true})
--		end

--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawE", name = "Draw E Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
end

function Wukong:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		end
	self:KS()
end

function Wukong:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawE:Value())then
		Draw.Circle(myHero, E.range, 3, Draw.Color(255, 255, 255, 10))
	end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
end
--Combo aka spacebar
function Wukong:Combo()
	if _G.SDK.TargetSelector:GetTarget(850) == nil then return end
	local ytarg = _G.SDK.TargetSelector:GetTarget(850)
	local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,}
	if GetItemSlot(myHero, 3142) >= 1 and self:CanCast(_E) and ytarg then 
		if self:IsReady(GetItemSlot(myHero, 3142)) then
			Control.CastSpell(ItemHotKey[GetItemSlot(myHero, 3142)], self)
		end 
	end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)

	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(pred)

	end
	
	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:CastR(rtarg)
    end
 
--    if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
--		self:Exhaust(xtarg)
--	end
end

function Wukong:Harass()
	if _G.SDK.TargetSelector:GetTarget(850) == nil then return end
	
	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)

	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(pred)
	end
		
end

function Wukong:JungleClear()
  	if self:GetValidMinion(650) == false then return end
  	local minion = nil
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 or 200 then
			if self:IsValidTarget(minion,650) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.JungleClear.E:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_E) then
				Control.CastSpell(HK_E,minion.pos)
			break
			end    		
			if self:IsValidTarget(minion,280) and myHero.pos:DistanceTo(minion.pos) < 280 and self.Menu.JungleClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_Q) then
				Control.CastSpell(HK_Q,minion.pos)
			break
			end
			if self:IsValidTarget(minion,150) and myHero.pos:DistanceTo(minion.pos) < 150 and self.Menu.JungleClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_W) then
				Control.CastSpell(HK_W)
			break
			end
		end
	end
end

function Wukong:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 650 
end

function Wukong:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 650 then
        return true
        end
    	end
    	return false
end

function Wukong:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Wukong:Exhaust(target)
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

function Wukong:HasBuff(unit, buffname)
for i = 0, unit.buffCount do
local buff = unit:GetBuff(i)
if buff.name == buffname and buff.count > 0 then 
return true
end
end
return false
end

function Wukong:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 200 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Wukong:CastQ(pred)
	local qtarg = _G.SDK.TargetSelector:GetTarget(280)
	if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local pred=qtarg:GetPrediction(Q.speed,Q.delay)
			Control.CastSpell(HK_Q,pred)
	end
return false
end

function Wukong:CastW(target) 
	local wtarg = _G.SDK.TargetSelector:GetTarget(650)
	if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		Control.CastSpell(HK_W)
	end
end
				

function Wukong:CastE(target)
	local etarg = _G.SDK.TargetSelector:GetTarget(650)
	if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		local pred=etarg:GetPrediction(E.speed,E.delay)
		Control.CastSpell(HK_E,pred)
	end
end

function Wukong:WhatSpell()
	if myHero.isChanneling then
 		local spell = myHero.activeSpell
 		if spell.valid then
  		print("Name: "..spell.name)
  		print("Target: "..spell.target)
  		print("Windup: "..spell.windup)
  		print("Animation: "..spell.animation)
  		Draw.Circle(spell.startPos,50,Draw.Color(200,50,250,50))
  		Draw.Circle(spell.placementPos,50,Draw.Color(200,250,50,50))
 		end
	end
end

LastR = Game.Timer()
function Wukong:CastR(target)
    local rtarg = _G.SDK.TargetSelector:GetTarget(300)
    if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
        if not rtarg.dead and not rtarg.isImmune then
            if self:CountEnemys(300) >= self.Menu.Combo.ER:Value() then
                if rtarg.distance<=300 and rtarg.health/rtarg.maxHealth <= 0.40 then
                   if Game.Timer() - LastR > 4 then
                      LastR = Game.Timer()
                      Control.CastSpell(HK_R)
                    end
                end
            end
        end
    end
return false
end

--[[ use Legendary Activator
function Wukong:Misc()
	if _G.SDK.TargetSelector:GetTarget(650) == nil then return end
     	for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
            if myHero:GetSpellData(5).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_2) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end
            if myHero:GetSpellData(4).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_1) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
end
--]]
function Wukong:KS()
	if _G.SDK.TargetSelector:GetTarget(650) == nil then return end
    	local EKS = _G.SDK.TargetSelector:GetTarget(650)
			if EKS and self:CanCast(_E) then
			local lvl = myHero:GetSpellData(_E).level
			local Qdmg = (({30, 60, 90, 120, 150})[lvl] + 0.10 * myHero.totalDamage)  --gains 125 range, deals 30/60/90/120/150 (+110% Attack Damage) bonus physical damage and reduces the enemy's Armor by 10/15/20/25/30% for 3 seconds.
			local Edmg = (({60, 105, 150, 195, 240})[lvl] + 0.80 * myHero.bonusDamage)--Each enemy struck takes 60/105/150/195/240 (+80% Bonus Attack Damage) physical damage. Wukong then gains 30/35/40/45/50% Attack Speed for 4 seconds.
			local Combodmg = Qdmg + Edmg + EKS.hpRegen * 2.5
				if Combodmg >= EKS.health and self:CanCast(_E) and self:CanCast(_Q) and self.Menu.Killsteal.UseE:Value() then
					self:CastE(EKS)	
				elseif Edmg >= EKS.health and self:CanCast(_E) and self.Menu.Killsteal.UseE:Value() then
					self:CastE(EKS)
				elseif Qdmg >= EKS.health and self:CanCast(_Q) and self:IsValidTarget(target, 280) and self.Menu.Killsteal.UseQ:Value() then
					self:CastQ(EKS)
					Control.Attack(EKS)
				end
			end
end

function Wukong:GetAllyHeroes()
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

function Wukong:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Wukong:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Wukong()
end