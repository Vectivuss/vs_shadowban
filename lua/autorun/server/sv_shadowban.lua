
VectivusLib:MsgPrint( "ShadowBan", "Loading", "[ LOADED ]" )

local pMeta = FindMetaTable( "Player" )

VectivusShadowBan.list = VectivusLib:LoadData( nil, "vs_ban", "bans", true ) or {}
function VectivusShadowBan:QueueSave()
    timer.Create( "VectivusShadowBan.QueueSave", .1, 1, function()
        VectivusLib:SaveData( nil, "vs_ban", "bans", self.list, true )
    end )
end
function VectivusShadowBan:GetBans()
    return self.list
end

function VectivusShadowBan:SetShadowBanned( p, bool )
    if !IsValid( p ) then return end
    p:SetNWBool( "VectivusShadowBan.IsShadowBanned", bool or false )
end
function VectivusShadowBan:SetShadowBanTime( p, i )
    if !IsValid( p ) then return end
    p:SetNWFloat( "VectivusShadowBan:GetBannedTime", os.time() + ( i or 0 ) )
end
function VectivusShadowBan:GetBannedTime( p )
    return p:GetNWFloat( "VectivusShadowBan:GetBannedTime", 0 )
end
function VectivusShadowBan:GetBannedTimeNormal( p )
    local format = math.Clamp( self:GetBannedTime( p ) - os.time(), 0, 999999 )
    p:SetNWInt( "VectivusShadowBan:GetTime", format )
    return format
end
function VectivusShadowBan:UpdatePlayers()
    for _, p in pairs( player.GetAll() ) do
        if !IsValid( p ) then continue end
        if !self:IsShadowBanned( p ) then continue end
        self:GetBannedTimeNormal( p )
    end
end
timer.Create( "VectivusShadowBan:UpdatePlayers", 1, 0, function() VectivusShadowBan:UpdatePlayers() end )

function VectivusShadowBan:ShadowBanPlayer( p, data )
    if !IsValid( p ) then return end
    local sid = p:SteamID()
    local result = hook.Run( "VectivusShadowBan:CanShadowBanPlayer", p )
    if result == false then
        VectivusLib:MsgPrint( "ShadowBan", "Protect", "Immune to shadowban [ PLAYER: %s ] [ STEAM: % ]", p:Name(), sid )
        return false
    end
    local ban_start = os.time()
    local ban_end = data and data.length or 0
    local reason = data and data.reason or "unknown"
    local admin = data and data.admin or "console"
    self:GetBans()[ sid ] = {name=p:Name(),ban_start=ban_start,ban_end=ban_end,reason=reason,admin=admin,}
    self:QueueSave()
    VectivusLib:MsgPrint( "ShadowBan", "Banned", "[ PLAYER: %s ] [ REASON: %s ] [ ADMIN: %s ]", p:Name(), reason, admin )
    hook.Run( "VectivusShadowBan:ShadowBannedPlayer", p )
end
hook.Add( "VectivusShadowBan:ShadowBannedPlayer", "ApplyBan", function( p ) 
    VectivusShadowBan:Apply( p ) 
end )
function pMeta:ShadowBan( data ) VectivusShadowBan:ShadowBanPlayer( self, data ) end
hook.Add( "VectivusShadowBan:CanShadowBanPlayer", "adminCheck", function( p )
    if p:IsSuperAdmin() then
        return false
    end
end )

function VectivusShadowBan:RemovePlayerBan( p )
    if !IsValid( p ) then return end
    local name = p:Name()
    local sid = p:SteamID()
    do // player data reset/disabled
        self:SetShadowBanned( p, false )
        self:SetShadowBanTime( p, 0 )
        self:RestorePlayer( p )
    end
    self:GetBans()[ sid ] = nil
    self:QueueSave()
    VectivusLib:MsgPrint( "ShadowBan", "Unban", "Removed ban(s) [ PLAYER: %s ] [ STEAMID: %s ]", name, sid )
end
function pMeta:RemoveShadowBan() VectivusShadowBan:RemovePlayerBan( self ) end


function VectivusShadowBan:Apply( p )
    if !IsValid( p ) then return end
    local sid = p:SteamID()
    local data = self.list[ sid ]
    if !data then return end
    if data.ban_end > 0 and os.time() > ( data.ban_start + data.ban_end ) then
        self:RemovePlayerBan( p )
        return
    end
    local bantime = data.ban_start + data.ban_end - os.time()
    self:SetShadowBanned( p, true )
    self:SetShadowBanTime( p, bantime )
    self:PlayerChanges( p )
    timer.Create( "VectivusShadowBan.OnSpawn." .. tostring( p ), self:GetBannedTimeNormal( p ), 1, function()
        if !IsValid( p ) then return end
        self:RemovePlayerBan( p )
    end )
    VectivusLib:MsgPrint( "ShadowBan", "Ban", "Applied ban to [ PLAYER: %s ] [ TIME: %s ]", p:Name(), self:GetBannedTimeNormal( p ) )
end
hook.Add( "PlayerSpawn", "VectivusShadowBan:OnSpawn", function( p ) 
    VectivusShadowBan:Apply( p ) 
    timer.Simple( 0, function()
        if !IsValid( p ) then return end
        p:SetAvoidPlayers( false )
    end )
end )


local hooks = {
    [ "PlayerSpawnedProp" ] = true,
    [ "PlayerSpawnedSENT" ] = true,
    [ "PlayerSpawnEffect" ] = true,
    [ "PlayerSpawnNPC" ] = true,
    [ "PlayerSpawnObject" ] = true,
    [ "PlayerSpawnProp" ] = true,
    [ "PlayerSpawnVehicle" ] = true,
    [ "PlayerSpawnSWEP" ] = true,
    [ "PlayerSpawnRagdoll" ] = true,
    [ "PlayerSay" ] = true,
    [ "CanTool" ] = true,
    [ "PlayerCanHearPlayersVoice" ] = true,
    [ "PlayerCanPickupItem" ] = true,
    [ "PlayerCanPickupWeapon" ] = true,
    [ "canBuyCustomEntity" ] = true,
    [ "canBuyShipment" ] = true,
    [ "canBuyPistol" ] = true,
    [ "canBuyAmmo" ] = true,
    [ "canBuyVehicle" ] = true,
}

function VectivusShadowBan:PlayerChanges( p )
    timer.Simple( .2, function()
        if !IsValid( p ) then return end
        if !self:IsShadowBanned( p ) then return end
        do // player edit
            p:SetTeam( DarkRP and TEAM_CITIZEN or TEAM_UNASSIGNED )
            p:StripWeapons()
            p:SetModel( "models/editor/playerstart.mdl" )
            p:SetMaterial( "models/debug/debugwhite" )
            p:SetColor( Color( 255, 0, 0 ) )
            p:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        end
        do // freezing
            p:Lock()
            p:SetMoveType( MOVETYPE_NONE )
        end
        do // disable hooks
            for k, _ in pairs( hooks ) do
                hook.Add( k, "vectivusshadowban."..k, function( p )
                    if self:IsShadowBanned( p ) then
                        return false
                    end
                end )
            end
        end
        do // teleport player
            local map = self.teleport[ game.GetMap() ]
            p:SetPos( map[ math.random( #map ) ] or Vector( 0, 0, 0 ) )
            p:DropToFloor()
        end
    end )
end

function VectivusShadowBan:RestorePlayer( p )
    timer.Simple( 0, function()
        if !IsValid( p ) then return end
        do // player edit
            p:SetColor( Color( 255, 255, 255 ) )
            p:SetMaterial( "" )
            p:Spawn()
        end
        do // unfreeze
            p:UnLock()
        end
    end )
end


hook.Add( "PhysgunDrop", "VectivusShadowBan.PhysgunDrop", function( _, e )
    timer.Simple( 0, function()
        local p = e:IsPlayer() and e
        if !IsValid( p ) then return end 
        if !VectivusShadowBan:IsShadowBanned( p ) then return end
        p:Lock()
        p:SetMoveType( MOVETYPE_NONE )
        p:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        p:SetAvoidPlayers( false )
    end )
end )


function VectivusShadowBan:KickPercentage( percent )
    if !self.kick then return end
    percent = percent or 0.85
    local players = #player.GetAll()
    for _, p in pairs( player.GetAll() ) do
        local i = players / game.MaxPlayers()
        if i > percent and self:IsShadowBanned( p ) then
            p:Kick( "Removing banned players for more space" ) 
            VectivusLib:MsgPrint( "ShadowBan", "Auto-Kick", "Kicked [ PLAYER: %s ]", p:Name() )
        end
    end
end
timer.Create( "VectivusShadowBan.KickPercentage", 5, 0, function()
    VectivusShadowBan:KickPercentage( VectivusShadowBan.kick_percent )
end )
