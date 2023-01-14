VectivusLib = VectivusLib or {}

local replace = { ":", "/", }
function VectivusLib:ParseKey( k )
    local a = string.lower( k )
    for i=1, #replace do
        a = string.Replace( a, replace[i], "_" ) -- supports steamid32
    end
    return a
end


function VectivusLib:SaveData( sid, path, name, data, bool, format )
    path = ( path or "vs_lib_datasave" )
    format = format or "dat"
    file.CreateDir( path )
    if sid then
        local a = self:ParseKey( sid )
        file.CreateDir( path .. "/" .. a )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    file.Write( path, ( bool and util.TableToJSON( data, true ) or data ) )
end

function VectivusLib:LoadData( sid, path, name, bool, format )
    path = ( path or "vs_lib_datasave" )
    format = format or "dat"
    if sid then
        local a = self:ParseKey( sid )
        path = ( path .. "/" .. a .. "/" )
    else
        path = ( path .. "/" )
    end
    path = ( path .. name .. "." .. format )
    if file.Exists( path, "DATA" ) then
        local r = file.Read( path, "DATA" )
        return ( bool and util.JSONToTable( r ) or r )
    end
    return false
end