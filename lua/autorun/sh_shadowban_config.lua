//////////////////////////////////////////////////////////////////////////////////

/////////////////////////////// Vectivus´s ShadowBan /////////////////////////////

// Developed by Vectivus:
// http://steamcommunity.com/id/vectivuss

// Wish to contact me:
// vectivus@qrextomniaservers.co

//////////////////////////////////////////////////////////////////////////////////

local config = VectivusShadowBan


// Name of server displayed in shadowban HUD
// https://i.imgur.com/lOJDSRe.png
config.server_name = "Google.com"

// Color of HUD
config.hud_color = Color( 210, 39, 105 )

// This will enable the kick feature
config.kick = true

// This will kick ALL shadowbanned player(s) once the server hits e.g 85% of max playercount
config.kick_percent = 0.85


config.teleport = { // Teleports shadowbanned player to a random location on map

    [ "gm_construct" ] = {
        Vector( -2473.307373, -3012.330566, 2912.031250 ),
    },

}
