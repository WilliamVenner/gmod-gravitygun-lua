if (SERVER) then
	util.AddNetworkString("GravGunOnPickedUp")
	util.AddNetworkString("GravGunOnDropped")
end

GravGunPickups = GravGunPickups or {
	Players = {},
	Entities = {}
}

do
	local plyMeta = FindMetaTable("Player")
	function plyMeta:GetGravGunEntity()
		return GravGunPickups.Players[self] or NULL
	end

	local entMeta = FindMetaTable("Entity")
	function entMeta:GetGravGunPlayer()
		return GravGunPickups.Entities[self] or NULL
	end
end

do
	local function GravGunOnPickedUp(ply, ent)
		if (not IsValid(ply) or not IsValid(ent)) then return end

		GravGunPickups.Players[ply] = ent
		GravGunPickups.Entities[ent] = ply

		if (SERVER) then
			net.Start("GravGunOnPickedUp")
				net.WriteEntity(ply)
				net.WriteEntity(ent)
			net.Broadcast()
		end
	end

	local function GravGunOnDropped(ply, ent)
		if (not IsValid(ply) or not IsValid(ent)) then return end

		GravGunPickups.Players[ply] = nil
		GravGunPickups.Entities[ent] = nil

		if (SERVER) then
			net.Start("GravGunOnDropped")
				net.WriteEntity(ply)
				net.WriteEntity(ent)
			net.Broadcast()
		end
	end

	if (CLIENT) then
		net.Receive("GravGunOnPickedUp", function()
			GravGunOnPickedUp(net.ReadEntity(), net.ReadEntity())
		end)

		net.Receive("GravGunOnDropped", function()
			GravGunOnDropped(net.ReadEntity(), net.ReadEntity())
		end)
	end

	hook.Add("GravGunOnPickedUp", "GravGunOnPickedUp", GravGunOnPickedUp)
	hook.Add("GravGunOnDropped", "GravGunOnDropped", GravGunOnDropped)
end

hook.Add("EntityRemoved", "GravGunOnPickedUp.EntityRemoved", function(ent)
	GravGunPickups.Players[ent] = nil
	GravGunPickups.Entities[ent] = nil
end)
