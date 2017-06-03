class "DrMundo"
 
require = 'DamageLib'

function DrMundo:__init()
	if myHero.charName ~= "DrMundo" then return end
PrintChat("DrMundo - Tocsin loaded v1.0")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["DrMundoIcon"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/9/93/Dr._Mundo_OriginalLoading.jpg",
["Q"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/f/f2/Infected_Cleaver.png",
["W"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/5/5d/Burning_Agony.png",
["E"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/9/95/Masochism.png"
}

function DrMundo.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function DrMundo:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "DrMundo", name = "DrMundo", leftIcon = Icons["DrMundoIcon"]})

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

--LastHit 

	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	

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

function DrMundo:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
    		self:LastHit()
		end
	self:Misc()
end

function DrMundo:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawW:Value())then
		Draw.Circle(myHero, W.range, 3, Draw.Color(255, 225, 255, 10))
	end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, 975, 3, Draw.Color(225, 225, 0, 100))
	end
end
--Combo aka spacebar
function DrMundo:Combo()
	--if _G.SDK.TargetSelector:GetTarget(1000) == false then return end
	if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
    	self:CastQ(qtarg)
    end

	if self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end

	if self.Menu.Combo.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end

	if self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	self:CastR(rtarg)
    end

    if self.Menu.Combo.Exhaust:Value() and not self:CanCast(_E) and not self:CanCast(_Q) then
		self:Exhaust(xtarg)
	end
end

function DrMundo:Harass() 
	if _G.SDK.TargetSelector:GetTarget(970) == nil then self:JungleW() return end
	
	if self.Menu.Harass.UseQ:Value() and self:CanCast(_Q) then
		self:CastQ(qtarg)
	end

	if self.Menu.Harass.UseE:Value() and self:CanCast(_E) then
		self:CastE(etarg)
	end

	if self.Menu.Harass.UseW:Value() and self:CanCast(_W) then
		self:CastW(wtarg)
	end
		
end

function DrMundo:JungleClear()
  	if self:GetValidMinion(970) == false then self:JungleW() return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 or 200 then
			if self:IsValidTarget(minion,150) and myHero.pos:DistanceTo(minion.pos) < 150 and self.Menu.JungleClear.E:Value() and self:CanCast(_E) then
				Control.CastSpell(HK_E,minion.pos)
				Control.Attack(minion)
			break
			end    		
			if self:IsValidTarget(minion,970) and myHero.pos:DistanceTo(minion.pos) < 970 and self.Menu.JungleClear.Q:Value() and self:CanCast(_Q) then
				Control.CastSpell(HK_Q,minion.pos)
			break
			end
			if self:IsValidTarget(minion,260) and myHero.pos:DistanceTo(minion.pos) < 260 and self.Menu.JungleClear.W:Value() and self:CanCast(_W) and myHero:GetSpellData(_W).toggleState == 1 then
				Control.CastSpell(HK_W)
			break
			end
		end
	end
end

function DrMundo:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 620 
end

function DrMundo:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 620 then
        return true
        end
    	end
    	return false
end

function DrMundo:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function DrMundo:JungleW()
  	if self:GetValidMinion(Q.range) == false then
  		if self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W)
		end	
	end
end

function DrMundo:Exhaust(target)
	local xtarg = _G.SDK.TargetSelector:GetTarget(550)
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

function DrMundo:HasBuff(unit, buffname)
for i = 0, unit.buffCount do
local buff = unit:GetBuff(i)
if buff.name == buffname and buff.count > 0 then 
return true
end
end
return false
end

function DrMundo:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 620 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function DrMundo:CastQ(target)
    local qrange = 975 
    local qtarg = _G.SDK.TargetSelector:GetTarget(qrange)
    if qtarg then
        if qtarg.dead or qtarg.isImmune then return end
        if myHero.pos:DistanceTo(qtarg.pos) < 975 then    
            if self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
                local pred=qtarg:GetPrediction(Q.speed,.25 + Game.Latency()/1000)
                Control.CastSpell(HK_Q,pred)
            end
        end
    end
end

function DrMundo:CastW(target) 
	local wtarg = _G.SDK.TargetSelector:GetTarget(500)
	if wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) and myHero:GetSpellData(_W).toggleState == 1 then
		Control.CastSpell(HK_W)
	else
	if not wtarg and self.Menu.Combo.UseW:Value() and self:CanCast(_W) and myHero:GetSpellData(_W).toggleState == 2 then
	Control.CastSpell(HK_W)
	end
end
end

function DrMundo:OffW(target)
	local otarg = _G.SDK.TargetSelector:GetTarget(500)
	if not otarg and self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W)
	end	
	-- body
end

function DrMundo:CastE(target)
	local etarg = _G.SDK.TargetSelector:GetTarget(150)
	if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
		if myHero.pos:DistanceTo(etarg.pos) < 150 then
			Control.CastSpell(HK_E)
			Control.Attack(etarg)
		end
	end
end


function DrMundo:CastR(target)
    local rtarg = _G.SDK.TargetSelector:GetTarget(970)
    if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) and myHero.health/myHero.maxHealth <= .30 then
    	if self:CountEnemys(970) >= self.Menu.Combo.ER:Value() then
    		Control.CastSpell(HK_R)
      	end
    end
end

function DrMundo:LastHit()
	if self.Menu.LastHit.UseQ:Value() == false then return end
	local level = myHero:GetSpellData(_Q).level
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if  minion.team == 200 then
		local Qdamage = (({80, 130, 180, 230, 280})[level])
    		if self:IsValidTarget(minion,970) and myHero.pos:DistanceTo(minion.pos) < 970 and minion.isEnemy then
      			if Qdamage >= self:HpPred(minion, 0.5) and self:CanCast(_Q) then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end
 

--KS
function DrMundo:Misc()
	if _G.SDK.TargetSelector:GetTarget(600) == nil then return end
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

function DrMundo:GetAllyHeroes()
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

function DrMundo:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function DrMundo:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	DrMundo()
end