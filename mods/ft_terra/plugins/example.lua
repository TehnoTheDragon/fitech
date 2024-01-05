local example = {}

function example:_init(storage)
    print("example plugin!")
end

function example:my_method(var)
    print("my_method is called!", var)
end

return example