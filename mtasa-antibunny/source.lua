local state
function Check()
    if getPedMoveState(getLocalPlayer()) == "sprint" then
        state = true
    elseif state and getPedMoveState(getLocalPlayer()) == "jump" then
        setTimer(setPedAnimation, 50, 1, getLocalPlayer(), "ped", "FALL_collapse", -1, false, true, false, false)
    else
        state = nil
    end
end

addEventHandler("onClientPreRender",root,Check)