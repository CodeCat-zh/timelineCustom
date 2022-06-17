module('BN.Cutscene', package.seeall)

CutsDialogueBaseCellViewModel = class('CutsDialogueBaseCellViewModel',BN.ViewModelBase)

function CutsDialogueBaseCellViewModel:OnDispose()
    self.contentText = nil
end

function CutsDialogueBaseCellViewModel:ModifyTextTypeWriter(textGO)
    self.textTypeWriter = Polaris.ToLuaFramework.TextTypeWriter.Get(textGO)
end

function CutsDialogueBaseCellViewModel:SetContentText(txtComponent)
    self.contentText = txtComponent
    self.txtComponentRT = goutil.GetRectTransform(self.contentText.gameObject, "")
    self.txtContentSize = Vector2(self.txtComponentRT.sizeDelta.x,self.txtComponentRT.sizeDelta.y)
    self.reviseSize = Vector2(self.txtContentSize.x - Mathf.Min(2, txtComponent.fontSize * 0.2), self.txtContentSize.y)
end

function CutsDialogueBaseCellViewModel:GetContentTextComponent()
    return self.contentText
end

function CutsDialogueBaseCellViewModel:WriterShowAll()
    self.textTypeWriter:ShowAll()
end

function CutsDialogueBaseCellViewModel:ChangeTextSizeToReviseSize()
    if self.reviseSize and self.txtComponentRT then
        self.txtComponentRT.sizeDelta = self.reviseSize
    end
end

function CutsDialogueBaseCellViewModel:ChangeTextSizeToContentSize()
    if self.txtContentSize and self.txtComponentRT then
        self.txtComponentRT.sizeDelta = self.txtContentSize
    end
end

function CutsDialogueBaseCellViewModel:SetWriteContentAndCallbackParams(params)
    local content = params.content
    local duration = params.duration
    local callback = params.callback
    if not self.textTypeWriter then
        return
    end
    self.textTypeWriter:Init(content, duration)
    self.textTypeWriter:SetShowAllCallback(callback, nil)
end

--Override
function CutsDialogueBaseCellViewModel:Free()
    if self.textTypeWriter then
        self.textTypeWriter:Init(nil, 0)
    end
end

--Override
function CutsDialogueBaseCellViewModel:ModifyContent(content)

end

--Override
function CutsDialogueBaseCellViewModel:SetArrowGOActive(value)

end

--Override
function CutsDialogueBaseCellViewModel:ModifyShowName(name)

end