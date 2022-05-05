
--[[
可用于一般回调函数. 例如:
button:AddListener(closure(self.func2, self))
button:RemoveListener(closure(self.func2, self))
]]
function closure(func, self)
   self.__closure = self.__closure or {}

   self.__closure[func] = self.__closure[func] or function ( ... )
      func(self, ...)
   end

   return self.__closure[func]
end

function closure0(func, self)
   self.__closure0 = self.__closure0 or {}

   self.__closure0[func] = self.__closure0[func] or function ()
      func(self)
   end

   return self.__closure0[func]
end

function closureN(func, self,...)
   self.__closureN = self.__closureN or {}
   local params = {...}
   self.__closureN[func] = self.__closureN[func] or function (...)
        local args = {...}
        local curParams = {}
        table.insertto(curParams,params)
        table.insertto(curParams,args)
        func(self,unpack(curParams))
   end

   return self.__closureN[func]
end

--[[
local boo = ClassBoo()
local func = closure(boo.func1, boo)
func.('param1', 'param1')
button.onClick:AddListener(closure(func.func2, boo))
button.onClick:RemoveListener(closure(func.func2, boo))
]]