-- Create our scene
local scene = director:createScene()

-- get text on and off
local function getTextOnOff(state)
  if state ~= nil and state == true then
    return "ON"
  else
    return "OFF"
  end
end

-- Setup resources
function scene:setUp(event)
  dbg.print("settingsScene - scene:setUp")
  
  -- Create the grass background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundSettings})

  local textGap = 5
  
  -- Create the sound labels
  self.soundLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="MUSIC: "})
  self.soundLabel.x = director.displayCenterX - 90
  self.soundLabel.y = director.displayCenterY + self.soundLabel.hText - textGap
  
  self.soundLabelState = director:createLabel({
    x = self.soundLabel.x + self.soundLabel.wText,
    y = self.soundLabel.y,
    text = getTextOnOff(Resources.UserData.EnableSoundTrack),
    font=Resources.Fonts.HomeWhite})
  function self.soundLabelState:blinkNotify(event)
    if event.phase == "ended" then
      Resources.UserData.EnableSoundTrack = not Resources.UserData.EnableSoundTrack
      self.text = getTextOnOff(Resources.UserData.EnableSoundTrack)
      saveUserData()
    end
  end
  initButton(self.soundLabelState, false)
  
  -- Create the sound effects labels
  self.soundEffectsLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="SOUNDS: "})
  self.soundEffectsLabel.x = self.soundLabel.x
  self.soundEffectsLabel.y = self.soundLabel.y - self.soundEffectsLabel.hText - textGap
  
  self.soundEffectsLabelState = director:createLabel({
    x = self.soundEffectsLabel.x + self.soundEffectsLabel.wText,
    y = self.soundEffectsLabel.y,
    text = getTextOnOff(Resources.UserData.EnableSoundEffects),
    font=Resources.Fonts.HomeWhite})
  function self.soundEffectsLabelState:blinkNotify(event)
    if event.phase == "ended" then
      Resources.UserData.EnableSoundEffects = not Resources.UserData.EnableSoundEffects
      self.text = getTextOnOff(Resources.UserData.EnableSoundEffects)
      saveUserData()
    end
  end
  initButton(self.soundEffectsLabelState, false)
  
--  -- Create the auto submit labels
--  self.autoSubmitLabel = director:createLabel({
--    font=Resources.Fonts.HomeWhite,
--    color=color.black,
--    text="AUTO-SUBMIT: "})
--  self.autoSubmitLabel.x = self.soundEffectsLabel.x
--  self.autoSubmitLabel.y = self.soundEffectsLabel.y - self.autoSubmitLabel.hText
  
--  self.autoSubmitLabelState = director:createLabel({
--    x = self.autoSubmitLabel.x + self.autoSubmitLabel.wText,
--    y = self.autoSubmitLabel.y,
--    text = getTextOnOff(Resources.UserData.EnableAutoSubmit),
--    font=Resources.Fonts.HomeWhite})
--  function self.autoSubmitLabelState:blinkNotify(event)
--    if event.phase == "ended" then
--      Resources.UserData.EnableAutoSubmit = not Resources.UserData.EnableAutoSubmit
--      self.text = getTextOnOff(Resources.UserData.EnableAutoSubmit)
--      saveUserData()
--    end
--  end
--  initButton(self.autoSubmitLabelState, false)
  
  -- Create the notifications labels
  self.notificationsLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="NOTIFICATIONS: "})
  self.notificationsLabel.x = self.soundEffectsLabel.x
  self.notificationsLabel.y = self.soundEffectsLabel.y - self.notificationsLabel.hText - textGap
  
  self.notificationsLabelState = director:createLabel({
    x = self.notificationsLabel.x + self.notificationsLabel.wText,
    y = self.notificationsLabel.y,
    text = getTextOnOff(Resources.UserData.EnableNotifications),
    font=Resources.Fonts.HomeWhite})
  function self.notificationsLabelState:blinkNotify(event)
    if event.phase == "ended" then
      Resources.UserData.EnableNotifications = not Resources.UserData.EnableNotifications
      self.text = getTextOnOff(Resources.UserData.EnableNotifications)
      saveUserData()
    end
  end
  initButton(self.notificationsLabelState, false)
  
  -- Create the haptic feedback label
  self.hapticLabel = director:createLabel({
    font=Resources.Fonts.HomeWhite,
    color=color.black,
    text="HAPTIC: "})
  self.hapticLabel.x = self.notificationsLabel.x
  self.hapticLabel.y = self.notificationsLabel.y - self.hapticLabel.hText - textGap
  
  self.hapticLabelState = director:createLabel({
    x = self.hapticLabel.x + self.hapticLabel.wText,
    y = self.hapticLabel.y,
    text = getTextOnOff(Resources.UserData.EnableHapticFeedback),
    font=Resources.Fonts.HomeWhite})
  function self.hapticLabelState:blinkNotify(event)
    if event.phase == "ended" then
      Resources.UserData.EnableHapticFeedback = not Resources.UserData.EnableHapticFeedback
      self.text = getTextOnOff(Resources.UserData.EnableHapticFeedback)
      saveUserData()
    end
  end
  initButton(self.hapticLabelState, false)
  
  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.HomeWhite,
    color=Resources.Colors.Blue,
    text="BACK"})
  self.exitSprite.y = self.hapticLabelState.y -  self.exitSprite.hText - textGap - 10
  createBackSprite(false, Resources.Scenes.Main, nil, self.exitSprite)
  
  dbg.print("settingsScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("settingsScene - scene:tearDown")
  
  -- Clear out the globals created by this scene
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  self.soundLabel = tearDownSprite(self.soundLabel)
  self.soundLabelState = tearDownSprite(self.soundLabelState)
  self.soundEffectsLabel = tearDownSprite(self.soundEffectsLabel)
  self.soundEffectsLabelState = tearDownSprite(self.soundEffectsLabelState)
  --self.autoSubmitLabel = tearDownSprite(self.autoSubmitLabel)
  --self.autoSubmitLabelState = tearDownSprite(self.autoSubmitLabelState)
  self.notificationsLabel = tearDownSprite(self.notificationsLabel)
  self.notificationsLabelState = tearDownSprite(self.notificationsLabelState)
  self.hapticLabel = tearDownSprite(self.hapticLabel)
  self.hapticLabelState = tearDownSprite(self.hapticLabelState)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  self:releaseResources()
  dbg.print("settingsScene - scene:tearDown - complete")
end

-- Pretransition event
function scene:exitPreTransition(event)
end

-- Post enter transition
function scene:enterPostTransition(event)
end

-- Add setup and teardown event handlers
scene:addEventListener({"setUp", "tearDown", "exitPreTransition", "enterPostTransition"}, scene)

-- Return the scene we created
return scene