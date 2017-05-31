class "Riven"
 
require = 'DamageLib'

function Riven:__init()
	if myHero.charName ~= "Riven" then return end
PrintChat("Riven - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["RivenIcon"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/3/30/Riven_OriginalLoading.jpg",
["Q"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/c/c3/Broken_Wings.png",
["W"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/9/97/Ki_Burst.png",
["E"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/e/e9/Valor.png",
["R"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/5/58/Blade_of_the_Exile.png",
["EXH"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/4/4a/Exhaust.png"
}

function Riven.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Riven:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Riven", name = "Riven", leftIcon = Icons["RivenIcon"]})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
	self.Menu.Combo:MenuElement({id = "Exhaust", name = "Use Exhaust", value = false, leftIcon = Icons.EXH})
--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})

--[[LastHit 

	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.LastHit:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	
--]]
--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.JungleClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.JungleClear:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
 

--misc
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
		if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
			self.Menu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true})
		end

--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawW", name = "Draw W Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
end

function Riven:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		end
	self:Misc()
end

function Riven:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawW:Value())then
		Draw.Circle(myHero, W.range, 3, Draw.Color(255, 225, 255, 10))
	end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, 440, 3, Draw.Color(225, 225, 0, 10))
	end
end
--Combo aka spacebar
function Riven:Combo()
	if _G.SDK.TargetSelector:GetTarget(700) == nil then return end
	
	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(qtarg)
	end
	
	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:CastR(rtarg)
    end
 	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:Wings(ztarg)
    end
    if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
		self:Exhaust(xtarg)
	end
end

function Riven:Harass() 
	if _G.SDK.TargetSelector:GetTarget(700) == nil then return end
	
	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(qtarg)
	end
		
end

function Riven:JungleClear()
  	if self:GetValidMinion(620) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 or 200 then
			if self:IsValidTarget(minion,620) and myHero.pos:DistanceTo(minion.pos) < 620 and self.Menu.JungleClear.E:Value() and self:CanCast(_E) then
				Control.CastSpell(HK_E,minion.pos)
			break
			end    		
			if self:IsValidTarget(minion,260) and myHero.pos:DistanceTo(minion.pos) < 260 and self.Menu.JungleClear.W:Value() and self:CanCast(_W) then
				Control.CastSpell(HK_W)
			break
			end
			if self:IsValidTarget(minion,440) and myHero.pos:DistanceTo(minion.pos) < 440 and self.Menu.JungleClear.Q:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
				Control.CastSpell(HK_Q,minion.pos)
			break
			end
		end
	end
end

function Riven:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 620 
end

function Riven:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 620 then
        return true
        end
    	end
    	return false
end

function Riven:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end


function Riven:Wings(target)
	local ztarg = _G.SDK.TargetSelector:GetTarget(850)
	if ztarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
			if self:HasBuff(myHero, "rivenwindslashready") then
				if ztarg.distance<=850 and ztarg.health/ztarg.maxHealth <= 0.23 then
					local pred=ztarg:GetPrediction(R.speed,R.delay)
					Control.CastSpell(HK_R,pred)
				end
			end
	end

end

function Riven:Exhaust(target)
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

function Riven:HasBuff(unit, buffname)
for i = 0, unit.buffCount do
local buff = unit:GetBuff(i)
if buff.name == buffname and buff.count > 0 then 
return true
end
end
return false
end

function Riven:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 260 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

LastCancel = Game.Timer()
function Riven:CastQ(target)
    local qrange = 440 --myHero:GetSpellData(_Q).range
    local qtarg = _G.SDK.TargetSelector:GetTarget(qrange)
    if qtarg then
        if qtarg.dead or qtarg.isImmune then return end
        if myHero.pos:DistanceTo(qtarg.pos) < myHero.range then
            if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) and myHero.attackData.state == STATE_WINDDOWN then
                Control.CastSpell(HK_Q,qtarg)
                if Game.Timer() - LastCancel > 0.15 then
                LastCancel = Game.Timer()
                    DelayAction(function()
                    local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
                    Control.Move(Vec)
                    end, 0.15)
                end
            end
        else
            if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
                Control.CastSpell(HK_Q,qtarg) 
                if Game.Timer() - LastCancel > 0.15 then
                LastCancel = Game.Timer()
                    DelayAction(function()
                    local Vec = Vector(myHero.pos):Normalized() * - (myHero.boundingRadius*1.1)
                    Control.Move(Vec)
                    end, 0.15)
                end
            end
        end
    end
end

function Riven:CastW(target) 
	local wtarg = _G.SDK.TargetSelector:GetTarget(260)
	if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		Control.CastSpell(HK_W)
	end
end
				

function Riven:CastE(target)
	local etarg = _G.SDK.TargetSelector:GetTarget(620)
	if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		local pred=etarg:GetPrediction(E.speed,E.delay)
		Control.CastSpell(HK_E,pred)
	end
end


function Riven:CastR(target)
    local rtarg = _G.SDK.TargetSelector:GetTarget(620)
    if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) and not self:HasBuff(myHero, "rivenwindslashready") then
    	if self:CountEnemys(260) >= self.Menu.Combo.ER:Value() then
    		Control.CastSpell(HK_R)
      	end
    end
end

--KS
function Riven:Misc()
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

function Riven:GetAllyHeroes()
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

function Riven:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Riven:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Riven()
end