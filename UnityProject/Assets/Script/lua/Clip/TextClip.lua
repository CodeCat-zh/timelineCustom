TextClip = {}
function TextClip:OnBehaviourPlay(args)
    self.type = args[0]
    self.id = args[1]
    self.playable = args[2]
    self.info = args[3]
    print("OnBehaviourPlay")
end


function TextClip:OnBehaviourPause(args)

end

function TextClip:PrepareFrame( args)

end

function TextClip:ProcessFrame(args)

end



