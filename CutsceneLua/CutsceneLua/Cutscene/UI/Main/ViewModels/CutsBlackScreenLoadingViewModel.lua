module('BN.Cutscene', package.seeall)

CutsBlackScreenLoadingViewModel = class('CutsBlackScreenLoadingViewModel',BN.ViewModelBase)

local WAIT_TIME_TO_CLOSE = 0

function CutsBlackScreenLoadingViewModel:Init()
	--@begin CreateProperty
	self.bgGoProperty = self.createProperty(false)
	--@end CreateProperty
	self.bgGoProperty(true)
end

function CutsBlackScreenLoadingViewModel:OnActive()
	UIManager:addListener(UIManager.LoadingViewLoadFinishEvent, self._LoadingViewLoaded, self)
end

function CutsBlackScreenLoadingViewModel:OnDispose()
	UIManager:removeListener(UIManager.LoadingViewLoadFinishEvent, self._LoadingViewLoaded, self)
	self.fadeFinishCallback = nil
	self.bgImg = nil
	self.viewGO = nil
	self:_StopLoadingCompleteCO()
	self:_StopFadeCoAndTween()
end

function CutsBlackScreenLoadingViewModel:OnRelease()
end

--@begin CreateEvent
--@end CreateEvent

function CutsBlackScreenLoadingViewModel:SetHasLoadFinished(viewGO,bgImg)
	self.loadFinished = true
	self.viewGO = viewGO
	self.bgImg = bgImg
	self:_StartLoading()
end

function CutsBlackScreenLoadingViewModel:EnterLoading(needFade,fadeTime,loadingColor,fadeFinishCallback)
	self.needFade = needFade
	self.fadeTime = fadeTime or 0
	self.loadingColor = loadingColor or CutsceneConstant.BLACK_SCREEN_FADE_COLOR
	self.fadeFinishCallback = fadeFinishCallback

	if self.loadFinished then
		self:_StartLoading()
	end
end

function CutsBlackScreenLoadingViewModel:LoadingComplete(needFade,fadeTime,callback)
	self:_StopLoadingCompleteCO()
	self:_StopFadeCoAndTween()
	local finishCallback = function()
		self.loadingCompleteCO = coroutine.start(function()
			coroutine.wait(WAIT_TIME_TO_CLOSE)
			coroutine.stop(self.loadingCompleteCO)
			self.loadingCompleteCO = nil
			UIManager.loadingEntry:CloseLoading(self)
			if callback then
				callback()
			end
		end)
	end
	if needFade then
		self.needFade = true
		self.fadeTime = fadeTime or 0
		self.fadeFinishCallback = finishCallback
		self:_StartFade(true)
	else
		finishCallback()
	end
end

function CutsBlackScreenLoadingViewModel:ForceClose()
	UIManager.loadingEntry:CloseLoading(self)
end

function CutsBlackScreenLoadingViewModel:_StartLoading()
	self:_StopFadeCoAndTween()
	if not goutil.IsNil(self.bgImg) then
		self.bgImg.color = Color.New(self.loadingColor.r,self.loadingColor.g,self.loadingColor.b,0)
	end
	if self.needFade then
		self:_StartFade(false)
	else
		if self.fadeFinishCallback then
			self.fadeFinishCallback()
		end
	end
end

function CutsBlackScreenLoadingViewModel:_StartFade(toTransparent)
	self.fadeCO = coroutine.start(function()
		local fadeValue = toTransparent and 0 or 1
		self.fadeTween = self.bgImg:DOFade(fadeValue, self.fadeTime)
		coroutine.wait(self.fadeTime)
		coroutine.stop(self.fadeCO)
		self.fadeCO = nil

		if self.fadeFinishCallback then
			self.fadeFinishCallback()
		end
	end)
end

function CutsBlackScreenLoadingViewModel:_StopFadeCoAndTween()
	if self.fadeCO then
		coroutine.stop(self.fadeCO)
		self.fadeCO = nil
	end
	if self.fadeTween then
		self.fadeTween:Kill(false)
		self.fadeTween = nil
	end
end

function CutsBlackScreenLoadingViewModel:_StopLoadingCompleteCO()
	if self.loadingCompleteCO then
		coroutine.stop(self.loadingCompleteCO)
		self.loadingCompleteCO = nil
	end
end

function CutsBlackScreenLoadingViewModel:_LoadingViewLoaded(viewName)
	if not goutil.IsNil(self.viewGO) then
		self.viewGO.transform:SetAsLastSibling()
	end
end