module('BN.Cutscene', package.seeall)

ActorTransformMovePathUtil = SingletonClass('ActorTransformMovePathUtil')

local instance = ActorTransformMovePathUtil

function ActorTransformMovePathUtil.GetAStarPathInfoOfGO(go,startPos,endPos,moveTypeUseAStar)
    local vectorPath
    if not goutil.IsNil(go) and moveTypeUseAStar then
        if not CutsceneUtil.CheckIsInEditorNotRunTime() then
            local seeker = go:GetOrAddComponent(typeof(Pathfinding.Seeker))
            seeker:CancelCurrentPathRequest()
            local path = seeker:StartPath(startPos,endPos)
            path:BlockUntilCalculated()
            vectorPath = path.vectorPath
        end
    end
    local aStarPathInfoList = instance._InitAStarPathNodeInfos(vectorPath,startPos,endPos)
    return aStarPathInfoList
end

function ActorTransformMovePathUtil.CloneNewVec3(targetVec3)
    return Vector3.New(targetVec3.x,targetVec3.y,targetVec3.z)
end

function ActorTransformMovePathUtil.GetPathUseTotalTime(moveParamStr,key,moveTypeUseAStar)
    local moveTypeParamsStrDataTab = cjson.decode(moveParamStr)
    local moveTypeStartPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(moveTypeParamsStrDataTab.moveTypeStartPos)
    local moveTypeTargetPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(moveTypeParamsStrDataTab.moveTypeTargetPos)
    local speedCurve = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(moveTypeParamsStrDataTab.speedCurveStr)
    local maxSpeed = moveTypeParamsStrDataTab.maxSpeed
    local actorGO = ResMgr.GetActorGOByKey(key)

    local totalTime = 0
    if not goutil.IsNil(actorGO) then
        local pathNodeInfoList = instance.GetAStarPathInfoOfGO(actorGO,moveTypeStartPos,moveTypeTargetPos,moveTypeUseAStar)
        local pathLength = instance.GetPathLength(pathNodeInfoList)
        local _,moveMaxTime = instance.GetTimeGapMoveInfoMapListAndMaxTime(pathLength,speedCurve,maxSpeed)
        totalTime = totalTime + moveMaxTime
    end
    totalTime = totalTime + CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME
    return totalTime
end

function ActorTransformMovePathUtil.GetPathLength(pathNodeInfoList)
    if pathNodeInfoList and #pathNodeInfoList ~= 0 then
        local lastPathNodeInfo = pathNodeInfoList[#pathNodeInfoList]
        local pathLength = lastPathNodeInfo:GetCurTransLength()
        return pathLength
    end
    return 0
end

function ActorTransformMovePathUtil.GetTimeGapMoveInfoMapListAndMaxTime(pathLength,speedCurve,maxSpeed)
    local moveGapCount = math.ceil( pathLength/CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP)
    local timeGapMoveInfoList = {}
    local moveMaxTime = 0
    local curPathLength = 0
    if moveGapCount > CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT then
        printError(string.format("ActorTransformMovePathUtil.GetTimeGapMoveInfoListAndMaxTime:  moveGapCount is over %s",CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT))
        return
    end
    for i=1,moveGapCount do
        curPathLength = math.min(i*CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP,pathLength)
        lastPathLength = math.max((i-1)*CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP,0)
        local percent = curPathLength/pathLength
        local curSpeed = math.max(maxSpeed * speedCurve:Evaluate(percent),BN.Unit.UnitSpeed.Walk)
        local gapUseTime = CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP/curSpeed
        moveMaxTime = moveMaxTime + gapUseTime

        local actorTimeGapMoveInfo = ActorTimeGapMoveInfo.New()
        actorTimeGapMoveInfo:SetCurTime(moveMaxTime)
        actorTimeGapMoveInfo:SetGapUseTime(gapUseTime)
        actorTimeGapMoveInfo:SetMovePathLength(curPathLength)
        actorTimeGapMoveInfo:SetMovePathLengthInGap(CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT)
        actorTimeGapMoveInfo:SetCurSpeed(curSpeed)
        actorTimeGapMoveInfo:SetLastMovePathLength(lastPathLength)
        table.insert(timeGapMoveInfoList,actorTimeGapMoveInfo)
    end
    local sortTimeGapMoveInfoList = instance._OptimizeTimeGapMoveInfoListSort(timeGapMoveInfoList,moveMaxTime)
    return sortTimeGapMoveInfoList,moveMaxTime
end

function ActorTransformMovePathUtil._OptimizeTimeGapMoveInfoListSort(timeGapMoveInfoList,moveMaxTime)
    local sortTimeGapMoveInfoList = {}
    local timeGapCount = math.ceil(moveMaxTime/CutsceneConstant.ACTOR_TRANSFORM_MOVE_TIME_GAP)
    if timeGapCount > CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT then
        printError(string.format("ActorTransformMovePathUtil._OptimizeTimeGapMoveInfoListSort:  timeGapCount is over %s",CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT))
        return
    end
    local curTime = 0
    for i=1,timeGapCount do
        curTime = math.min(moveMaxTime,i *  CutsceneConstant.ACTOR_TRANSFORM_MOVE_TIME_GAP)
        local lastCurTime = math.max(0,(i-1)*CutsceneConstant.ACTOR_TRANSFORM_MOVE_TIME_GAP)
        sortTimeGapMoveInfoList[i] = {}
        for _,moveInfoList in ipairs(timeGapMoveInfoList) do
            local infoCurTime = moveInfoList:GetCurTime()
            if infoCurTime > lastCurTime and infoCurTime <= curTime then
                table.insert(sortTimeGapMoveInfoList[i],moveInfoList)
            end
        end
    end
    return sortTimeGapMoveInfoList
end

function ActorTransformMovePathUtil._InitAStarPathNodeInfos(vectorPath,startPos,endPos)
    local aStarPathInfoList = {}
    local pathLength = 0
    local startPathNodeInfo = ActorMovePathNodeInfo.New()
    startPathNodeInfo:SetPathNodeVec3(startPos)
    startPathNodeInfo:SetCurTransLength(0)
    table.insert(aStarPathInfoList,startPathNodeInfo)
    if vectorPath then
        for i = 0, vectorPath.Count -1 do
            local curPathVec3 = instance.CloneNewVec3(vectorPath[i])
            local tempCurPathVec3 = instance.CloneNewVec3(vectorPath[i])
            local lastPathVec3 = curPathVec3
            if i>0 then
                lastPathVec3 = instance.CloneNewVec3(vectorPath[i-1])
            else
                lastPathVec3 = startPos
            end
            local dirVec3Adjacent = tempCurPathVec3:Sub(lastPathVec3)
            local transLengthStackingAmount = dirVec3Adjacent:Magnitude()
            pathLength = pathLength + transLengthStackingAmount
            local pathNodeInfo = ActorMovePathNodeInfo.New()
            pathNodeInfo:SetPathNodeVec3(curPathVec3)
            pathNodeInfo:SetCurTransLength(pathLength)
            table.insert(aStarPathInfoList,pathNodeInfo)
        end
    end
    local endPathNodeInfo = ActorMovePathNodeInfo.New()
    endPathNodeInfo:SetPathNodeVec3(endPos)
    local endPosClone = instance.CloneNewVec3(endPos)
    if(#aStarPathInfoList ~=0) and vectorPath then
        local finalVectorPath = vectorPath[vectorPath.Count - 1]
        local vecAdjacent = endPosClone:Sub(finalVectorPath)
        local transLengthStackingAmount = vecAdjacent:Magnitude()
        pathLength = pathLength + transLengthStackingAmount
        endPathNodeInfo:SetCurTransLength(pathLength)
    else
        local vecAdjacentStartToEnd = endPosClone:Sub(startPos)
        local transLengthStackingAmount = vecAdjacentStartToEnd:Magnitude()
        pathLength = pathLength + transLengthStackingAmount
        endPathNodeInfo:SetCurTransLength(pathLength)
    end
    table.insert(aStarPathInfoList,endPathNodeInfo)
    return aStarPathInfoList
end