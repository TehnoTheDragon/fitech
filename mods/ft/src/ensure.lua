return function(value, fn)
    return value ~= nil and fn(value) or value
end