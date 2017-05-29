if myHero.charName ~= "Gragas" then return end
PrintChat("Sofie's Gragas fix - changed to IC Orbwalker and a few other changes by Tocsin")

require ("DamageLib")

-- Spells
local Spells = {
		Q = {range = 850, delay = 0.25, speed = 1000, width = 110},
		W = {range = 850, delay = 1, speed = 828},
		E = {range = 600, delay = 0.25, speed = 500, width = 50},
		R = {range = 1000, delay = 0.25, speed = 200, width = 120},
}

-- Menú
Menu = MenuElement({type = MENU, id = "Siar - Gragas", name = "Siar - Gragas", leftIcon="http://2.bp.blogspot.com/-IZcNPdC8bWg/VEllEofRtjI/AAAAAAAAbWw/B9qPy88Islg/s1600/Gragas_Square_0.png"})

-- Combo
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
Menu.Combo:MenuElement({id = "REnemy", name = "Min. Enemies around to cast R", value = 2, min  = 1, max = 5})

-- Harass
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Farm
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Ks
Menu:MenuElement({type = MENU, id = "Ks", name = "KillSteal Settings"})
Menu.Ks:MenuElement({id = "KsQ", name = "Use Q", value = true})
Menu.Ks:MenuElement({id = "Recall", name = "Don't Ks during Recall", value = true})
Menu.Ks:MenuElement({id = "Disabled", name = "Don't Ks", value = false})

-- Draw
Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
Menu.Draw:MenuElement({id = "DrawE", name = "Draw E", value = true})
Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
Menu.Draw:MenuElement({id = "All", name = "Disable All", value = true})

-- Tick | KillSteal | Cast
Callback.Add('Tick', function()
	if not myHero.dead then
		KillSteal()
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			Combo()
		end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			Harass()
		end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			Farm()
		end
		Misc()
	end
end)


function Misc()
     for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
            if myHero:GetSpellData(5).name == "SummonerDot" and Menu.Ks.KsQ:Value() and IsReady(SUMMONER_2) then
                if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end

            if myHero:GetSpellData(4).name == "SummonerDot" and Menu.Ks.KsQ:Value() and IsReady(SUMMONER_1) then
                if IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
end

function KillSteal()
	if Menu.Ks.Disabled:Value() or (IsRecalling() and Menu.Ks.Recall:Value()) then return end
	for K, Enemy in pairs(GetEnemyHeroes()) do
		if Menu.Ks.KsQ:Value() and IsReady(_Q) then
			local qPos = Enemy:GetPrediction(Spells.Q.Speed, Spells.Q.Delay)
			if getdmg("Q", Enemy, myHero) > Enemy.health and IsValidTarget(myHero, Spells.Q.Range, false, qPos) then
				CastQ(qPos)
			end
		end
	end
end

function CastQ(target)
	local target = GetTarget(Spells.Q.Range)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=Spells.Q.range then
				local pred=target:GetPrediction(Spells.Q.speed,Spells.Q.delay)
				Control.CastSpell(HK_Q,pred)
			end
		end
	end
return false
end


function CastQF(qPos)
	Control.CastSpell(HK_Q, qPos)
end

function CastW(target)
	if target then
		if not target.dead and not target.isImmune and CanCast(_W) then
			if target.distance<=225 then
				Control.CastSpell(HK_W)
			end
		end
	end
return false
end

function CastE(target)
	local target = GetTarget(Spells.E.Range)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=Spells.E.range then
				local pred=target:GetPrediction(Spells.E.speed,Spells.E.delay)
				Control.CastSpell(HK_E,pred)
			end
		end
	end
return false
end

function CastEF(ePos)
	Control.CastSpell(HK_E, ePos)
end

function CastR(target)
	local target = GetTarget(Spells.R.Range)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=Spells.R.range and target.health/target.maxHealth <= 0.25 then
				local pred=target:GetPrediction(Spells.R.speed,Spells.R.delay)
					Control.CastSpell(HK_R,pred)
			end
		end
	end
return false
end

function CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

-- Combo | Harass | Farm

function Combo()
	if Menu.Combo.ComboE:Value() and CanCast(_E) then
		CastE(ePos)
	end

	if Menu.Combo.ComboW:Value() and CanCast(_W) then
		CastW(myHero)
	end

	if Menu.Combo.ComboQ:Value() and CanCast(_Q) then
		CastQ(qPos)
	end

	if Menu.Combo.ComboR:Value() and GetEnemyCount() >= Menu.Combo.REnemy:Value() and IsReady(_R) then
		CastR(rpos)
	end

end

function Harass()
	if (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value() / 100) then
		if Menu.Harass.HarassQ:Value() then
			CastQ(qPos)
		end
		if Menu.Harass.HarassE:Value() then
			CastE(ePos)
		end
	end
end

function Farm()
	if (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value() / 100) then
		if GetValidMinion(Spells.Q.range) == false then return end
  		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
    	if  minion.team == 300 or 200 then
    		if IsValidTarget(minion,300) and Menu.Farm.FarmW:Value() and IsReady(_W) then
				CastW(myHero)
			end
			if Menu.Farm.FarmQ:Value() and IsReady(_Q) then
				local qPos = minion:GetPrediction(Spells.Q.speed, Spells.Q.delay)
					if IsValidTarget(myHero, Spells.Q.range, false, qPos) then
						CastQF(qPos)
					end
			end
			if Menu.Farm.FarmE:Value() and IsReady(_E) then
				local ePos = minion:GetPrediction(Spells.E.speed, Spells.E.delay)
				if IsValidTarget(myHero, Spells.E.range, false, ePos) then
					CastEF(ePos)
				end
			end
		end
	end
	end
end

-- Things
function GetTarget(range)
  local target = nil
  local lessCast = 0
  local GetEnemyHeroes = GetEnemyHeroes()
  for i = 1, #GetEnemyHeroes do
  	local Enemy = GetEnemyHeroes[i]
    if IsValidTarget(Enemy, range, false, myHero.pos) then
      local Armor = (100 + Enemy.magicResist) / 100
      local Killable = Armor * Enemy.health
      if Killable <= lessCast or lessCast == 0 then
        target = Enemy
        lessCast = Killable
      end
    end
  end
  return target
end

function GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Spells.Q.range then
        return true
        end
    	end
    	return false
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function IsBuffed(target, BuffName)
	for K, Buff in pairs(GetBuffs(target)) do
		if Buff.name == BuffName then
			return true
		end
	end
	return false
end

function GetAllyHeroes()
	AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function GetEnemyCount(range)
	local count = 0
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team then
			count = count + 1
		end
	end
	return count
end

function GetEnemyHeroes()
	EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end

function GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function IsImmune(unit)
	for K, Buff in pairs(GetBuffs(unit)) do
		if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" or Buff.name == "zhonyasringshield" then 
            return true
        end
	end
	return false
end

function IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from) < range 
end

function IsReady(slot)
	assert(type(slot) == "number", "IsReady > invalid argument: expected number got " ..type(slot))
	return (myHero:GetSpellData(slot).level >= 1 and myHero:GetSpellData(slot).currentCd == 0 and myHero:GetSpellData(slot).mana <= myHero.mana)
end

function OnDraw()
	if Menu.Draw.All:Value() then return end

	if Menu.Draw.DrawQ:Value() and IsReady(_Q) then
		Draw.Circle(myHero.pos, Spells.Q.range, 1, Draw.Color(255, 255, 255, 255))
	end

	if Menu.Draw.DrawE:Value() and IsReady(_E) then
		Draw.Circle(myHero.pos, Spells.E.range, 1, Draw.Color(255, 255, 255, 255))
	end

	if Menu.Draw.DrawR:Value() and IsReady(_R) then
		Draw.Circle(myHero.pos, Spells.R.range, 1, Draw.Color(255, 255, 255, 255))
	end
end