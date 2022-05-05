local defaultEvent = 'change'
local lo = {}

local EQUALITY_COMPARE_CONST_TYPES = {'string','number','boolean'}

lo.meta = {
	_computed = {
		__call = function(self, ...)
			local arguments = {...}

			if (#arguments > 0) then
	            self:set(...)
	        else
	            return self:get()
	        end
		end,
	},
	_observable = {
		__call = function(self, ...)
			local arguments = {...}
	        if (#arguments > 0) then
	            -- Write
	            -- Ignore writes if the value hasn't changed
				-- self._latestValue ~= arguments[1] or type(arguments[1]) == 'table'
	            if ( not self.equalityComparer or not self.equalityComparer(self._latestValue, arguments[1]) ) then
	                self._latestValue = arguments[1];
	                self:valueHasMutated();
	            end
				return self
	        else
	            -- Read
	            -- lo.dependencyDetection.registerDependency(observable); -- The caller only needs to be notified of changes if they did a "read" operation
				lo.dependencyDetection.registerDependency(self);
	            return self._latestValue;
	        end
		end,
		__index = {
			setNil = function(self)
				if ( not self.equalityComparer or not self.equalityComparer(self._latestValue, nil) ) then
	                self._latestValue = nil;
	                self:valueHasMutated();
	            end
				return self
			end,
			valueHasMutated = function(self)
				self:notifySubscribers(self._latestValue)
			end,
			equalityComparer = function(a, b)
				if a == nil then return a == b end
				if u_(EQUALITY_COMPARE_CONST_TYPES):any(function(v)
					return type(a) == v
				end) then
					return a == b
				end

				return false
			end
		},
		__tostring = function(self)
			local str = 'observable:'.. (self.name and self.name or 'noname')
			str = str .. ' subscription count >> ' .. self:getSubscriptionsCount()
			return str
		end,
	},
}

lo.observable = function(initialValue)
	local observable = {
		_latestValue = initialValue
	}
	setmetatable(observable, lo.meta._observable)
	lo.subscribable(observable);
	return observable
end

lo.isObservable = function (instance)
    if getmetatable(instance) == lo.meta._observable then return true end
	if getmetatable(instance) == lo.meta._computed then return true end
	return false
end

lo.isWriteableObservable = function (instance)
    -- Observable
    if lo.isObservable(instance) and not lo.isComputed(instance) then
        return true;
	end

    -- Writeable dependent observable
    if getmetatable(instance) == lo.meta._computed and (instance.hasWriteFunction) then
        return true;
	end
    -- Anything else
    return false;
end

---------------------------------------------------------------------------------

lo.extenders = {
    notify = function(target, notifyWhen)
		if notifyWhen == "always" then
			target["equalityComparer"] = function() return false end -- Treat all values as not equal
		else
			target["equalityComparer"] = nil
		end

        return target;
    end,
}

---------------------------------------------------------------------------------

lo.subscription = function (t, c, event)
	local sst = {}

	sst.target = t
	sst.isDisposed = false
	sst.callback = c

	function sst:dispose()
	    self.isDisposed = true;
        self.target._subscriptions[event][sst] = nil
	end

	return sst
end

lo.subscribable_fn = {
	subscribe = function (self, callbackOrTarget, event)
        event = event or defaultEvent;
        local boundCallback = type(callbackOrTarget) == 'table' and
			function(...)
				callbackOrTarget[event](callbackOrTarget,...)
			end or callbackOrTarget;

        local subscription = lo.subscription(self, boundCallback, event);

		self._subscriptions[event] = self._subscriptions[event] or {}
        self._subscriptions[event][subscription] = true
        return subscription;
    end,

    notifySubscribers = function (self, valueToNotify, event)
        event = event or defaultEvent;
        if (self._subscriptions[event]) then
			u_(u_.keys(self._subscriptions[event])):each( function(subscription)
				if (subscription and subscription.isDisposed ~= true) then
					--print("DataBind.CommonBind-1",valueToNotify)
                    subscription.callback(valueToNotify);
				end
           	end)
		end
    end,

    getSubscriptionsCount = function (self)
        local total = u_(u_.values(self._subscriptions)):chain():reduce(0, function(memo,v)
			memo = memo + #(u_.values(v))
			return memo
		end):value()

        return total;
    end,

	extend = function(self, requestedExtenders)
		local target = self;
		if requestedExtenders then
			u_(u_.keys(requestedExtenders)):each(function(key)
				local extenderHandler = lo.extenders[key];
				if type(extenderHandler) == 'function' then
					target = extenderHandler(target, requestedExtenders[key]);
				end
			end)
		end
		return target;
	end,
}

lo.subscribable = function(self)
	self = self or {}
	self._subscriptions = {};
    u_.extend(self, lo.subscribable_fn);
	return self
end


lo.isSubscribable = function (instance)
	return type(instance) == "table" and type(instance.subscribe) == "function" and type(instance["notifySubscribers"]) == "function"
end

---------------------------------------------------------------------------------

lo.dependencyDetection = (function ()
    local _frames = {};

    return {
        begin = function (callback)
            _frames[#_frames+1] = { callback = callback, distinctDependencies={} }
        end,

        ["end"] = function ()
            _frames[#_frames] = nil
        end,

        registerDependency = function (subscribable)
            if not lo.isSubscribable(subscribable) then
                error("Only subscribable things can act as dependencies");
			end

            if (#_frames > 0) then
                local topFrame = _frames[#_frames];
				if u_(u_.values(topFrame.distinctDependencies)):any(function(v) return v == subscribable end) then
					return
				end

                topFrame.distinctDependencies[#(topFrame.distinctDependencies)+1] = subscribable;
                topFrame.callback(subscribable);
            end
        end
    }
end)();

lo.isCallable = function(instance)
	if type(instance) == "function" then return true end
	if type(instance) == 'table' and getmetatable(instance).__call then
		return true
	end

	return false
end

lo.isComputed = function (instance)
	if getmetatable(instance) == lo.meta._computed then return true end
	return false
end

-- lo.computed = function (evaluatorFunctionOrOptions, evaluatorFunctionTarget, options)
lo.computed = function (evaluatorFunctionOrOptions, options)
	local computed = {}

    local _latestValue
	local _hasBeenEvaluated = false
	local readFunction = evaluatorFunctionOrOptions

    if (readFunction and type(readFunction) == "table") then
        -- Single-parameter syntax - everything is on this "options" param
        options = readFunction;
        readFunction = options["read"];
    else
        -- Multi-parameter syntax - construct the options according to the params passed
        options = options or {};
        if  not readFunction then
            readFunction = options.read;
		end
    end


    -- By here, "options" is always non-null
    if not lo.isCallable(readFunction) then
        error("Pass a function that returns the value of the lo.computed")
	end

    local writeFunction = options.write;

    computed._subscriptionsToDependencies = {};

    local disposeWhen = options["disposeWhen"] or function() return false end

	local evaluationTimeoutInstance = nil;

    function computed:evaluateImmediate()
        if (_hasBeenEvaluated and disposeWhen()) then
            self:dispose();
            return
        end

		local _stat, _err = xpcall(function()
			local disposalCandidates = u_.extend({},self._subscriptionsToDependencies)

	        lo.dependencyDetection.begin(function(subscribable)
		        local inOld =  u_(disposalCandidates):detect(function(i)
		         	return (i.target) == subscribable		    
				end);
		
				if not inOld then
					--若property里边有此property，则会无限循环注册监听，导致这里无限注册，从而使lua内存一直增加，再dispose前不会被释放，也就是泄露了啊。
					self._subscriptionsToDependencies[#(self._subscriptionsToDependencies)+1] = subscribable:subscribe(self); -- Brand new subscription - add it
				end
			end);

		    readFunction();
		end,__G__TRACKBACK__)
        lo.dependencyDetection['end']();
       	_hasBeenEvaluated = true;
    end

	function computed:set(...)
        if type(writeFunction) == "function" then
            -- Writing a value
            writeFunction(...);
        else
            error("Cannot write a value to a lo.computed unless you specify a 'write' option. If you wish to read the current value, don't pass any parameters.");
        end
    end

	function computed:change(v)
        self:evaluateImmediate();
	end


	function computed:get()
        -- Reading the value
        if (not _hasBeenEvaluated) then
            self:evaluateImmediate();
		end

        lo.dependencyDetection.registerDependency(self);
        return _latestValue;
	end

	setmetatable(computed, lo.meta._computed)
    function computed:getDependenciesCount()
		return #(u_.keys(self._subscriptionsToDependencies))
	end

    computed.hasWriteFunction = type(options["write"]) == "function"

    function computed:dispose()
		u_(self._subscriptionsToDependencies):each(function (v)
			v:dispose();
        end);
        self._subscriptionsToDependencies = {};
	end

    lo.subscribable(computed);
    computed:evaluateImmediate();

    return computed;
end

return lo;