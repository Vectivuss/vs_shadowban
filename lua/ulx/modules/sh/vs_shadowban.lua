local CATEGORY_NAME = "ShadowBan"

do // shadowban ULX
	function ulx.shadowban( calling_ply, target_ply, minutes, reason )
		if target_ply:IsListenServerHost() or target_ply:IsBot() then
			ULib.tsayError( calling_ply, "This player is immune to banning", true )
			return
		end

		local time = "for #s"
		if minutes == 0 then time = "permanently" end
		local str = "#A shadow banned #T " .. time
		if reason and reason ~= "" then str = str .. " (#s)" end
		ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and ULib.secondsToStringTime( minutes * 60 ) or reason, reason )

		if VectivusShadowBan:ShadowBanPlayer( target_ply ) == false then
			ULib.tsayError( calling_ply, "This player is immune to shadow ban", true )
			return
		end

		if minutes and (minutes * 60) > 0 and (minutes * 60) then
			target_ply:ShadowBan({
				length = minutes * 60,
				reason = reason,
				admin = calling_ply:Name().."("..calling_ply:SteamID()..")",
			})
			return 
		end

	end
	local shadowban = ulx.command( CATEGORY_NAME, "ulx shadow_ban", ulx.shadowban, nil, false, false, true )
	shadowban:addParam{ type=ULib.cmds.PlayerArg }
	shadowban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
	shadowban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
	shadowban:defaultAccess( ULib.ACCESS_ADMIN )
	shadowban:help( "Shadow Bans target." )
end


do // shadowban unban ULX
	function ulx.shadowunban( calling_ply, target_ply )
		target_ply:RemoveShadowBan()
		ulx.fancyLogAdmin( calling_ply, "#A UnShadowBanned #s(#s)", target_ply:Name(), target_ply:SteamID() )
	end
	local unban = ulx.command( CATEGORY_NAME, "ulx shadow_unban", ulx.shadowunban, nil, false, false, true )
	unban:addParam{ type=ULib.cmds.PlayerArg }
	unban:defaultAccess( ULib.ACCESS_ADMIN )
	unban:help( "Unbans steamid." )
end