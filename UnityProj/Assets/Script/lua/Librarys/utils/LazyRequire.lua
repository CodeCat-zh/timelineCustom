
--- Helper to deal with circular module require situations. Provided module access is not
-- needed immediately (in particular, it can wait until the requiring module has loaded),
-- the lazy-required module looks like and may be treated as a normal module.
-- @string name Module name, as passed to @{require}.
-- @treturn table Module proxy, to be accessed like the module proper.
function LazyRequire (name)
  local mod

  return setmetatable({}, {
    __index = function(_, k)
      mod = mod or require(name)

      return mod[k]
    end
  })
end
