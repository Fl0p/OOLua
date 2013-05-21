
require('src.middleclass.middleclass' )


local _modules = {
  'Invoker', 'GetterSetter', 'Branchy', 'Callbacks', 'Apply', 'Beholder', 'Stateful', 'Indexable'
}

for _,module in ipairs(_modules) do
  require('src.middleclass.' .. module)
end
