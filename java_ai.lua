require 'dokidoki.module' [[ make ]]

function make(class_name)
  return function ()
    return ({'left', 'right', 'thrust', 'shoot'})[math.random(4)]
  end
end

return get_module_exports()
