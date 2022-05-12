local TextClip = {}


function TextClip:OnBehaviourPlay(args)
    self.type =args[1]
    self.id = args[2]
    self.playable = args[3]
    self.info = args[4]
    print(self.id)
    print(self.type)
end


function TextClip:OnBehaviourPause(args)

end

function TextClip:PrepareFrame( args)

end

function TextClip:ProcessFrame(args)

end


return TextClip
