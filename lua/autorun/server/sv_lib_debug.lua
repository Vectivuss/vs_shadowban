
VectivusLib = VectivusLib or {}

function VectivusLib:MsgPrint( addon, cat, msg, ... )
    local args = { ... }
    local resp, msg = pcall( string.format, msg, unpack( args ) )
    if !resp then return end
    MsgC( Color( 0, 225, 0 ), "[" .. addon .. "]:", Color( 255, 0, 0 ), "[" .. cat .. "]",  Color( 255, 255, 0 ), " »  ",  Color( 155, 155, 155 ), msg .. "\n" )
end
VectivusLib:MsgPrint( "SyS", "Debug", "Loaded!" )