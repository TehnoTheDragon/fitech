local TileEntity = class "TileEntity" {}

function TileEntity:init(position, data)
    self.pos = position
    self.data = data
end

function TileEntity.get_from(tileEntityType, position)
    tileEntityType = tileEntityType or TileEntity
    local meta = minetest.get_meta(position:pos())
    assert(meta ~= nil, ("TileEntity at: (%s) not found"):format(tostring(position)))
    return tileEntityType(position, minetest.deserialize(meta:get_string("TED")))
end

function TileEntity:save()
    local meta = minetest.get_meta(self.pos:pos())
    assert(meta ~= nil, ("TileEntity at: (%s) not found"):format(tostring(position)))
    meta:set_string("TED", minetest.serialize(self.data))
end

return TileEntity