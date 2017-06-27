require 'DamageLib'
require 'Eternal Prediction'

local ScriptVersion = "v1.3"

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

local function GetDistance(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local function GetDistance2D(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2))
end

local function OnScreen(unit)
	return unit.pos:To2D().onScreen;
end
local Grasp = false
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

class "Ezreal"

function Ezreal:__init()
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

function Ezreal:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/5/5a/Mystic_Shot.png" }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/9/9e/Essence_Flux.png" }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/f/fb/Arcane_Shift.png" }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/0/02/Trueshot_Barrage.png" }
end

function Ezreal:LoadMenu()
	Tocsin = MenuElement({type = MENU, id = "Ezreal_Tocsin", name = "Ezreal_Tocsin"})



	Tocsin:MenuElement({name = "Ezreal", drop = {ScriptVersion}, leftIcon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/e/ec/Ezreal_OriginalLoading.jpg"})
	
	--Combo

	Tocsin:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Tocsin.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Combo:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Combo:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Combo:MenuElement({id = "R", name = "Use [R]", value = true, leftIcon = R.icon})
	
	--Clear

	Tocsin:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
	Tocsin.Clear:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Clear:MenuElement({id = "E", name = "Use [E]", value = true, leftIcon = E.icon})
	Tocsin.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear [%]", value = 0.30, min = 0.05, max = 1, step = 0.01})
	
	--Harass

	Tocsin:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Harass:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	Tocsin.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass [%]", value = 0.30, min = 0.05, max = 1, step = 0.01})
	
	--Misc

	Tocsin:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	Tocsin.Misc:MenuElement({id = "Qks", name = "Killsecure [Q]", value = true, leftIcon = Q.icon})
	Tocsin.Misc:MenuElement({id = "Wks", name = "Killsecure [W]", value = true, leftIcon = W.icon})
	Tocsin.Misc:MenuElement({id = "Rks", name = "Killsecure [R]", value = true, leftIcon = R.icon})
	Tocsin.Misc:MenuElement({id = "Rkey", name = "Semi-Manual [R] Key [?]", key = string.byte("T"), tooltip = "Manually select your target before pressing the key"})
	

 	--Eternal Prediction

	Tocsin:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
	Tocsin.Pred:MenuElement({type = SPACE, id = "Pred Info", name = "If you go too high it wont fire"})
	Tocsin.Pred:MenuElement({id = "Chance", name = "Prediction Hitchance", value = 0.175, min = 0.05, max = 1, step = 0.025})
	
	--Draw

	Tocsin:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	Tocsin.Draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = true, leftIcon = W.icon})
	Tocsin.Draw:MenuElement({id = "DMG", name = "Draw Combo Damage", value = true})
end

function Ezreal:Tick()
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
end

function Ezreal:Combo()
	local target = GetTarget(1300)
	if not target then return end
	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1000 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 1000 then
		self:CastW(target)
	end
	if Tocsin.Combo.E:Value() and Ready(_E)and myHero.pos:DistanceTo(target.pos) < 1100 then
		self:CastE(target)
	end
	if Tocsin.Combo.R:Value() and Ready(_R) then--and OnScreen(target) then
		if  myHero.pos:DistanceTo(target.pos) > 800 then
			local lvl = myHero:GetSpellData(_R).level
			local Rdmg = (({350, 500, 650})[lvl] )
			if  Rdmg > target.health *1.1 + target.shieldAP then
				self:CastR(target)
			end
		end
	end

end

function Ezreal:Harass()
	local target = GetTarget(1200)
	if myHero.mana/myHero.maxMana < Tocsin.Harass.Mana:Value() then return end
	if not target then return end
	if Tocsin.Harass.Q:Value() and Ready(_Q)and myHero.pos:DistanceTo(target.pos) < 1000 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
		self:CastQ(target)
	end
	if Tocsin.Harass.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 1000 then
		self:CastW(target)
	end
end

function Ezreal:Clear()
	if myHero.mana/myHero.maxMana < Tocsin.Clear.Mana:Value() then return end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team ~= myHero.team then
			if  Tocsin.Clear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 1000 then
				self:CastQ(minion)
			end
			if  Tocsin.Clear.E:Value() and Ready(_E) and myHero.pos:DistanceTo(minion.pos) < 1000 then
				self:CastE(minion)
			end
		end
	end
end

function Ezreal:Misc()
	local target = GetTarget(20000)
	if not target then return end
		if Tocsin.Misc.Rkey:Value() and Ready(_R) then
		self:CastR(target)
	end
end

function Ezreal:CastQ(target)
	local Qdata = {speed = 1200, delay = 0.25, range = 1150, width = 60}
	local Qspell = Prediction:SetSpell(Qdata, TYPE_LINEAR, true)
	local pred = Qspell:GetPrediction(target,myHero.pos)
	if  myHero.pos:DistanceTo(target.pos) < 1150 then
		if myHero.attackData.state == STATE_WINDDOWN then
			if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() and pred:mCollision() == 0 and pred:hCollision() == 0 then
				EnableOrb(false)
				Grasp = true
				Control.CastSpell(HK_Q, pred.castPos)
				DelayAction(function() Grasp = false EnableOrb(true) end, 0.3)
			end
		end
	end
	if  myHero.pos:DistanceTo(target.pos) > myHero.range then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() and pred:mCollision() == 0 and pred:hCollision() == 0 then
			EnableOrb(false)
			Grasp = true
			Control.CastSpell(HK_Q, pred.castPos)
			DelayAction(function() Grasp = false EnableOrb(true) end, 0.3)
		end
	end
end

function Ezreal:CastW(target)
	local Wdata = {speed = 1200, delay = 0.25, range = 950, width = 80}
	local Wspell = Prediction:SetSpell(Wdata, TYPE_LINEAR, true)
	local pred = Wspell:GetPrediction(target,myHero.pos)
	if  myHero.pos:DistanceTo(target.pos) < myHero.range then
		if myHero.attackData.state == STATE_WINDDOWN then
			if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() then
				EnableOrb(false)
				Grasp = true
				Control.CastSpell(HK_W, pred.castPos)
				DelayAction(function() Grasp = false EnableOrb(true) end, 0.3)
			end
		end
	end
	if  myHero.pos:DistanceTo(target.pos) > myHero.range then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() then
			EnableOrb(false)
			Grasp = true
			Control.CastSpell(HK_W, pred.castPos)
			DelayAction(function() Grasp = false EnableOrb(true) end, 0.3)
		end
	end
end

function Ezreal:CastE(target)
	local Edata = {speed = 2000, delay = 0.25,range = 450 }
	if  myHero.pos:DistanceTo(target.pos) < myHero.range then
		if myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_E)
		end
	end
	if  myHero.pos:DistanceTo(target.pos) > myHero.range then
			Control.CastSpell(HK_E)
	end
end

function Ezreal:CastR(target)
	local Rdata = {speed = 2000, delay = 1.05, range = 20000, width = 160 }
	local Rspell = Prediction:SetSpell(Rdata, TYPE_LINE, true)
	local pred = Rspell:GetPrediction(target, myHero.pos)
	if OnScreen(target) then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() then
			EnableOrb(false)
			Grasp = true
			Control.CastSpell(HK_R, pred.castPos)
			DelayAction(function() Grasp = false EnableOrb(true) end, 0.80)
		end
	end 
	if not OnScreen(target) then
		if pred and pred.hitChance >= Tocsin.Pred.Chance:Value() then
			EnableOrb(false)
			Grasp = true
			Control.SetCursorPos(pred.castPos:ToMM().x,pred.castPos:ToMM().y)
			Control.KeyDown(HK_R)
			Control.KeyUp(HK_R)
			DelayAction(function() Grasp = false EnableOrb(true) end, 0.80)
		end
	end
end

function Ezreal:GetComboDamage(unit)
	local Total = 0
	if Ready(_Q) then
		local Qlvl = myHero:GetSpellData(_Q).level
		local Qdmg = (({35, 55, 75, 95, 115})[Qlvl] + myHero.totalDamage)
		Total = Total + Qdmg
	end
	if Ready(_W) then
		local Wlvl = myHero:GetSpellData(_W).level
		local Wdmg = (({70, 115, 160, 205, 250})[Wlvl] + .8 * myHero.ap) --70 / 115 / 160 / 205 / 250 (+ 80% AP)
		Total = Total + Wdmg
	end
	if Ready(_R) then
		local Rlvl = myHero:GetSpellData(_R).level
		local Rdmg = (({350, 500, 650})[Rlvl] + myHero.bonusDamage)
		Total = Total + Rdmg
	end
	return Total
end

function Ezreal:Draw()
	if Tocsin.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1150, 3,  Draw.Color(255,255, 162, 000)) end
	if Tocsin.Draw.DMG:Value() then
		for i = 1, Game.HeroCount() do
			local enemy = Game.Hero(i)
			if enemy and enemy.isEnemy and not enemy.dead then
				if OnScreen(enemy) then
				local rectPos = enemy.hpBar
					if self:GetComboDamage(enemy) < enemy.health then
						Draw.Rect(rectPos.x , rectPos.y ,(tostring(math.floor(self:GetComboDamage(enemy)/enemy.health*100)))*((enemy.health/enemy.maxHealth)),10, Draw.Color(150, 000, 000, 255)) 
					else
						Draw.Rect(rectPos.x , rectPos.y ,((enemy.health/enemy.maxHealth)*100),10, Draw.Color(150, 255, 255, 000)) 
					end
				end
			end
		end
	end
end

Callback.Add("Load", function()
	if myHero.charName ~= "Ezreal" then return end
	if not _G.Prediction_Loaded then return end
	if _G[myHero.charName] then
		_G[myHero.charName]()
		print("Tocsin "..myHero.charName.." "..ScriptVersion.." Loaded")
	else print ("Tocsin doesn't support "..myHero.charName.." shutting down...") return
	end
end)