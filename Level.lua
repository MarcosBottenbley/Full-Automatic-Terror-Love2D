--- Marcos Bottenbley
--- mbotten1@jhu.edu

--- Rebecca Bushko
--- rbushko1@jhu.edu

--- Adam Ellenbogen
--- aellenb1@jhu.edu

--- David Miller
--- dmill118@jhu.edu

local Level = {
    num,
}
Level.__index = Level

setmetatable(Level, {
    __call = function (cls, ... )
        local self = setmetatable({}, cls)
        self:_init(...)
        return self
    end,
})

function Level:_init()

end
