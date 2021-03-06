scriptname Zebrina:Workshop:MechDoorControlScript extends ObjectReference

import Zebrina:WorkshopUtility

group AutoFill
    Keyword property DLC01CanOpenMechanistDoorsKeyword auto const mandatory
    Scene property DLC01_PlayerMechDoorComment_RedOff auto const mandatory
	{ Player-voice scene to play when the player interacts with a Controller in the RedOff state. "The power is out." }
    Scene property DLC01_PlayerMechDoorComment_RedOn auto const mandatory
	{ Player-voice scene to play when the player interacts with a Controller in the RedOn state. "My robot should use this." }
	Sound property DLC01DRSMechanistDoorControlBeepDeny auto const mandatory
	Sound property DLC01DRSMechanistDoorControlBeepConfirm auto const mandatory
endgroup
group QuestAliasesAndScenes
    ReferenceAlias property Followers_Companion auto const mandatory
    ReferenceAlias property DLC01MasterQuest_MechDoorControl_Primary auto const mandatory
    ReferenceAlias property DLC01MasterQuest_MechDoorControl_Target auto const mandatory
    Scene property DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated auto const mandatory
	{ On DLC01MasterQuest, a scene in which the player tells their robot to scan and open the door control. }
	Scene property DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated auto const mandatory
	{ On DLC01MasterQuest, a scene in which the robot scans and opens the door control. }
endgroup

event OnLoad()
    self.BlockActivation()
endevent

function StartRobotScanningScene(bool abIsPlayerInitiated)
    ; Push the controls into the scene aliases.
    DLC01MasterQuest_MechDoorControl_Primary.ForceRefTo(self)
    DLC01MasterQuest_MechDoorControl_Target.ForceRefTo(self)

    ; Register for scene end event and start the appropriate scene.
    self.RegisterForRemoteEvent(DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated, "OnEnd")
    if (abIsPlayerInitiated)
        DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated.Start()
    else
        DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated.Start()
    endif
endfunction

auto state WaitForActivate
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Busy")
        if (IsPlayerActionRef(akActionRef))
            Actor player = Game.GetPlayer()
            Actor companionActor = Followers_Companion.GetActorRef()
            bool canOpen = companionActor && companionActor.HasKeyword(DLC01CanOpenMechanistDoorsKeyword)
            if (player.IsInScene())
                DLC01DRSMechanistDoorControlBeepDeny.Play(self)
            elseif (canOpen)
                ; Our robot Followers_Companion activated the controller.
                StartRobotScanningScene(akActionRef == player)
                return ; To prevent going to 'WaitForActivate'
            elseif (!self.IsPowered())
                ; Play a player-voice scene stating the power is out.
                DLC01_PlayerMechDoorComment_RedOff.Start()
            else
                ; Otherwise, if closed, play a negative acknowledgement.
                if (self.GetOpenState() == 3)
                    DLC01DRSMechanistDoorControlBeepDeny.Play(self)
                else
                    ; If open, play positive instead of negative achknowledgement.
                    DLC01DRSMechanistDoorControlBeepConfirm.Play(self)
                endif
                ; And play a player-voice scene commenting on the strange device.
                Utility.Wait(0.75)
                DLC01_PlayerMechDoorComment_RedOn.Start()
            endif
        endif
        self.GoToState("WaitForActivate")
    endevent
endstate
state Busy
endstate

event Scene.OnEnd(Scene akSender)
    self.UnregisterForRemoteEvent(akSender, "OnEnd")
    self.Activate(Game.GetPlayer(), true)
    self.GoToState("WaitForActivate")
endevent

; OLD SCRIPT
;/
import Zebrina:WorkshopUtility

group AutoFill
    Keyword property DLC01CanOpenMechanistDoorsKeyword auto const mandatory
    Scene property DLC01_PlayerMechDoorComment_RedOff auto const mandatory
	{ Player-voice scene to play when the player interacts with a Controller in the RedOff state. "The power is out." }
    Scene property DLC01_PlayerMechDoorComment_RedOn auto const mandatory
	{ Player-voice scene to play when the player interacts with a Controller in the RedOn state. "My robot should use this." }
	Sound property DLC01DRSMechanistDoorControlOpen auto const mandatory
	Sound property DLC01DRSMechanistDoorControlClose auto const mandatory
	Sound property DLC01DRSMechanistDoorControlBeepDeny auto const mandatory
	Sound property DLC01DRSMechanistDoorControlBeepConfirm auto const mandatory
endgroup
group QuestAliases
    ReferenceAlias property Followers_Companion auto const mandatory
    ReferenceAlias property DLC01MasterQuest_MechDoorControl_Primary auto const mandatory
    ReferenceAlias property DLC01MasterQuest_MechDoorControl_Target auto const mandatory
    Scene property DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated auto const mandatory
	{ On DLC01MasterQuest, a scene in which the player tells their robot to scan and open the door control. }
	Scene property DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated auto const mandatory
	{ On DLC01MasterQuest, a scene in which the robot scans and opens the door control. }
endgroup

bool property bOpen = false auto hidden

; Empty function definitions.
function HandleOnActivate(ObjectReference akActionRef)
    DEBUGTraceself(self, "HandleOnActivate", "Called in state which does not define it.")
endfunction
function HandlePowerChange(bool abPowerOn)
    DEBUGTraceself(self, "HandlePowerChange", "Called in state which does not define it.")
endfunction
function HandleSceneEnd(Scene akScene)
    DEBUGTraceself(self, "HandleSceneEnd", "Called in state which does not define it.")
endfunction

function UpdateSwitchState()
    self.SetOpen(!bOpen)
endfunction
function SetSwitchState(bool abFlag)
    bOpen = abFlag
    UpdateSwitchState()
endfunction

function ToggleSwitchState(ObjectReference akActionRef)
    if (IsPlayerActionRef(akActionRef))
        Actor player = Game.GetPlayer()
        Actor companionActor = Followers_Companion.GetActorRef()
        bool canOpen = companionActor && companionActor.HasKeyword(DLC01CanOpenMechanistDoorsKeyword)
        if (player.IsInScene())
            DLC01DRSMechanistDoorControlBeepDeny.Play(self)
        elseif (canOpen)
            ; Our robot Followers_Companion activated the controller.
            StartRobotScanningScene(akActionRef == player)
        else
            ; Otherwise, play a negative acknowledgement.
            DLC01DRSMechanistDoorControlBeepDeny.Play(self)
            ; And play a player-voice scene commenting on the strange device.
            Utility.Wait(0.75)
            DLC01_PlayerMechDoorComment_RedOn.Start()
        endif
    endif
endfunction
function StartRobotScanningScene(bool abIsPlayerInitiated)
    ; Push the controls into the scene aliases.
    DLC01MasterQuest_MechDoorControl_Primary.ForceRefTo(self)
    DLC01MasterQuest_MechDoorControl_Target.ForceRefTo(self)

    ; Register for scene end event and start the appropriate scene.
    self.RegisterForRemoteEvent(DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated, "OnEnd")
    if (abIsPlayerInitiated)
        DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated.Start()
    else
        DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated.Start()
    endif
endfunction

auto state Unloaded
    event OnBeginState(string asOldState)
    endevent

    event OnLoad()
        if (self.IsPowered())
            if (bOpen)
                self.GoToState("GreenOn")
            else
                self.GoToState("RedOn")
            endif
        else
            self.GoToState("RedOff")
        endif
    endevent
endstate

state RedOn
    event OnBeginState(string asOldState)
        if (asOldState == "GreenOn")
			DLC01DRSMechanistDoorControlClose.Play(self)
			self.PlayAnimationAndWait("Play01", "Done")
            SetSwitchState(false)
		else
			self.PlayAnimation("StartOnRed01")
		endif
    endevent
    event OnEndState(string asNewState)
        self.UnregisterForRemoteEvent(DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated, "OnEnd")
    endevent

    function HandleOnActivate(ObjectReference akActionRef)
        ToggleSwitchState(akActionRef)
    endfunction
    function HandlePowerChange(bool abPowerOn)
        if (!abPowerOn)
            self.GoToState("RedOff")
        endif
    endfunction
    function HandleSceneEnd(Scene akScene)
        self.GoToState("GreenOn")
    endfunction
endstate
state RedOff
    event OnBeginState(string asOldState)
        if (asOldState == "GreenOn")
			DLC01DRSMechanistDoorControlClose.Play(self)
			self.PlayAnimationAndWait("Play01", "Done")
			self.PlayAnimation("OffRed01")
		elseif (asOldState == "RedBlinking")
			self.PlayAnimation("OnRed01")
			self.PlayAnimation("OffRed01")
        else
            self.PlayAnimation("StartOffRed01")
		endif
    endevent

    function HandleOnActivate(ObjectReference akActionRef)
        if (IsPlayerActionRef(akActionRef))
            if (!Game.GetPlayer().IsInScene())
                DLC01_PlayerMechDoorComment_RedOff.Start()
            else
                DLC01DRSMechanistDoorControlBeepDeny.Play(self)
            endif
        endif
    endfunction
    function HandlePowerChange(bool abPowerOn)
        if (bOpen)
            self.GoToState("GreenOn")
        else
            self.GoToState("RedOn")
        endif
    endfunction
endstate
state RedBlinking
    event OnBeginState(string asOldState)
        self.StartTimer(1.0)
        if (asOldState == "GreenOn")
			DLC01DRSMechanistDoorControlClose.Play(self)
			self.PlayAnimationAndWait("Play01", "Done")
			self.PlayAnimation("BlinkRed01")
		elseif (asOldState == "RedOff")
			DLC01DRSMechanistDoorControlBeepConfirm.Play(self)
			self.PlayAnimation("OnRed01")
			self.PlayAnimation("BlinkRed01")
        else
            self.PlayAnimation("StartBlinkRed01")
		endif
    endevent
    event OnEndState(string asNewState)
        self.CancelTimer()
    endevent

    event OnTimer(int aiTimerID)
        self.GoToState("GreenOn")
    endevent

    function HandleOnActivate(ObjectReference akActionRef)
        if (IsPlayerActionRef(akActionRef))
            DLC01DRSMechanistDoorControlBeepDeny.Play(self)
        endif
    endfunction
    function HandlePowerChange(bool abPowerOn)
        if (!abPowerOn)
            self.GoToState("RedOff")
        endif
    endfunction
endstate

state GreenOn
    event OnBeginState(string asOldState)
        Actor player = Game.GetPlayer()
        Actor companionActor = Followers_Companion.GetActorRef()
        if (asOldState == "GreenOn")
			self.PlayAnimation("StartOnGreen01")
		elseif (player.IsInCombat() || (companionActor && companionActor.IsInCombat()))
			self.GoToState("RedBlinking")
		else
			DLC01DRSMechanistDoorControlOpen.Play(self)
			self.PlayAnimationAndWait("Play01", "Done")
			DLC01DRSMechanistDoorControlBeepConfirm.Play(self)
            SetSwitchState(true)
		endif
    endevent
    event OnEndState(string asNewState)
        self.UnregisterForRemoteEvent(DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated, "OnEnd")
    endevent

    function HandleOnActivate(ObjectReference akActionRef)
        ToggleSwitchState(akActionRef)
    endfunction
    function HandlePowerChange(bool abPowerOn)
        if (!abPowerOn)
            self.GoToState("RedOff")
        endif
    endfunction
    function HandleSceneEnd(Scene akScene)
        self.GoToState("RedOn")
    endfunction
endstate

event OnActivate(ObjectReference akActionRef)
    UpdateSwitchState()
    HandleOnActivate(akActionRef)
endevent
event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerChange(true)
endevent
event OnPowerOff()
    HandlePowerChange(false)
endevent
event Scene.OnEnd(Scene akSender)
    self.UnregisterForRemoteEvent(akSender, "OnEnd")
    HandleSceneEnd(akSender)
endevent

; DEBUG

; ScriptObject override.
function GotoState(string asNewState)
    DEBUGTraceSelf(self, "GotoState", "Transitioning from state '" + self.GetState() + "' to '" + asNewState + "'.")
    parent.GoToState(asNewState)
endfunction
/;
