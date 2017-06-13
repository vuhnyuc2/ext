--require 'DamageLib'
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

class "Thresh"

function Thresh:__init()
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

function Thresh:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/d/d5/Death_Sentence.png" }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/4/44/Dark_Passage.png" }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width, icon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/7/71/Flay.png" }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c1/The_Box.png" }
end

function Thresh:LoadMenu()
	Tocsin = MenuElement({type = MENU, id = "Tocsin", name = "Tocsin Thresh"})



	Tocsin:MenuElement({name = "Thresh", drop = {ScriptVersion}, leftIcon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/b/b5/Thresh_OriginalLoading.jpg"})
	
	--Combo

	Tocsin:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Tocsin.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Combo:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Combo:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Combo:MenuElement({id = "Key", name = "Toggle: E Push-Pull Key", key = string.byte("T"), toggle = true})
	Tocsin.Combo:MenuElement({id = "R", name = "Use [R]", value = true, leftIcon = R.icon})
	Tocsin.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
	
	--Clear support, nah we Gucci
--[[
	Tocsin:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
	Tocsin.Clear:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("A"), toggle = true})
	Tocsin.Clear:MenuElement({id = "Q", name = "Use [Q]", value = false, leftIcon = Q.icon})
	Tocsin.Clear:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear [%]", value = 0, min = 0, max = 100})
--]]
	--Harass

	Tocsin:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Tocsin.Harass:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("S"), toggle = true})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [Q]", value = false, leftIcon = Q.icon})
	Tocsin.Harass:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	--Tocsin.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass [%]", value = 0, min = 0, max = 100})

	--Misc

	--Tocsin:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	

	--Eternal Prediction
	Tocsin:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Tocsin.Pred:MenuElement({id = "Chance", name = "Prediction Hitchance", value = 0.125, min = 0.05, max = 1, step = 0.025})
	
	--Draw

	Tocsin:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	Tocsin.Draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true, leftIcon = Q.icon})
	Tocsin.Draw:MenuElement({id = "Push", name = "Push Toggle", value = true})
	Tocsin.Draw:MenuElement({id = "HT", name = "Harass Toggle", value = true})
end

function Thresh:Tick()
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	end
end

function Thresh:Combo()
	local target = GetTarget(1450)
	if not target then return end
	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1050 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W) then
		self:CastW(target)
	end
	if Tocsin.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 400 then
		self:CastE(target)
	end
	if Tocsin.Combo.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 420 then
		self:CastR(target)
	end
end

function Thresh:Harass()
	local target = GetTarget(1450)
	if Tocsin.Harass.Key:Value() == false then return end
	--if myHero.mana/myHero.maxMana < Tocsin.Harass.Mana:Value() then return end
	if not target then return end
	if Tocsin.Harass.Q:Value() and Ready(_Q)and myHero.pos:DistanceTo(target.pos) < 1050 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Harass.E:Value() and Ready(_E)and myHero.pos:DistanceTo(target.pos) < 400 then
		self:CastE(target)
	end
end
--[[
function Thresh:Clear()
	if Tocsin.Clear.Key:Value() == false then return end
	if myHero.mana/myHero.maxMana < Tocsin.Clear.Mana:Value() then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team ~= myHero.team then
			if  Tocsin.Clear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1000 then
				self:CastQ(minion)
			end
			if  Tocsin.Clear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 400 then
				self:CastE(minion)
			end
		end
	end
end
--]]
function Thresh:CastQ(target)
	local Qdata = {speed = 1200, delay = 0.50,range = 1050 }
	local Qspell = Prediction:SetSpell(Qdata, TYPE_LINEAR, true)
	local pred = Qspell:GetPrediction(target,myHero.pos)
	if  myHero.pos:DistanceTo(target.pos) < 1050 then
		if myHero.attackData.state == STATE_WINDDOWN then
			if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() and pred:mCollision() == 0 and pred:hCollision() == 0 then
				EnableOrb(false)
				Control.CastSpell(HK_Q, pred.castPos)
				EnableOrb(true)
			end
		end
	end
	if  myHero.pos:DistanceTo(target.pos) < 1050 then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() and pred:mCollision() == 0 and pred:hCollision() == 0 then
			EnableOrb(false)
			Control.CastSpell(HK_Q, pred.castPos)
			EnableOrb(true)
		end
	end
end

function Thresh:CastW(target)
	for i,ally in pairs(self.GetAllyHeroes()) do
		if self:IsValidTarget(ally,950) and myHero.pos:DistanceTo(ally.pos) < 950 then
			if not ally.isMe then
				for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
					if hero.team == myHero.team and not hero.isMe and myHero.pos:DistanceTo(target.pos) < 250 then
						if Tocsin.Combo.W:Value() and Ready(_W) and not Ready(_Q) and not ally.isMe then
							EnableOrb(false)
							Control.CastSpell(HK_W,ally)
							EnableOrb(true)
						end
					end
				end
			end
		end
	end
end

function Thresh:CastE(target)
	if  myHero.pos:DistanceTo(target.pos) < 420 then
		if Tocsin.Combo.Key:Value() == false then
				EnableOrb(false)
				Control.CastSpell(HK_E, myHero.pos:Extended(target.pos, -100))
				EnableOrb(true)
		end
	end
	if  myHero.pos:DistanceTo(target.pos) < 420 then
		if Tocsin.Combo.Key:Value() == true then
			EnableOrb(false)
			Control.CastSpell(HK_E, target.pos)
			EnableOrb(true)
		end
	end
end

function Thresh:CastR(target)
	local target = GetTarget(420)
	if self:CountEnemys(420) >= Tocsin.Combo.ER:Value() then
		if not target.dead and not target.isImmune then
			if target.distance <= 420 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

function Thresh:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 400 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
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

function Thresh:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 1000 
end

function Thresh:Draw()
	if Tocsin.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1000, 3,  Draw.Color(255,255, 162, 000)) end
	if Tocsin.Draw.Push:Value() then
		local textPos = myHero.pos:To2D()
		if Tocsin.Combo.Key:Value() then
			Draw.Text("Push: On", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("Push: Off", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 225, 000, 000)) 
		end
	end
	if Tocsin.Draw.HT:Value() then
		local textPos = myHero.pos:To2D()
		if Tocsin.Harass.Key:Value() then
			Draw.Text("Harass: On", 20, textPos.x - 40, textPos.y + 80, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("Harass: Off", 20, textPos.x - 40, textPos.y + 80, Draw.Color(255, 255, 000, 000)) 
		end
	end
end

Callback.Add("Load", function()
	if not _G.Prediction_Loaded then return end
	if _G[myHero.charName] then
		_G[myHero.charName]()
		print("Tocsin "..myHero.charName.." "..ScriptVersion.." Loaded")
	else print ("Tocsin doens't support "..myHero.charName.." shutting down...") return
	end
end)