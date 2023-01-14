
VectivusShadowBan = VectivusShadowBan or {}

function VectivusShadowBan:IsShadowBanned( p )
    if !IsValid( p ) then return end
    return p:GetNWBool( "VectivusShadowBan.IsShadowBanned", false )
end
