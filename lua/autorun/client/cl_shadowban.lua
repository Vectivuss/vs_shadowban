
VectivusLib:CreateFont( "shadowbanb.22", "Arial", 30, 1024 )

function VectivusShadowBan:FormatTime( i )
    i = i or 0
    i = string.FormattedTime( i )
    return ( i.h < 10 and "0" .. i.h or i.h) .. ":" .. (i.m < 10 and "0" .. i.m or i.m) .. ":" .. (i.s < 10 and "0" .. i.s or i.s )
end

function VectivusShadowBan:GetTime( p )
    return p:GetNWInt( "VectivusShadowBan:GetTime", 0 )
end

function VectivusShadowBan:HUD()
    local p, w, h = LocalPlayer(), ScrW(), ScrH()
    if !self:IsShadowBanned( p ) then return end
    local x, y, W, H = 0, h, w, h*.07
    local reason = string.format( "Banned for: %s", self:FormatTime( self:GetTime( p ) ) )
    local server = string.format( "Appeal @ %s", self.server_name or "google.com" )

    draw.RoundedBox( 0, x, (y-H)/2, W, H, Color( 0, 0, 0, 166 ) )
    surface.SetDrawColor( self.hud_color or color_white )
    surface.DrawOutlinedRect( x, (y-H)/2, W, 0, 1 )
    surface.DrawOutlinedRect( x, (y-H)/2+H, W, 0, 1 )

    draw.SimpleText( reason, "vs.shadowbanb.22", w/2, (y-H)/2+(H*.25), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( server, "vs.shadowbanb.22", w/2, (y-H)/2+(H*.7), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
hook.Add( "HUDPaint", "VectivusShadowBan:HUD", function() VectivusShadowBan:HUD() end )
