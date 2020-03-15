 -- Hold references to methods
 -- that are required for recursions
local funcTable = { }

-- Disable touches for this sprite and its children
function disableTouches(sprite, disableMe)
  if sprite ~= nil then
    if disableMe == nil then
      disableMe = false
    end
    
    if disableMe then
      sprite.isTouchable = false
    end
    
    if sprite.children ~= nil then
      for i,v in ipairs(sprite.children) do
        disableTouches(v, true)
      end
    end
  end
end

-- Activate a particle for the position
function activateParticle(centerX, centerY)
  for key,value in pairs(Resources.Particles) do
    if value ~= nil and not value:isActive() and value:getNumParticles() == 0 then
      value.sourcePos={centerX, centerY}
      value:reset()
      dbg.print("Activated particle " .. value.name)
      return
    end
  end
  dbg.print("ERROR: No particle available!")
end

-- Create a partycle system
function funcTable:createParticle(centerX, centerY)
  local explosion = director:createParticles({
    totalParticles=100,
    source=Resources.Atlases.Explosion,
    emitterMode=particles.modeGravity,
    emitterRate=1500/3.5,
    sourcePos={centerX, centerY},
    sourcePosVar={1, 1},
    duration=0.1,
    modeGravity={
        radialAccel=0, radialAccelVar=0,
        speed=75, speedVar=50},
    angle=360, angleVar=360,
    life=0.5, lifeVar=0.1,
    startColor={0, 0, 192}, startColorVar={0, 0, 128},
    endColor={0, 255, 255}, endColorVar={32, 177, 170},
    startSize=8.0, startSizeVar=2.0, endSize=0})
  explosion.zOrder = 2
  explosion:stop()
  return explosion
end

-- Initialize the particles
function initializeParticles()
  if Resources.Particles == nil then
    Resources.Particles = { }
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    table.insert(Resources.Particles, funcTable:createParticle(0, 0))
    dbg.print("Initialized all particles.")
  end
end

-- Teardown particles
function tearDownParticles()
  if Resources.Particles ~= nil then
    for key,value in pairs(Resources.Particles) do
      if value ~= nil then
        value:stop()
        dbg.print("Stopped particle " .. value.name)
      end
    end
    
    dbg.print("Tearing down particles")
    Resources.Particles = tearDownSprites(Resources.Particles)
  end
end

-- Pause a sprite and its children
function pauseSprite(sprite, children)
  if sprite ~= nil then
    dbg.print("pauseSprite - " .. sprite.name)
    if sprite.canPause ~= nil and sprite.canPause then
      sprite:pause()
    end
    sprite:pauseTimers()
    sprite:pauseTweens()
    if children == nil or children == true then
      funcTable:pauseSprites(sprite.children, children)
    end
  end
end

-- Resume a sprite and its children
function resumeSprite(sprite, children)
  if sprite ~= nil then
    dbg.print("resumeSprite - " .. sprite.name)
    if sprite.canPause ~= nil and sprite.canPause then
      sprite:play(sprite:getFrame())
    end
    sprite:resumeTimers()
    sprite:resumeTweens()
    if children == nil or children == true then
      funcTable:resumeSprites(sprite.children, children)
    end
  end
end

-- Play the haptic feedback
function playHapticFeedback()
  if Resources.UserData.EnableHapticFeedback then
    if device:isVibrationAvailable() and device:isVibrationEnabled() then
      device:vibrate(100, 50)
    end
  end
end

-- Pause sprites iterator function
function funcTable:pauseSprites(sprites, children)
  if sprites ~= nil then
    for key,value in pairs(sprites) do
      if value ~= nil then
        pauseSprite(value, children)
      end
    end
  end
end

-- Resume sprites iterator
function funcTable:resumeSprites(sprites, children)
  if sprites ~= nil then
    for key,value in pairs(sprites) do
      if value ~= nil then
        resumeSprite(value, children)
      end
    end
  end
end

-- Tear down the table of sprites
function tearDownTimers(timers)
  if timers ~= nil then
    for key,value in pairs(timers) do
      if value ~= nil then
        dbg.print("tearDownTimers - cleaned up timer " .. key)
        value:cancel()
      end
    end
  end
end

-- Tear down a sprites tweens
function tearDownSpriteTweens(sprite)
  if sprite ~= nil then
    dbg.print("tearDownSpriteTweens - cleaned up sprite " .. sprite.name)
    -- Cancel any open tweens
    if sprite.tweens ~= nil then
      for key,value in pairs(sprite.tweens) do
        if value ~= nil then
          dbg.print("tearDownSpriteTweens - cleaned up sprite " .. sprite.name .. " tween " .. key)
          tween:cancel(value)
        end
      end
    end
  end
end

-- Tear down a sprites timers
function tearDownSpriteTimers(sprite)
  if sprite ~= nil then
    dbg.print("tearDownSpriteTimers - cleaned up sprite " .. sprite.name)
    -- Cancel any open timers
    if sprite.timers ~= nil then
      for key,value in pairs(sprite.timers) do
        if value ~= nil then
          dbg.print("tearDownSpriteTimers - cleaned up sprite " .. sprite.name .. " timer " .. key)
          value:cancel()
        end
      end
    end
  end
end

-- Refresh the sprite physics
function refreshSpritePhysics(sprite)
  if sprite ~= nil then
    
--    if sprite.tx ~= nil and sprite.ty ~= nil then
--      sprite.physics:setTransform(sprite.tx, sprite.ty)
--    elseif sprite.tx ~= nil then
--      sprite.physics:setTransform(sprite.tx, sprite.y)
--    elseif sprite.ty ~= nil then  
--      sprite.physics:setTransform(sprite.x, sprite.ty)
--    end
    
    physics:removeNode(sprite)
    if sprite.tx ~= nil then
      sprite.x = sprite.tx
    end
    
    if sprite.ty ~= nil then
      sprite.y = sprite.ty
    end
    physics:addNode(sprite, {type="static"})
    
  end
end

-- Refresh the sprite physics
function refreshSpritesPhysics(sprites)
  if sprites ~= nil then
    for key,value in pairs(sprites) do
      if value ~= nil then
        refreshSpritePhysics(value)
      end
    end
  end
end

-- Tear down the sprite
function tearDownSprite(sprite)
  if sprite ~= nil then
    dbg.print("tearDownSprite - cleaned up sprite " .. sprite.name)
    -- Remove from physics simulation
    physics:removeNode(sprite)
    
    -- Cancel any open timers
    tearDownSpriteTimers(sprite)
    
    -- Cancel any open tweens
    tearDownSpriteTweens(sprite)
    
    return sprite:removeFromParent()
  else
    return nil
  end
end

-- Tear down the table of sprites
function tearDownSprites(sprites)
  if sprites ~= nil then
    for key,value in pairs(sprites) do
      if value ~= nil then
        sprites[key] = tearDownSprite(value)
      end
    end
  end
end

-- Save the user data
function saveUserData()
  local file = io.open(Resources.GameData.UserDataFile, "w")
  if file ~= nil then
    local encoded = json.encode(Resources.UserData)
    local encrypted = crypto:base64Encode(encoded)
    file:write(encrypted)
    file:close()
  end
end

 -- Load the user data
function loadUserData()
  local file = io.open(Resources.GameData.UserDataFile)
  if file ~= nil then
    local encrypted = file:read("*a")
    local encoded = crypto:base64Decode(encrypted)
    local data = json.decode(encoded)
    if data ~= nil then
      for key,value in pairs(data) do
        if Resources.UserData[key] ~= nil then
          dbg.print("loadUserData - loaded " .. key)
          Resources.UserData[key] = value
        else
          dbg.print("loadUserData - ignored " .. key)
        end
      end
    end
    file:close()
  end
  dbg.print("User Data Table:")
  dbg.printTable(Resources.UserData)
end

-- Load all sound
function loadSound()
  audio:setSoundFrequency(Resources.GameData.SoundFrequency)
  audio:loadStream(Resources.Sounds.Soundtrack)
  
  for key,value in pairs(Resources.Sounds) do
    if value ~= nil and value ~= Resources.Sounds.Soundtrack then
      audio:loadSound(value)
    end
  end
end

-- Unload all sound
function unloadSound()
  for key,value in pairs(Resources.Sounds) do
    if value ~= nil and value ~= Resources.Sounds.Soundtrack then
      audio:unloadSound(value)
    end
  end
end

-- Update the sound
function updateSound(forceOff, pauseResume)
  forceOff = forceOff or false
  pauseResume = pauseResume or false
  local playing = audio:isStreamPlaying()
  if forceOff == true then
    if playing == true then
      audio:stopStream()
    end
  elseif Resources.UserData.EnableSoundTrack == true then
    if playing == false then
      if pauseResume == true then
        audio:resumeStream()
      else
        audio:playStream(Resources.Sounds.Soundtrack, true)
      end
    elseif pauseResume == true then
      audio:pauseStream()
    end
  elseif playing == true then
    audio:stopStream()
  end
end

-- Play the game sound
function playGameSound(sound)
  if Resources.UserData.EnableSoundEffects == true then
    audio:playSound(sound)
  end
end

-- Tear down table
function tearDownTable(table)
  if table ~= nil then
    for key,value in pairs(table) do
      value = nil
      table[key] = nil
    end
  end
  return nil
end

-- Remove the game resources
function removeGameResources()
  dbg.print("removing game resources...")
  
  -- Cleanup all the global resources we stored.
  if Resources ~= nil then
    dbg.print("removing game resources - processing table...")
    
    -- Disable sounds and unload them
    dbg.print("unloading sounds...")
    Resources.EnableSoundTrack = false
    Resources.EnableSoundEffects = false
    updateSound(true)
    unloadSound()
    
    -- Manually tear down the current scene since
    -- if we used a traditional move to scene operation
    -- the scene would not actually get torn down
    -- in time before the application exits and fail
    -- to release resources...
    dbg.print("unloading scenes...")
    local currentScene = director:getCurrentScene()
    if currentScene ~= nil and currentScene.tearDown ~= nil then
      dbg.print("removing game resources - tearing down current scene...")
      currentScene:tearDown()
    end
    
    -- Clear out all the scenes we stored as resources
    for key,value in pairs(Resources.Scenes) do
      value:releaseResources()
    end
    Resources.Scenes = tearDownTable(Resources.Scenes)
    
    -- Unload the animations
    dbg.print("unloading animations...")
    Resources.Animations = tearDownTable(Resources.Animations)
    
    -- Clean out atlases
    dbg.print("unloading atlases...")
    Resources.Atlases = tearDownTable(Resources.Atlases)
    
    -- Destroy the fonts
    dbg.print("unloading fonts...")
    Resources.Fonts = tearDownTable(Resources.Fonts)
    
    -- Onload the particles
    dbg.print("unloading particles...")
    tearDownParticles()
    
    -- Clear the resources reference
    Resources = tearDownTable(Resources)
  end
  
  -- Terminate scoreloop
  scores:terminate()
  
  -- Clear the current scene reference
  -- and cleanup existing textures
  director:setCurrentScene(nil)
  director:cleanupTextures()
  
  -- Collect all garbage before we exit.
  collectgarbage()
end

-- Create back sprite
function createBackSprite(quit, scene, notify, label)
  local sprite = label
  sprite.quit = quit
  sprite.scene = scene
  sprite.notify = notify
  
  -- The back function for this sprite
  function sprite:back()
    if self.notify ~= nil then
      self.notify()
      self.notify = nil
    end
    if self.quit ~= nil and self.quit == true then
      dbg.print("invoking system exit...")
      self.scene = nil
      director:moveToScene(nil)
      system:quit()
    elseif self.scene ~= nil then
      moveToGameScene(self.scene)
      self.scene = nil
    end
  end
  
  -- Hook up the exit sprite to touch events
  function sprite:blinkNotify(event)
    if event.phase == "ended" then
      self:back()
    end
  end
  initButton(sprite, true, true)
  
  -- Hook up the exit sprite to key events
  function sprite:key(event)
    if event.phase == "pressed" then
      if event.keyCode == key.back or event.keyCode == key.backspace then
        self:back()
      end
    end
  end
  sprite:addEventListener("key", sprite)
  
  return sprite
end

-- Tear down the back sprite
function tearDownBackSprite(sprite)
  if sprite ~= nil then
    sprite.scene = nil
    sprite:removeEventListener("touch", sprite)
    sprite:removeEventListener("key", sprite)
  end
  return tearDownSprite(sprite)
end

-- Determine if this is a top score
function isTopScore(score, time, level)
  local topScore = false
  score = score or 0
  time = time or 0
  level = level or 0
  
  if Resources.UserData.TopScore < score then
    topScore = true
  elseif Resources.UserData.TopScore == score and
    Resources.UserData.TopTime < time then
    topScore = true
  elseif Resources.UserData.TopScore == score and
    Resources.UserData.TopTime == time and
    Resources.UserData.TopLevel < level then
    topScore = true
  elseif Resources.UserData.TopScore == score and
    Resources.UserData.TopTime == time and
    Resources.UserData.TopLevel == level then
    topScore = true
  end

  return topScore
end

-- Blink fade in for sprite
function funcTable:blinkFadeIn(sprite)
  tween:to(sprite,
    {
      alpha=1,
      time=0.15,
      onComplete=
        function(target)
          if target.blinkNotify ~= nil then
            local blinkEvent = { }
            blinkEvent.phase = "ended"
            target:blinkNotify(blinkEvent)
          end
        end
    })
end

-- Blink fade out for sprite
function funcTable:blinkFadeOut(sprite)
  if sprite.blinkNotify ~= nil then
    local blinkEvent = { }
    blinkEvent.phase = "started"
    sprite:blinkNotify(blinkEvent)
  end
  tween:to(sprite,
    {
      alpha=0.25,
      time=0.15,
      onComplete=
        function(target)
          funcTable:blinkFadeIn(target)
        end
    })
end

-- Initialize the button
function initButton(sprite, blink, transition)
  if blink == nil then
    sprite.blink = true
  else
    sprite.blink = blink
  end
  
  if transition == nil then
    transition = false
  end
  sprite.transition = transition
  
  function sprite:touch(event)
    if event.phase == "began" and event.id == 1 then
      dbg.print("initButton - touch began " .. self.name)
      if self.transition then
        disableTouches(director:getCurrentScene(), false)
      end
      playHapticFeedback()
      if self.blink then
        funcTable:blinkFadeOut(self)
      elseif self.blinkNotify ~= nil then
        local blinkEvent = { }
        blinkEvent.phase = "ended"
        self:blinkNotify(blinkEvent)
      end
      return true
    end
  end
  sprite:addEventListener("touch", sprite)
end

-- Create scoreloop sprite
function createScoreloopSprite()
  local scoreloopSprite = director:createSprite({source = Resources.Animations.Scoreloop})
  function scoreloopSprite:touch(event)
    if event.phase == "began" then
      if browser:isAvailable() then
        local platform = device:getInfo("platform")
        local url = "http://www.scoreloop.com/"
        if platform == "ANDROID" then
          url = "https://play.google.com/store/apps/details?id=com.scoreloop.android.slapp"
        elseif platform == "IPHONE" then
          url = "https://itunes.apple.com/us/app/scoreloop-community/id322303167?mt=8"
        end
        browser:launchURL(url, false)
      end
    end
  end
  scoreloopSprite:addEventListener("touch", scoreloopSprite)
  return scoreloopSprite
end

-- Prepare the banner ad
function showAd(x, y)
  if ads:isAvailable() then
    ads:newAd(y, Resources.Ads.BannerHeight, "leadbolt", "banner", Resources.Ads.LeadBoltBannerID, x, Resources.Ads.BannerWidth)
--  else
--    dbg.print("ERROR: Ads not available")
  end
end

-- Hide the banner ad
function hideAd()
  if ads:isAvailable() then
    ads:show(false)
--  else
--    dbg.print("ERROR: Ads not available")
  end
end