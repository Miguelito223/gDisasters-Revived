SWEP.Author = "Miguelito"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Tornado Radar"
SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.UseHands = false

SWEP.Weight = 5
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 0

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Category 			= "gDisasters - Measurer"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Distance = 75 

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Damage = 0
SWEP.Secondary.Delay = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Distance = 100


function SWEP:Initialize()
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()
	for k, v in pairs(ents.FindByClass("env_tornado")) do
		if v:IsValid() then
			ply:PrintMessage(HUD_PRINTCENTER, "Radar Dectect: " .. v.Data.Parent.PrintName)
		else
			ply:PrintMessage(HUD_PRINTCENTER, "I don't detect anything")
		end
	end
end

function SWEP:SecondaryAttack()

end