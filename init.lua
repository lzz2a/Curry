--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    tobiware typ hsi
--]]

getgenv().Timing = 0.3
local a
a = {
	cache = {},
	load = function(b)
		if not a.cache[b] then
			a.cache[b] = { c = a[b]() }
		end
		return a.cache[b].c
	end,
}
do
	function a.a()
		local b
		local c = function(c, ...)
			local d = b
			b = nil
			c(...)
			b = d
		end
		local d, e = function()
			while true do
				c(coroutine.yield())
			end
		end, {}
		e.__index = e
		function e.new(f, g)
			return setmetatable({ _connected = true, _signal = f, _fn = g, _next = false }, e)
		end
		function e:Disconnect()
			self._connected = false
			if self._signal._handlerListHead == self then
				self._signal._handlerListHead = self._next
			else
				local f = self._signal._handlerListHead
				while f and f._next ~= self do
					f = f._next
				end
				if f then
					f._next = self._next
				end
			end
		end
		setmetatable(e, {
			__index = function(f, g)
				error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(g)), 2)
			end,
			__newindex = function(f, g, h)
				error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(g)), 2)
			end,
		})
		local f = {}
		f.__index = f
		function f.new()
			local g = setmetatable({ _handlerListHead = false }, f)
			return g
		end
		function f.Connect(g, h)
			local i = e.new(g, h)
			if g._handlerListHead then
				i._next = g._handlerListHead
				g._handlerListHead = i
			else
				g._handlerListHead = i
			end
			return i
		end
		function f.DisconnectAll(g)
			g._handlerListHead = false
		end
		function f.Fire(g, ...)
			local h = g._handlerListHead
			while h do
				if h._connected then
					if not b then
						b = coroutine.create(d)
						coroutine.resume(b)
					end
					task.spawn(b, h._fn, ...)
				end
				h = h._next
			end
		end
		function f.Wait(g)
			local h, i = (coroutine.running())
			i = g:Connect(function(...)
				i:Disconnect()
				task.spawn(h, ...)
			end)
			return coroutine.yield()
		end
		function f.Once(g, h)
			local i
			i = g:Connect(function(...)
				if i._connected then
					i:Disconnect()
				end
				h(...)
			end)
			return i
		end
		setmetatable(f, {
			__index = function(g, h)
				error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(h)), 2)
			end,
			__newindex = function(g, h, i)
				error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(h)), 2)
			end,
		})
		return f
	end
	function a.b()
		local b, c = a.load("a"), {}
		c.__index = c
		local d
		function c.new()
			if d then
				return d
			end
			local e = (setmetatable({}, c))
			do
				e._playerObject = game:GetService("Players").LocalPlayer
			end
			e:Init()
			d = e
			return e
		end
		function c.Init(e)
			if e._playerObject then
				e.ShootingStarted = b.new()
				if e._playerObject.Character then
					e:SetupCharacter(e._playerObject.Character)
				end
				e._playerObject.CharacterAdded:Connect(function(f)
					e:SetupCharacter(f)
				end)
			end
		end
		function c.SetupCharacter(e, f)
			f:GetAttributeChangedSignal("Shooting"):Connect(function()
				if f:GetAttribute("Shooting") == true then
					e.ShootingStarted:Fire()
				end
			end)
		end
		function c.GetTeammates(e)
			local f = {}
			return f
		end
		function c.GetHumanoid(e)
			if e._playerObject then
				local f = e._playerObject.Character
				if f then
					local g = f:WaitForChild("Humanoid")
					return g
				end
			end
			return nil
		end
		return c
	end
	function a.c()
		local b, c, d = game:GetService("VirtualInputManager"), {}, a.load("b").new()
		function c.StopShooting(e)
			b:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end
		function c:Init()
			d.ShootingStarted:Connect(function()
				local e = game:GetService("Stats")
				local f = e.Network.ServerStatsItem["Data Ping"]:GetValue()
				if getgenv().Shots[c.LastShotType] then
					task.wait(getgenv().Shots[c.LastShotType] - (f / 1000))
					c:StopShooting()
					warn(`[ShotService.lua]: Timed shot for type: {c.LastShotType}`)
				end
			end)
			local e
			e = hookmetamethod(game, "__namecall", function(f, ...)
				local g = { ... }
				if tostring(f) == "Actions" then
					local h = g[1]
					if h and h.ShotType then
						c.LastShotType = h.ShotType
					end
				end
				return e(f, ...)
			end)
			warn("[ShotService.lua]: started")
		end
		return c
	end
end
getgenv().Shots = { Normal = 0.39, SemiSlow = 0.47, Fast = 0.31, SuperFast = 0.31 }
if not getgenv().Executed then
	getgenv().Executed = true
	setfpscap(math.huge)
	local b = a.load("c")
	b:Init()
end
