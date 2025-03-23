local rs = game:GetService("RunService")

local p = Instance.new("Part")
p.Size = Vector3.new(200, 1, 200)
p.Anchored = true
p.Position = Vector3.new(0, 0, 0)
p.Material = Enum.Material.Concrete
p.Color = Color3.new(0.2, 0.2, 0.2)
p.Parent = workspace

local gY = 5

local function cv(x, y, z, w)
	return {x = x, y = y, z = z, w = w}
end

local function pv(v)
	local d = 3
	local factor = d / (d - v.w)
	return Vector3.new(v.x * factor, v.y * factor, v.z * factor)
end

local function at(pos3D, t)
	local cf = CFrame.Angles(math.sin(t * 0.5) * 0.5, math.cos(t * 0.5) * 0.5, math.sin(t * 0.3) * 0.5)
	return (cf * CFrame.new(pos3D)).p
end

local function genT(off)
	local m = Instance.new("Model")
	m.Name = "Tesseract"
	m.Parent = workspace

	local bv = {}
	local v = {}
	local vp = {}
	local ep = {}
	local sf = 5

	for i = 0, 15 do
		local x = (bit32.band(i, 1) == 0) and -1 or 1
		local y = (bit32.band(i, 2) == 0) and -1 or 1
		local z = (bit32.band(i, 4) == 0) and -1 or 1
		local w = (bit32.band(i, 8) == 0) and -1 or 1
		local vert = cv(x, y, z, w)
		table.insert(bv, vert)
		table.insert(v, {x = vert.x, y = vert.y, z = vert.z, w = vert.w})
	end

	for i = 1, #v do
		local pt = Instance.new("Part")
		pt.Shape = Enum.PartType.Ball
		pt.Size = Vector3.new(0.3, 0.3, 0.3)
		pt.Anchored = true
		pt.CanCollide = false
		pt.Material = Enum.Material.Neon
		pt.Color = Color3.new(1, 1, 1)
		pt.Parent = m
		vp[i] = pt
	end

	local function conn(a, b)
		local diff = 0
		if math.abs(a.x - b.x) > 0 then diff = diff + 1 end
		if math.abs(a.y - b.y) > 0 then diff = diff + 1 end
		if math.abs(a.z - b.z) > 0 then diff = diff + 1 end
		if math.abs(a.w - b.w) > 0 then diff = diff + 1 end
		return diff == 1
	end

	for i = 1, #v do
		for j = i + 1, #v do
			if conn(bv[i], bv[j]) then
				local ed = Instance.new("Part")
				ed.Anchored = true
				ed.CanCollide = false
				ed.Material = Enum.Material.Metal
				ed.Color = Color3.new(0.8, 0.8, 0.8)
				ed.Size = Vector3.new(0.1, 0.1, 1)
				ed.Parent = m
				table.insert(ep, {p = ed, i1 = i, i2 = j})
			end
		end
	end

	local ang = 0
	local sp = 0.5
	local tLocal = 0

	rs.Heartbeat:Connect(function(dt)
		tLocal = tLocal + dt
		ang = ang + sp * dt

		for i, base in ipairs(bv) do
			local r = {}
			r.x = base.x * math.cos(ang) - base.w * math.sin(ang)
			r.w = base.x * math.sin(ang) + base.w * math.cos(ang)
			r.y = base.y
			r.z = base.z
			v[i] = r

			local pos = pv(r) * sf
			pos = at(pos, tLocal)
			vp[i].Position = pos + off + Vector3.new(0, gY, 0)
		end

		for _, ed in ipairs(ep) do
			local pos1 = pv(v[ed.i1]) * sf
			local pos2 = pv(v[ed.i2]) * sf
			pos1 = at(pos1, tLocal)
			pos2 = at(pos2, tLocal)
			pos1 = pos1 + off + Vector3.new(0, gY, 0)
			pos2 = pos2 + off + Vector3.new(0, gY, 0)
			local mid = (pos1 + pos2) / 2
			local len = (pos2 - pos1).Magnitude
			ed.p.Size = Vector3.new(0.1, 0.1, len)
			ed.p.CFrame = CFrame.new(mid, pos2)
		end
	end)
end

local function genC(off)
	local m = Instance.new("Model")
	m.Name = "FourDCylinder"
	m.Parent = workspace

	local seg = 24
	local zl = { -1, 1 }
	local wl = { -1, 1 }
	local bv = {}
	local v = {}
	local vp = {}
	local ep = {}
	local sf = 5

	local vi = {}
	for i = 1, #zl do
		vi[i] = {}
		for j = 1, #wl do
			vi[i][j] = {}
			for k = 1, seg do
				local theta = (k - 1) * (2 * math.pi / seg)
				local x = math.cos(theta)
				local y = math.sin(theta)
				local z = zl[i]
				local w = wl[j]
				local vert = cv(x, y, z, w)
				table.insert(bv, vert)
				table.insert(v, {x = vert.x, y = vert.y, z = vert.z, w = vert.w})
				local idx = #bv
				vi[i][j][k] = idx
			end
		end
	end

	for i = 1, #v do
		local pt = Instance.new("Part")
		pt.Shape = Enum.PartType.Ball
		pt.Size = Vector3.new(0.3, 0.3, 0.3)
		pt.Anchored = true
		pt.CanCollide = false
		pt.Material = Enum.Material.Neon
		pt.Color = Color3.new(1, 1, 1)
		pt.Parent = m
		vp[i] = pt
	end

	for i = 1, #zl do
		for j = 1, #wl do
			for k = 1, seg do
				local i1 = vi[i][j][k]
				local i2 = vi[i][j][(k % seg) + 1]
				local ed = Instance.new("Part")
				ed.Anchored = true
				ed.CanCollide = false
				ed.Material = Enum.Material.Metal
				ed.Color = Color3.new(0.8, 0.8, 0.8)
				ed.Size = Vector3.new(0.1, 0.1, 1)
				ed.Parent = m
				table.insert(ep, {p = ed, i1 = i1, i2 = i2})
			end
		end
	end

	for j = 1, #wl do
		for k = 1, seg do
			local i1 = vi[1][j][k]
			local i2 = vi[2][j][k]
			local ed = Instance.new("Part")
			ed.Anchored = true
			ed.CanCollide = false
			ed.Material = Enum.Material.Metal
			ed.Color = Color3.new(0.8, 0.8, 0.8)
			ed.Size = Vector3.new(0.1, 0.1, 1)
			ed.Parent = m
			table.insert(ep, {p = ed, i1 = i1, i2 = i2})
		end
	end

	for i = 1, #zl do
		for k = 1, seg do
			local i1 = vi[i][1][k]
			local i2 = vi[i][2][k]
			local ed = Instance.new("Part")
			ed.Anchored = true
			ed.CanCollide = false
			ed.Material = Enum.Material.Metal
			ed.Color = Color3.new(0.8, 0.8, 0.8)
			ed.Size = Vector3.new(0.1, 0.1, 1)
			ed.Parent = m
			table.insert(ep, {p = ed, i1 = i1, i2 = i2})
		end
	end

	local angXW, angYW, angZW = 0, 0, 0
	local spXW, spYW, spZW = 0.4, 0.6, 0.8
	local tLocal = 0

	rs.Heartbeat:Connect(function(dt)
		tLocal = tLocal + dt
		angXW = angXW + spXW * dt
		angYW = angYW + spYW * dt
		angZW = angZW + spZW * dt

		for i, base in ipairs(bv) do
			local r = {}
			local nx = base.x * math.cos(angXW) - base.w * math.sin(angXW)
			local nw = base.x * math.sin(angXW) + base.w * math.cos(angXW)
			r.x = nx; r.w = nw
			local ny = base.y * math.cos(angYW) - r.w * math.sin(angYW)
			nw = base.y * math.sin(angYW) + r.w * math.cos(angYW)
			r.y = ny; r.w = nw
			local nz = base.z * math.cos(angZW) - nw * math.sin(angZW)
			nw = base.z * math.sin(angZW) + nw * math.cos(angZW)
			r.z = nz; r.w = nw
			v[i] = r
			local pos = pv(r) * sf
			pos = at(pos, tLocal)
			vp[i].Position = pos + off + Vector3.new(0, gY, 0)
		end

		for _, ed in ipairs(ep) do
			local pos1 = pv(v[ed.i1]) * sf
			local pos2 = pv(v[ed.i2]) * sf
			pos1 = at(pos1, tLocal)
			pos2 = at(pos2, tLocal)
			pos1 = pos1 + off + Vector3.new(0, gY, 0)
			pos2 = pos2 + off + Vector3.new(0, gY, 0)
			local mid = (pos1 + pos2) / 2
			local len = (pos2 - pos1).Magnitude
			ed.p.Size = Vector3.new(0.1, 0.1, len)
			ed.p.CFrame = CFrame.new(mid, pos2)
		end
	end)
end

local function gen24(off)
	local m = Instance.new("Model")
	m.Name = "24Cell"
	m.Parent = workspace

	local bv = {}
	local v = {}
	local vp = {}
	local ep = {}
	local sf = 5

	local comb = {
		{1, 2}, {1, 3}, {1, 4},
		{2, 3}, {2, 4}, {3, 4}
	}
	for _, ind in ipairs(comb) do
		local i1, i2 = ind[1], ind[2]
		for s1 = -1, 1, 2 do
			for s2 = -1, 1, 2 do
				local coord = {0, 0, 0, 0}
				coord[i1] = s1
				coord[i2] = s2
				local vert = cv(coord[1], coord[2], coord[3], coord[4])
				table.insert(bv, vert)
				table.insert(v, {x = vert.x, y = vert.y, z = vert.z, w = vert.w})
			end
		end
	end

	for i = 1, #v do
		local pt = Instance.new("Part")
		pt.Shape = Enum.PartType.Ball
		pt.Size = Vector3.new(0.3, 0.3, 0.3)
		pt.Anchored = true
		pt.CanCollide = false
		pt.Material = Enum.Material.Neon
		pt.Color = Color3.new(1, 1, 1)
		pt.Parent = m
		vp[i] = pt
	end

	local function sqd(a, b)
		local dx = a.x - b.x
		local dy = a.y - b.y
		local dz = a.z - b.z
		local dw = a.w - b.w
		return dx*dx + dy*dy + dz*dz + dw*dw
	end

	for i = 1, #bv do
		for j = i + 1, #bv do
			if math.abs(sqd(bv[i], bv[j]) - 2) < 0.001 then
				local ed = Instance.new("Part")
				ed.Anchored = true
				ed.CanCollide = false
				ed.Material = Enum.Material.Metal
				ed.Color = Color3.new(0.8, 0.8, 0.8)
				ed.Size = Vector3.new(0.1, 0.1, 1)
				ed.Parent = m
				table.insert(ep, {p = ed, i1 = i, i2 = j})
			end
		end
	end

	local angXW, angYW, angZW = 0, 0, 0
	local spXW, spYW, spZW = 0.4, 0.6, 0.8
	local tLocal = 0

	local function rot4(vt)
		local x, y, z, w = vt.x, vt.y, vt.z, vt.w
		local nx = x * math.cos(angXW) - w * math.sin(angXW)
		local nw = x * math.sin(angXW) + w * math.cos(angXW)
		x, w = nx, nw
		local ny = y * math.cos(angYW) - w * math.sin(angYW)
		nw = y * math.sin(angYW) + w * math.cos(angYW)
		y, w = ny, nw
		local nz = z * math.cos(angZW) - w * math.sin(angZW)
		nw = z * math.sin(angZW) + w * math.cos(angZW)
		z, w = nz, nw
		return {x = x, y = y, z = z, w = w}
	end

	rs.Heartbeat:Connect(function(dt)
		tLocal = tLocal + dt
		angXW = angXW + spXW * dt
		angYW = angYW + spYW * dt
		angZW = angZW + spZW * dt

		for i, base in ipairs(bv) do
			local r = rot4(base)
			v[i] = r
			local pos = pv(r) * sf
			pos = at(pos, tLocal)
			vp[i].Position = pos + off + Vector3.new(0, gY, 0)
		end

		for _, ed in ipairs(ep) do
			local pos1 = pv(v[ed.i1]) * sf
			local pos2 = pv(v[ed.i2]) * sf
			pos1 = at(pos1, tLocal)
			pos2 = at(pos2, tLocal)
			pos1 = pos1 + off + Vector3.new(0, gY, 0)
			pos2 = pos2 + off + Vector3.new(0, gY, 0)
			local mid = (pos1 + pos2) / 2
			local len = (pos2 - pos1).Magnitude
			ed.p.Size = Vector3.new(0.1, 0.1, len)
			ed.p.CFrame = CFrame.new(mid, pos2)
		end
	end)
end

local function gen600(off)
	local m = Instance.new("Model")
	m.Name = "600Cell"
	m.Parent = workspace

	local tLocal = 0
	local bv = {}
	local v = {}
	local vp = {}
	local ep = {}
	local sf = 5

	local phi = (1 + math.sqrt(5)) / 2
	local iP = 1 / phi

	local function setA()
		for i = 1, 4 do
			for s = -1, 1, 2 do
				local arr = {0, 0, 0, 0}
				arr[i] = s * 2
				table.insert(bv, cv(arr[1], arr[2], arr[3], arr[4]))
			end
		end
	end

	local function setB()
		for s1 = -1, 1, 2 do
			for s2 = -1, 1, 2 do
				for s3 = -1, 1, 2 do
					for s4 = -1, 1, 2 do
						table.insert(bv, cv(s1, s2, s3, s4))
					end
				end
			end
		end
	end

	local function evenPerm(arr)
		local inv = 0
		for i = 1, #arr do
			for j = i + 1, #arr do
				if arr[i] > arr[j] then
					inv = inv + 1
				end
			end
		end
		return inv % 2 == 0
	end

	local function perms(arr)
		local pList = {}
		local function permute(a, l, r)
			if l == r then
				local cp = {unpack(a)}
				if evenPerm(cp) then
					table.insert(pList, cp)
				end
			else
				for i = l, r do
					a[l], a[i] = a[i], a[l]
					permute(a, l + 1, r)
					a[l], a[i] = a[i], a[l]
				end
			end
		end
		permute(arr, 1, #arr)
		return pList
	end

	local function setC()
		local base = {0, 1, phi, iP}
		local pList = perms(base)
		for _, perm in ipairs(pList) do
			for s2 = -1, 1, 2 do
				for s3 = -1, 1, 2 do
					for s4 = -1, 1, 2 do
						local arr = {perm[1], s2 * perm[2], s3 * perm[3], s4 * perm[4]}
						table.insert(bv, cv(arr[1], arr[2], arr[3], arr[4]))
					end
				end
			end
		end
	end

	setA()
	setB()
	setC()

	for i, vert in ipairs(bv) do
		v[i] = {x = vert.x, y = vert.y, z = vert.z, w = vert.w}
	end

	for i = 1, #v do
		local pt = Instance.new("Part")
		pt.Shape = Enum.PartType.Ball
		pt.Size = Vector3.new(0.3, 0.3, 0.3)
		pt.Anchored = true
		pt.CanCollide = false
		pt.Material = Enum.Material.Neon
		pt.Color = Color3.new(1, 1, 1)
		pt.Parent = m
		vp[i] = pt
	end

	local minDSq = math.huge
	for i = 1, #bv do
		for j = i + 1, #bv do
			local dx = bv[i].x - bv[j].x
			local dy = bv[i].y - bv[j].y
			local dz = bv[i].z - bv[j].z
			local dw = bv[i].w - bv[j].w
			local dSq = dx * dx + dy * dy + dz * dz + dw * dw
			if dSq > 0 and dSq < minDSq then
				minDSq = dSq
			end
		end
	end
	local tol = minDSq * 0.05

	local function sqd(a, b)
		local dx = a.x - b.x
		local dy = a.y - b.y
		local dz = a.z - b.z
		local dw = a.w - b.w
		return dx * dx + dy * dy + dz * dz + dw * dw
	end

	for i = 1, #bv do
		for j = i + 1, #bv do
			local dSq = sqd(bv[i], bv[j])
			if math.abs(dSq - minDSq) < tol then
				local ed = Instance.new("Part")
				ed.Anchored = true
				ed.CanCollide = false
				ed.Material = Enum.Material.Metal
				ed.Color = Color3.new(0.8, 0.8, 0.8)
				ed.Size = Vector3.new(0.1, 0.1, 1)
				ed.Parent = m
				table.insert(ep, {p = ed, i1 = i, i2 = j})
			end
		end
	end

	local angXW, angYW, angZW = 0, 0, 0
	local spXW, spYW, spZW = 0.3, 0.45, 0.6

	rs.Heartbeat:Connect(function(dt)
		tLocal = tLocal + dt
		angXW = angXW + spXW * dt
		angYW = angYW + spYW * dt
		angZW = angZW + spZW * dt

		local function rot4(vt)
			local x, y, z, w = vt.x, vt.y, vt.z, vt.w
			local nx = x * math.cos(angXW) - w * math.sin(angXW)
			local nw = x * math.sin(angXW) + w * math.cos(angXW)
			x, w = nx, nw
			local ny = y * math.cos(angYW) - w * math.sin(angYW)
			nw = y * math.sin(angYW) + w * math.cos(angYW)
			y, w = ny, nw
			local nz = z * math.cos(angZW) - w * math.sin(angZW)
			nw = z * math.sin(angZW) + w * math.cos(angZW)
			z, w = nz, nw
			return {x = x, y = y, z = z, w = w}
		end

		for i, base in ipairs(bv) do
			local r = rot4(base)
			v[i] = r
			local pos = pv(r) * sf
			pos = at(pos, tLocal)
			vp[i].Position = pos + off + Vector3.new(0, gY, 0)
		end

		for _, ed in ipairs(ep) do
			local pos1 = pv(v[ed.i1]) * sf
			local pos2 = pv(v[ed.i2]) * sf
			pos1 = at(pos1, tLocal)
			pos2 = at(pos2, tLocal)
			pos1 = pos1 + off + Vector3.new(0, gY, 0)
			pos2 = pos2 + off + Vector3.new(0, gY, 0)
			local mid = (pos1 + pos2) / 2
			local len = (pos2 - pos1).Magnitude
			ed.p.Size = Vector3.new(0.1, 0.1, len)
			ed.p.CFrame = CFrame.new(mid, pos2)
		end
	end)
end

local offs = {
	T = Vector3.new(-50, 0, -50),
	C = Vector3.new(50, 0, -50),
	Cell24 = Vector3.new(-50, 0, 50),
	Cell600 = Vector3.new(50, 0, 50)
}

genT(offs.T)
genC(offs.C)
gen24(offs.Cell24)
gen600(offs.Cell600)
