
require 'Eternal Prediction'

local ScriptVersion = "v1.0"

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
end

local function EnemiesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local m = Game.Hero(i)
		if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 125 then
			Count = Count + 1
		end
	end
	return Count
end

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}--
end

local function GetBuffs(unit)
	local t = {}
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 then
			table.insert(t, buff)
		end
	end
	return t
end
local Grasp = false
local function AlliesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local m = Game.Hero(i)
		if m and m.team == 100 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 600 then
			Count = Count + 1
		end
	end
	return Count
end

local function GetTarget(range)
	local target = nil
	if Orb == 1 then
		target = EOW:GetTarget(range)
	elseif Orb == 2 then
		target = _G.SDK.TargetSelector:GetTarget(range)
	elseif Orb == 3 then
		target = GOS:GetTarget(range)
	end
	return target
end

local intToMode = {
   	[0] = "",
   	[1] = "Combo",
   	[2] = "Harass",
   	[3] = "LastHit",
   	[4] = "Clear"
}

local function GetMode()
	if Orb == 1 then
		return intToMode[EOW.CurrentMode]
	elseif Orb == 2 then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	else
		return GOS.GetMode()
	end
end

local function EnableOrb(bool)
	if Orb == 1 then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif Orb == 2 then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end

class "Malzahar"

function Malzahar:__init()
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	end
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Malzahar:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/5/5f/Call_of_the_Void.png" }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/a/a1/Void_Swarm.png" }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/3/3e/Malefic_Visions.png" }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/4/4e/Nether_Grasp.png" }
end

function Malzahar:LoadMenu()
	Tocsin = MenuElement({type = MENU, id = "Tocsin", name = "Tocsin Malzahar"})



	Tocsin:MenuElement({name = "Malzahar", drop = {ScriptVersion}, leftIcon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/8/81/Malzahar_OriginalLoading.jpg"})
	
	--Combo

	Tocsin:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Tocsin.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Combo:MenuElement({id = "W", name = "Use [W]", value = false, leftIcon = W.icon})
	Tocsin.Combo:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Combo:MenuElement({id = "R", name = "Use [R]", value = true, leftIcon = R.icon})
	Tocsin.Combo:MenuElement({id = "Health", name = "Enemy Health % To Use R", value = 0.50, min = 0.1, max = 1, step = 0.05})

	--Harass

	Tocsin:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [Q]", value = false, leftIcon = Q.icon})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [W]", value = false, leftIcon = W.icon})
	Tocsin.Harass:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass [%]", value = 0.35, min = 0.05, max = 1, step = 0.01})

    --Clear

	Tocsin:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
	Tocsin.Clear:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
    Tocsin.Clear:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Clear:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear [%]", value = 0.30, min = 0.05, max = 1, step = 0.01})

		--Misc

	Tocsin:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	Tocsin.Misc:MenuElement({id = "Qks", name = "Killsecure [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Misc:MenuElement({id = "Eks", name = "Killsecure [E]", value = true, leftIcon = E.icon})
	

	--Eternal Prediction
	Tocsin:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Tocsin.Pred:MenuElement({id = "Chance", name = "Prediction Hitchance", value = 0.200, min = 0.05, max = 1, step = 0.025})
	
	--Draw

	Tocsin:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	Tocsin.Draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true, leftIcon = Q.icon})


end

function Malzahar:Tick()
	if myHero.dead or Grasp == true then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
    elseif Mode == "Clear" then
		self:Clear()
	end
    self:Misc()
    --AbleOrb()
end

function Malzahar:Combo()
	local target = GetTarget(1000, "AD")
	if not target then return end
	if myHero.activeSpell.isChanneling == true then return end
    if Tocsin.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 630 then
		self:CastE(target)
	end

	if Tocsin.Combo.Q:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) < 870 then
		self:CastQ(target)
	end

	if Tocsin.Combo.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 680 then
		self:CastR(target)
	end

	if Tocsin.Combo.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 150 then
		self:CastW(target)
	end

end

function Malzahar:Harass()
	local target = GetTarget(1000)
	if myHero.mana/myHero.maxMana < Tocsin.Harass.Mana:Value() then return end
	if not target then return end
	if Tocsin.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 630 then
		self:CastE(target)
	end

	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 870 then
		self:CastQ(target)
	end

	if Tocsin.Combo.W:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 150 then
		self:CastW(target)
	end
end

function Malzahar:Clear()
	if myHero.mana/myHero.maxMana < Tocsin.Clear.Mana:Value() then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team ~= myHero.team then
		    if  Tocsin.Clear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 630 then
				self:CastE(minion)
			end
            if  Tocsin.Clear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 870 then
				self:CastQ(minion)
			end
            if  Tocsin.Clear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 150 then
				self:CastW(minion)
			end
		end
	end
end
--   80 / 115 / 150 / 185 / 220 (+ 80% AP) E
--   70 / 105 / 140 / 175 / 210 (+ 80% AP) Q
function Malzahar:Misc()
	if myHero.activeSpell.isChanneling == true then return end
	local target = GetTarget(850)
	if not target then return end
		if Tocsin.Misc.Eks:Value() and Ready(_E) then
			local lvl = myHero:GetSpellData(_E).level
			local Edmg = (({80, 115, 150, 185, 220})[lvl] + .80 * myHero.ap)
			if  Edmg > target.health + target.shieldAP then
				self:CastE(target)
			end
		end
        if Tocsin.Misc.Eks:Value() and Tocsin.Misc.Qks:Value() and Ready(_Q) and Ready(_E) then
        local Elvl = myHero:GetSpellData(_E).level
        local Qlvl = myHero:GetSpellData(_E).level
		local Edmg = (({80, 115, 150, 185, 220})[Elvl] + .80 * myHero.ap)
        local Qdmg = (({70, 105, 140, 175, 210})[Elvl] + .80 * myHero.ap)
        local QEdmg = Edmg + Qdmg
            if QEdmg > target.health * 1.2 + target.shieldAP then
                self:CastE(target)
                DelayAction(function() self:CastQ(target) end, 0.3)
            end
        end
end

function AbleOrb()
	if myHero.activeSpell.isChanneling == false then
	EnableOrb(true)
	end
end

function Malzahar:CastQ(target)
	if myHero.activeSpell.isChanneling == true then return end
	local Qdata = {speed = 1600, delay = 0.25, range = 870 }
	local Qspell = Prediction:SetSpell(Qdata, TYPE_LINEAR, false)
	local pred = Qspell:GetPrediction(target,myHero.pos)
	if  myHero.pos:DistanceTo(target.pos) < 870 then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() then
		    --for i = 0, target.buffCount do
		    --local buff = target:GetBuff(i);
			    --if buff.count > 0 then
				    --if buff.name == MalzaharE then
					    EnableOrb(false)
			            Control.CastSpell(HK_Q, pred.castPos)
			            DelayAction(function() EnableOrb(true) end, 0.3)
				    --end 
			    --end
		    --end	
		end
	end
end

function Malzahar:CastW(target)
	if myHero.activeSpell.isChanneling == true then return end
	if  myHero.pos:DistanceTo(target.pos) < 150 then
		Control.CastSpell(HK_W)
	end
end

function Malzahar:CastE(target)
	if myHero.activeSpell.isChanneling == true then return end
	if  myHero.pos:DistanceTo(target.pos) < 630 then
	    Control.CastSpell(HK_E, target)
	end
end

LastR = Game.Timer()
function Malzahar:CastR(target)
	local target = GetTarget(700)
	if not target.dead and not target.isImmune and Game.Timer() - LastR > 5 then
		if target.distance < 680 and target.health/target.maxHealth < Tocsin.Combo.Health:Value() then
			EnableOrb(false)
			Control.CastSpell(HK_R, target)
			Grasp = true
			DelayAction(function() Grasp = false EnableOrb(true) end, 2.6)
		end
	end
end

function Malzahar:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 700 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Malzahar:GetAllyHeroes()
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

function Malzahar:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 1000 
end

function Malzahar:Draw()
	if Tocsin.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1050, 3,  Draw.Color(255,255, 162, 000)) end

end

Callback.Add("Load", function()
	if myHero.charName ~= "Malzahar" then return end
	if not _G.Prediction_Loaded then return end
	if _G[myHero.charName] then
		_G[myHero.charName]()
		print("Tocsin "..myHero.charName.." "..ScriptVersion.." Loaded")
	else print ("Tocsin doens't support "..myHero.charName.." shutting down...") return
	end
end)