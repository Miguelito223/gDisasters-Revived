AddCSLuaFile()

print("[GDISASTERS AUTOLOAD] LOADING TVIRUS... ")

npc_tvirus = {
	"npc_monk",
	"npc_metropolice",
	"npc_combine_s",
	"npc_stalker",
	"npc_alyx",
	"npc_barney",
	"npc_magnusson",
	"npc_kleiner",
	"npc_eli",
	"npc_kleiner",
	"npc_mossman",
	"npc_gman",
	"npc_citizen",
	"npc_breen"
}

for i = 1, #npc_tvirus do
	print("[GDISASTERS AUTOLOAD] LOADING TABLE: " .. npc_tvirus[i])
end

print("[GDISASTERS AUTOLOAD] FINISH")
