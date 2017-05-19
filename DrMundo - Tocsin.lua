class "DrMundo"
--to do jungle clear, last hit with q, and lane clear


function DrMundo:__init()
	if myHero.charName ~= "DrMundo" then return end
PrintChat("DrMundo - Tocsin loaded")
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

	Q = {delay = 0.250, radius = 250, range = 975, speed = 1750, Collision = true}
	W = {delay = 0.250, radius = 250, range = 160}
	E = {delay = 0.250, range = 150}
	R = {delay = 0.250}
end

function DrMundo:LoadMenu()

--Main Menu

self.Menu = MenuElement({type = MENU, id = "DrMundo", name = "DrMundo", leftIcon = Icons["DrMundoIcon"]})

--Combo Settings Menu

self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
self.Menu.Combo:MenuElement({type = SPACE, name = "Infected Cleaver", leftIcon = Icons["Q"]})
self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
self.Menu.Combo:MenuElement({type = SPACE, name = "Burning Agony", leftIcon = Icons["W"]})
self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
self.Menu.Combo:MenuElement({type = SPACE, name = "Masochism", leftIcon = Icons["E"]})
self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})

--Harass Settings Menu

self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
self.Menu.Harass:MenuElement({type = SPACE, name = "Q", leftIcon = Icons["Q"]})
self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})

--Drawings Settings Menu
self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
self.Menu.Drawings:MenuElement({id = "drawE", name = "Draw E Range", value = true})
end

function DrMundo:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			self:Harass()
		end
	
end

function DrMundo:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawings.drawE:Value())then
		Draw.Circle(myHero, E.range, 3, Draw.Color(225, 225, 0, 10))
	end
end

function DrMundo:Combo()
	local qtarg = _G.SDK.TargetSelector:GetTarget(950)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q)then
			self:CastQ(qtarg)
		end

	local wtarg = _G.SDK.TargetSelector:GetTarget(160)
		if wtarg and self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 1 then
			Control.CastSpell(HK_W)
		end

	local etarg = _G.SDK.TargetSelector:GetTarget(E.range)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E)then
			local castPosition = etarg
			self:CastE(castPosition)
		end
	local otarg = _G.SDK.TargetSelector:GetTarget(950)
		if not otarg and self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W)
		end

end

function DrMundo:Harass()
	local qtarg = _G.SDK.TargetSelector:GetTarget(950)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q)then
			self:CastQ(qtarg)
		end
end

--add last hit Q for when behind 

function DrMundo:CastQ(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=Q.range then
				local pred=target:GetPrediction(Q.speed,Q.delay)
				Control.CastSpell(HK_Q,pred)
			end
		end
	end
return false
end

function DrMundo:CastW(target)
	if target then
		if not target.dead and not target.isImmune then
			if myHero:GetSpellData(_W).toggleState == 1 and target.distance<=W.range then
				Control.CastSpell(HK_W)
			end
		end
	end
return false
end

function DrMundo:CastE(position)
	if position then
		Control.SetCursorPos(position)
		Control.CastSpell(HK_E, position)
	end
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