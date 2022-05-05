module("LoopManager",package.seeall)

frameLoopDic = {};
timeoutLoopDic = {};
intervalLoopDic = {};

recordFrame = {};
recordTimeout = {};
recordInterval = {};

nowTime = Time.time


timeoutIndex = 1;



UpdateBeat:Add(function () Update() end)


function Update()
    nowTime = Time.time
    for key,action in pairs(frameLoopDic)do
        if recordFrame[key] ~= true then
            xpcall(
                    function()
                        action[1](action[2])
                    end
            ,print)
        end
    end

    for key,action in pairs(timeoutLoopDic)do
        if recordTimeout[key] ~= true and action[2]<=nowTime then
            xpcall(
                    function()
                        action[1](action[3])
                    end
            ,print)
            ClearTimeout(key);
        end
    end


    for key,action in pairs(intervalLoopDic)do
        if recordInterval[key] ~= true and action[2]<=(nowTime - action[3])then
            xpcall(
                    function()
                        action[3]= nowTime
                        action[1](action[4])
                    end
            ,print)
        end
    end

    for key,v in pairs(recordTimeout)do
        timeoutLoopDic[key] = nil;
    end

    for key,v in pairs(recordFrame)do
        frameLoopDic[key] = nil;
    end

    for key,v in pairs(recordInterval)do
        intervalLoopDic[key] = nil;
    end

    table.clear(recordTimeout)
    table.clear(recordFrame)
    table.clear(recordInterval)
end

function AddToFrame(key,func,params)
    if frameLoopDic[key] ~= nil then
        printError("已经添加过的Key:"..key);
    else
        local action = {func,params};
        frameLoopDic[key] = action;
        recordFrame[key] = nil;
    end
end

function RemoveFromFrame(key)
    if frameLoopDic[key] then
        recordFrame[key] = true;
    end
end


function SetTimeout(func,time,params)
    timeoutIndex = timeoutIndex + 1;
    time  = Time.time + time;
    local action = {func,time,params};
    timeoutLoopDic[timeoutIndex] = action;
    return timeoutIndex;
end

function ClearTimeout(index)
    if index~=nil and timeoutLoopDic[index] then
        recordTimeout[index] = true;
    end
end


function AddToInterval(key,func,interval,params)
    if intervalLoopDic[key] ~= nil and  recordInterval[key] == nil then
        printError("已经添加过的Key:"..key);
    else
        local action = {func,interval, Time.time,params};
        intervalLoopDic[key] = action;
        recordInterval[key] = nil;
    end
end

function RemoveFromInterval(key)
    if intervalLoopDic[key] then
        recordInterval[key] = true;
    end
end

function AddToSecond(key,func,params)
    AddToInterval(string.format("%s_sec",key),func,1,params);
end

function RemoveFromSecond(key)
    RemoveFromInterval(string.format("%s_sec",key));
end
