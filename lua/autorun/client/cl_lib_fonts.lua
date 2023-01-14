
VectivusLib = VectivusLib or {}

local scaledFonts = scaledFonts or {}

function VectivusLib:Scale( i )
    return math.max( i * ( ScrH() / 1080 ), 1 )
end

function VectivusLib:RegisterFont( name, font, size, weight )
    if !name then print( "[    VectivusLib:RegisterFont:     ]", "missing argument #1 (string name)" ) return end
    if !font then print( "[    VectivusLib:RegisterFont:     ]", "missing argument #2 (string font)" ) return end
    if !size then print( "[    VectivusLib:RegisterFont:     ]", "missing argument #3 (integer size)" ) return end
    surface.CreateFont( "vs." .. name, {
        font = font,
        size = size,
        weight = weight or 500,
    })
end

function VectivusLib:CreateFont( name, font, size, weight )
    scaledFonts[ name ] = {
        font = font,
        size = size,
        weight = weight,
    }
    self:RegisterFont( name, font, self:Scale( size ), weight )
end

hook.Add( "OnScreenSizeChanged", "VectivusLib:RegisterFont", function()
    timer.Simple( 1, function()
        for k, v in pairs( scaledFonts ) do
            print( "[   VectivusLib:Fonts - Updated:    ]", k )
            VectivusLib:CreateFont( k, v.font, v.size, v.weight )
        end
    end )
end )