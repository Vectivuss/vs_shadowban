--[[-------------------------------------------------
    @ module » SAM ShadowBan
---------------------------------------------------]]
local sam, command, language = sam, sam.command, sam.language
command.set_category( "ShadowBan" )

do
    command.new( "shadow_ban" )
        :SetPermission( "shadow_ban", "admin" )
        :AddArg("player", {single_target = true})
        :AddArg("length", {optional = true, default = 0})
        :AddArg("text", {hint = "reason", optional = true, default = language.get("default_reason")})
        :GetRestArgs()
        :Help("ban_help")
        :OnExecute(function(ply, targets, length, reason)
            local target = targets[1]
            if ply:GetBanLimit() ~= 0 then
                if length == 0 then
                    length = ply:GetBanLimit()
                else
                    length = math.Clamp(length, 1, ply:GetBanLimit())
                end
            end

            if VectivusShadowBan:ShadowBanPlayer( target ) == false then
                sam.player.send_message( ply, "{T} is immune to shadowban.", {
                    A = ply, T = target:Name()
                })
                return
            end
            sam.player.send_message(nil, "ban", {
                A = ply, T = target:Name(), V = sam.format_length(length), V_2 = reason
            })
            if length and (length * 60) > 0 and (length * 60) then
                target:ShadowBan({
                    length = length * 60,
                    reason = reason,
                    admin = ply:Name().."("..ply:SteamID()..")",
                })
                return
            end
        end)
    :End()
end

do
    command.new( "shadow_unban" )
        :SetPermission( "shadow_unban", "admin" )
        :AddArg("player", {single_target = true})
        :GetRestArgs()
        :Help( "Unbans player(s) from shadowban" )
        :OnExecute(function(ply, targets)
            local target = targets[1]
            target:RemoveShadowBan()
            sam.player.send_message(nil, "{A} UnShadowBanned {T}.", {
                A = ply, T = target:Name()
            })
        end)
    :End()
end
