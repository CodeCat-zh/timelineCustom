AppFocusEvent 	= event("AppFocusEvent", true)
AppPauseEvent	= event("AppPauseEvent", true)
AppQuitEvent	= event("AppQuitEvent", true)

module("BN.Main", package.seeall)

local p =string.format('%s/GameScripts/', UnityEngine.Application.dataPath)
local m_package_path = package.path
package.path = string.format("%s?/Init.lua", p)
print(package.path)

local services = {}

local function CO()
    --等待框架C#层初始化完成
    coroutine.wait(0.2)

    require('Startup')

    PathUtil.Init()
    if Application.isEditor then
        PathUtil.Dump()
    end

    setglobal('enableLog', true)
    setglobal('enableWarnLog', true)

    local go = GameObject.Find('Root')
    local component = go:GetComponent('ShowFPS')
    if component then
        component.enabled = false
    end

    local go = GameObject.Find('UIROOT')
    local component = go:GetComponent('ShowInfo')
    if component then
        component.enabled = false
    end
    CameraService.Init()
    AudioService.Init()
    PostProcessService.Init()
    QualityService.Init() -- QualityService在Init时会调用到CameraService，所以一定要放在CameraService后边
    ResourceService.Init()
    GlobalDispatcher.init()
    CharacterLoaderService.Init()
    DataUnlockService.Init()
    RegisterServices()
    UISetting:Init()
    UIManager:Init()
    CommonSetting.Init()
    PlayerService.InitSettingInEditor()
    PublicSceneService.Init()
    InitServices()
    LoginServices()
    AudioService.EnableBGM()
    UIManager:Open("CutsceneEditorMainView")
    coroutine.stop(co)

    co = nil
end

function RegisterService(service)
    if not table.indexof(services, service) then
        table.insert(services, service)
    else
        printWarn('service：', service, '已经注册了多次！')
    end
end

function RegisterServices()
    RegisterService(QualityService)
    RegisterService(SceneService)
    RegisterService(CutsceneService)
    RegisterService(AudioService)
    RegisterService(AssetLoaderService)
    RegisterService(CharacterLoaderService)
    RegisterService(TimeScaleService)
    RegisterService(WeatherService)
    RegisterService(TimeService)
end

function InitServices()
    for i,service in ipairs(services) do
        local handler = service['Init']
        if handler then
            trycall(handler, true)
        end
    end

    ClothesService.Init()
end

function LoginServices()
    PostProcessService.OnLogin()
    for i,service in ipairs(services) do
        local handler = service['OnLogin']
        if handler then
            trycall(handler)
        end
    end
end

local co = nil

--入口函数
function Main()
    --[[
    for n in pairs(_G) do
        print("_G:",n)
    end
    ]]
    co = coroutine.start(CO)
end