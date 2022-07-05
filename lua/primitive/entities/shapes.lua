
local class = {}

local typen = { "cone", "cube", "cube_magic", "cube_hole", "cylinder", "dome", "pyramid", "sphere", "torus", "tube", "wedge", "wedge_corner" }
local typek, defaults = {}, {}

do
    for k, v in pairs( typen ) do
        typek[v] = v
    end

    defaults = {
        cone = {
            PrimMAXSEG = 16,
            PrimMESHSMOOTH = 45,
            PrimNUMSEG = 16,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "cone",
        },
        cube = {
            PrimMESHSMOOTH = 0,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "cube",
        },
        cube_hole = {
            PrimDT = 4,
            PrimMESHSMOOTH = 65,
            PrimNUMSEG = 4,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimSUBDIV = 16,
            PrimTYPE = "cube_hole",
        },
        cube_magic = {
            PrimDT = 4,
            PrimMESHSMOOTH = 0,
            PrimSIDES = 63,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "cube_magic",
        },
        cylinder = {
            PrimMAXSEG = 16,
            PrimMESHSMOOTH = 65,
            PrimNUMSEG = 16,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "cylinder",
        },
        dome = {
            PrimMESHSMOOTH = 65,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimSUBDIV = 8,
            PrimTYPE = "dome",
        },
        generic = {
            PrimDT = 4,
            PrimMAXSEG = 16,
            PrimMESHSMOOTH = 0,
            PrimNUMSEG = 16,
            PrimSIDES = 0,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimSUBDIV = 8,
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "generic",
        },
        pyramid = {
            PrimMESHSMOOTH = 0,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "pyramid",
        },
        sphere = {
            PrimMESHSMOOTH = 65,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimSUBDIV = 8,
            PrimTYPE = "sphere",
        },
        torus = {
            PrimDT = 6,
            PrimMAXSEG = 16,
            PrimMESHSMOOTH = 65,
            PrimNUMSEG = 16,
            PrimSIZE = Vector( 48, 48, 6 ),
            PrimSUBDIV = 16,
            PrimTYPE = "torus",
        },
        tube = {
            PrimDT = 4,
            PrimMAXSEG = 16,
            PrimMESHSMOOTH = 65,
            PrimNUMSEG = 16,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0,
            PrimTY = 0,
            PrimTYPE = "tube",
        },
        wedge = {
            PrimMESHSMOOTH = 0,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0.5,
            PrimTY = 0,
            PrimTYPE = "wedge",
        },
        wedge_corner = {
            PrimMESHSMOOTH = 0,
            PrimSIZE = Vector( 48, 48, 48 ),
            PrimTX = 0.5,
            PrimTY = 0,
            PrimTYPE = "wedge_corner",
        },
    }
end


function class:PrimitiveSetup( initial, args )
    if initial and SERVER then
        duplicator.StoreEntityModifier( self, "mass", { Mass = 100 } )
    end

    local type, physics, uv = unpack( args )

    if defaults[type] then
        self:SetPrimTYPE( type )
        self:SetPrimMESHENUMS( 1 )

        if tobool( physics ) then self:SetPrimMESHPHYS( tobool( physics ) ) end
        if tonumber( uv ) then self:SetPrimMESHUV( tonumber( uv ) ) end
    end
end

local function resetType( self, type )
    for k, v in pairs( self:PrimitiveGetKeys() ) do
        if k == "PrimTYPE" then goto SKIP end

        local value = defaults[type][k]
        if value == nil then
            value = defaults.generic[k]
        end

        if value == nil then goto SKIP end

        self["Set" .. k]( self, value )

        ::SKIP::
    end
end

function class:PrimitivePostNetworkNotify( name, keyval )
    if SERVER and name == "PrimTYPE" and defaults[keyval] then
        resetType( self, keyval )
    end
end


function class:PrimitiveGetConstruct()
    local keys = self:PrimitiveGetKeys()
    return Primitive.construct.get( keys.PrimTYPE, keys, true, keys.PrimMESHPHYS )
end


function class:PrimitiveSetupDataTables()
    self:PrimitiveVar( "PrimTYPE", "String", { category = "modify", title = "type", panel = "combo", values = typek, icons = "primitive/icons/%s.png" }, true )
    self:PrimitiveVar( "PrimSIZE", "Vector", { category = "modify", title = "size", panel = "vector", min = Vector( 1, 1, 1 ), max = Vector( 1000, 1000, 1000 ) }, true )

    self:PrimitiveVar( "PrimDT", "Float", { category = "modify", title = "thickness", panel = "float", min = 1, max = 1000 }, true )
    self:PrimitiveVar( "PrimTX", "Float", { category = "modify", title = "taper x", panel = "float", min = -1, max = 1 }, true )
    self:PrimitiveVar( "PrimTY", "Float", { category = "modify", title = "taper y", panel = "float", min = -1, max = 1 }, true )

    self:PrimitiveVar( "PrimSUBDIV", "Int", { category = "modify", title = "subdivide", panel = "int", min = 1, max = 32 }, true )
    self:PrimitiveVar( "PrimMAXSEG", "Int", { category = "modify", title = "max segments", panel = "int", min = 1, max = 32 }, true )
    self:PrimitiveVar( "PrimNUMSEG", "Int", { category = "modify", title = "num segments", panel = "int", min = 1, max = 32 }, true )
    self:PrimitiveVar( "PrimSIDES", "Int", { category = "modify", title = "sides", panel = "bitfield", lbl = { "front", "rear", "left", "right", "top", "bottom" } }, true )
end


local spawnlist
if CLIENT then
    spawnlist = {
        { category = "shapes", entity = "primitive_shape", title = "cone", command = "cone 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "cube", command = "cube 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "cube_magic", command = "cube_magic 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "cube_hole", command = "cube_hole 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "cylinder", command = "cylinder 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "dome", command = "dome 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "pyramid", command = "pyramid 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "sphere", command = "sphere 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "torus", command = "torus 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "tube", command = "tube 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "wedge", command = "wedge 1 48" },
        { category = "shapes", entity = "primitive_shape", title = "wedge_corner", command = "wedge_corner 1 48" },
    }

    local callbacks = {
        EDITOR_OPEN = function ( self, editor, name, val )
            for k, cat in pairs( editor.categories ) do
                if k == "debug" or k == "mesh" or k == "model" then cat:ExpandRecurse( false ) else cat:ExpandRecurse( true ) end
            end
        end,
        PrimTYPE = function( self, editor, name, val )
            local edit = self:GetEditingData()
            local values = defaults[self.primitive.keys.PrimTYPE]

            for k, row in pairs( editor.rows ) do
                row:SetVisible( edit[k].global or values[k] ~= nil )
            end

            editor:InvalidateChildren( true )
        end,
    }

    function class:EditorCallback( editor, name, val )
        if callbacks[name] then callbacks[name]( self, editor, name, val ) end
    end
end


Primitive.funcs.registerClass( "shape", class, spawnlist )