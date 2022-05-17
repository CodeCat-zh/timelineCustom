TextClip = {}
function TextClip:OnBehaviourPlay(args)
    self.type = args[0]
    self.id = args[1]
    self.playable = args[2]
    self.info = args[3]
    self.paramList ={}
    local initPosIndex = 4
    for i = 0,args.Length - initPosIndex - 1  do
       self.paramList[ i + 1 ] = args[ i + initPosIndex ]
    end
end


function TextClip:OnBehaviourPause(args)
  
end

function TextClip:PrepareFrame( args)

end

function TextClip:ProcessFrame(args)

end



