require 'DamageLib'
require 'Eternal Prediction'

local ScriptVersion = "v1.0"

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
end
--[[
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
--]]
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

local function GetDistance(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local function GetDistance2D(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

local function OnScreen(unit)
	return unit.pos:To2D().onScreen;
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

class "DrMundo"

function DrMundo:__init()
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

function DrMundo:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/f/f2/Infected_Cleaver.png" }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/5/5d/Burning_Agony.png" }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/9/95/Masochism.png" }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/8/81/Sadism.png" }
end

function DrMundo:LoadMenu()
	Tocsin = MenuElement({type = MENU, id = "Tocsin", name = "Tocsin DrMundo"})



	Tocsin:MenuElement({name = "DrMundo", drop = {ScriptVersion}, leftIcon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/9/93/Dr._Mundo_OriginalLoading.jpg"})
	
	--Combo

	Tocsin:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Tocsin.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Combo:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Combo:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
    Tocsin.Combo:MenuElement({id = "R", name = "Use [R]", value = true, leftIcon = R.icon})
    Tocsin.Combo:MenuElement({id = "Health", name = "Health %", value = 0.25, min = 0.1, max = 1, step = 0.05})
	
	--Clear

	Tocsin:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
	Tocsin.Clear:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("A"), toggle = true})
	Tocsin.Clear:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Clear:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
    Tocsin.Clear:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
    Tocsin.Clear:MenuElement({id = "Health", name = "Health %", value = 0.25, min = 0.1, max = 1, step = 0.05})
	
	--Harass

	Tocsin:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Tocsin.Harass:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("S"), toggle = true})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Harass:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Harass:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})

--LastHit 

	Tocsin:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	Tocsin.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Q.icon})

	--Misc

	Tocsin:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	Tocsin.Misc:MenuElement({id = "Qks", name = "Killsecure [Q]", value = true, leftIcon = Q.icon})
	
 	--Eternal Prediction

	Tocsin:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Tocsin.Pred:MenuElement({type = SPACE, id = "Pred Info", name = "If you go too high it wont fire"})
	Tocsin.Pred:MenuElement({id = "Chance", name = "Prediction Hitchance", value = 0.15, min = 0.05, max = 1, step = 0.025})
	
	--Draw

	Tocsin:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	Tocsin.Draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true, leftIcon = W.icon})
	Tocsin.Draw:MenuElement({id = "CT", name = "Clear Toggle", value = true})
	Tocsin.Draw:MenuElement({id = "HT", name = "Harass Toggle", value = true})
end

function DrMundo:Tick()
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
    elseif Mode == "LastHit" then
        self:LastHit()
    else self:AutoW()
	end
		self:Misc()
end

function DrMundo:Combo()
	local target = GetTarget(1500)
	if not target then return end
	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1000 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 400 and myHero:GetSpellData(_W).toggleState == 1 then
		self:CastW(target)
	end
	if Tocsin.Combo.E:Value() and Ready(_E)and myHero.pos:DistanceTo(target.pos) < 150 then
		self:CastE(target)
	end
    if Tocsin.Combo.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 550 then 
        if myHero.health/myHero.maxHealth <= Tocsin.Combo.Health:Value() then
		    self:CastR(target)
        end
	end
end

function DrMundo:Harass()
	local target = GetTarget(1100)
	if Tocsin.Harass.Key:Value() == false then return end
	if not target then return end
	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1000 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 170 and myHero:GetSpellData(_W).toggleState == 1 then
		self:CastW(target)
	end
	if Tocsin.Combo.E:Value() and Ready(_E)and myHero.pos:DistanceTo(target.pos) < 150 then
		self:CastE(target)
	end
end

function DrMundo:Clear()
	if Tocsin.Clear.Key:Value() == false then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team ~= myHero.team then
			if  Tocsin.Clear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1000 then
				self:CastQ(minion)
			end
			if  Tocsin.Clear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 150 then
				self:CastE(minion)
			end
            if  Tocsin.Clear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 165 and myHero:GetSpellData(_W).toggleState == 1 then
                if myHero.health/myHero.maxHealth >= Tocsin.Clear.Health:Value() then
				self:CastW(minion)
                end
			end
            if  Tocsin.Clear.W:Value() and Ready(_W) and myHero:GetSpellData(_W).toggleState == 2 then
                if myHero.health/myHero.maxHealth <= Tocsin.Clear.Health:Value() then
				self:CastW(minion)
                end
			end
		end
	end
end

function DrMundo:Misc()
	local target = GetTarget(1000)
	if not target then return end
		if Tocsin.Combo.Q:Value() and Ready(_Q) and OnScreen(target) then
			local lvl = myHero:GetSpellData(_Q).level
			local Qdmg = (({80, 130, 180, 230, 280 })[lvl] )
			if  Qdmg > target.health then
				self:CastQ(target)
			end
		end
end

function DrMundo:CastQ(target)
	local Qdata = {speed = 1500, delay = 0.25, range = 975 }
	local Qspell = Prediction:SetSpell(Qdata, TYPE_LINEAR, true)
	local pred = Qspell:GetPrediction(target,myHero.pos)
	if  myHero.pos:DistanceTo(target.pos) < 1000 then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() and pred:mCollision() == 0 and pred:hCollision() == 0 then
			EnableOrb(false)
			Control.CastSpell(HK_Q, pred.castPos)
			EnableOrb(true)
		end
	end
end

function DrMundo:CastW(target)
	if  myHero.pos:DistanceTo(target.pos) < myHero.range then
		if myHero.attackData.state == STATE_WINDDOWN then
			if myHero:GetSpellData(_W).toggleState == 1 then
				Control.CastSpell(HK_W)
			end
		end
	end
	if  myHero.pos:DistanceTo(target.pos) > myHero.range then
		if myHero:GetSpellData(_W).toggleState == 1 then
			Control.CastSpell(HK_W)
		end
	end
end

function DrMundo:CastE(target)
	if  myHero.pos:DistanceTo(target.pos) < myHero.range then
		if myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_E)
                Control.Attack(target)
		end
	end
	if  myHero.pos:DistanceTo(target.pos) > myHero.range then
			Control.CastSpell(HK_E)
			Control.Attack(target)
	end
end

function DrMundo:CastR(target)
	if  myHero.pos:DistanceTo(target.pos) < 500 then
			Control.CastSpell(HK_R)
	end
end

function DrMundo:AutoW()
	if myHero:GetSpellData(_W).toggleState == 2 then
		Control.CastSpell(HK_W)
	end
end
-------Checklast hitQ and Clear
function DrMundo:LastHit()
	if Tocsin.LastHit.UseQ:Value() == false then return end
	local level = myHero:GetSpellData(_Q).level
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if  minion.team == 200 then
		local Qdamage = (({80, 130, 180, 230, 280})[level])
    		if  Tocsin.LastHit.UseQ:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1000 then
      			if Qdamage >= self:HpPred(minion, 0.5) then
					EnableOrb(false)
					self:CastQ(minion)
					EnableOrb(true)
				end
			end
		end
	end
end

function DrMundo:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function DrMundo:Draw()
	if Tocsin.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1100, 3,  Draw.Color(255,255, 162, 000)) end
	if Tocsin.Draw.CT:Value() then
		local textPos = myHero.pos:To2D()
		if Tocsin.Clear.Key:Value() then
			Draw.Text("Clear: On", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("Clear: Off", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 225, 000, 000)) 
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
	else print ("Tocsin doesn't support "..myHero.charName.." shutting down...") return
	end
end)