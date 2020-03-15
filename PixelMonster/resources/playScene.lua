-- Create our scene
local scene = director:createScene()

-- Table for private scene functions
-- that have cross dependencies and cannot
-- be ordered and should be private to
-- the scenes internals
local sceneLocal = {}

------------------------------------------------------------------------
-- Local Members
------------------------------------------------------------------------

-- Game over notify
local function gameOverNotify()
  scene.gameOverFlag = true
end

-- Determine if something should happen based
-- on the current level, earlier levels have
-- better probability while later levels have
-- worse probability.
local function randOccurForLevel(inverse)
  inverse = inverse or false
  local occur = false
  local randA = math.random() * 100
  local randB = scene.currentLevel / (Resources.GameData.MaxLevel - 1) * 100
  if randA >= randB then
    occur = true
  end
  
  if inverse then
    return not occur
  else
    return occur
  end
end

-- Setup the pixel for death
local function setPixelDead(sprite, stopPhysics)
  if sprite ~= nil then
    if stopPhysics ~= nil and stopPhysics == true then
      physics:removeNode(sprite)
    end
    sprite.isDead = true
    scene.deadPixelSprites[sprite.name] = sprite
    scene.livePixelSprites[sprite.name] = nil
  end
end

-- Clear the dead pixels
local function clearDeadPixels()
  tearDownSprites(scene.deadPixelSprites)
end

-- Fade out the monster
local function fadeOutMonster(monster)
  local newColor = nil
  tween:to(monster,
    {
      alpha=0.2,
      time=8,
      onComplete=
        function(target)
          -- When this tween has completed remove the
          -- sprite from the game so that it cannot be
          -- counted as a point.
          dbg.print("createPixelTimer - tween - onComplete - fade out " .. target.name)
          target.debugDraw = false
          target.alpha = 0
          if target.isDead == false then
            local centerX, centerY = target:getPointInWorldSpace(target.w/2, target.h/2)
            activateParticle(centerX, centerY)
            setPixelDead(target, true)
            if target.isPowerup == false and scene.monsterSprite.isInvincible == false then
              scene:removeLife("on pixel monster fade out complete")
            end
          end
        end
    })
end

-- Fade in the monster
local function fadeInMonster(monster)
  tween:to(monster,
    {
      alpha=1,
      time=1,
      onComplete=
        function(target)
          dbg.print("createPixelTimer - tween - onComplete - fade in " .. target.name)
          fadeOutMonster(target)
        end
    })
end

-- Monster invincible clock elapsed function
local function invincibleTimerElapsed(event)
  scene:updateInvincible(false)
end

local function hurtTimerElapsed(event)
  scene:updateHurt(false)
end

-- Create the pixel which can be a powerup
-- or any other interactive pixel that we need
local function createPixel(powerUp)
  -- Generate the random pixel sprite
  local pixelBomb = false
  local forceBomb = false
  local heavyBomb = false
  local spriteRes = nil
  local points = 0
  local randForce = 0
  local randForceAngular = 0
  local densityOverride = nil
  local frictionOverride = nil
  local restitionOverride = 0.5
  local frame = 1
  local playAnimation = false
  local canPause = false
  
  if powerUp == true then
    if scene.allowNewPowerup == false or scene.gameClockTicks < scene.nextPowerupTicks then
      return -- Do not create any powerup
    end
    
    local createPowerup = randOccurForLevel()
    if createPowerup == false then
      return -- Do not create any powerup
    end
    
    -- Create the power up
    playAnimation = true
    scene.allowNewPowerup = false
    spriteRes = Resources.Animations.Powerups
    canPause = true
  else
    -- Based on the current level determine
    -- which pixel monsters we should be generating
    local randMin = 1
    local randMax = 1
    if scene.currentLevel == Resources.GameData.MaxLevel - 1 then
      randMin = 6 -- Bomb
      randMax = 6 -- Bomb
    elseif scene.currentLevel >= 16 then
      randMax = 6 -- Bomb
    elseif scene.currentLevel >= 12 and randOccurForLevel() then
      randMax = 6 -- Bomb
    elseif scene.currentLevel >= 8 then
      randMax = 5 -- Force
    elseif scene.currentLevel >= 5 then
      randMax = 4 -- Heavy
    elseif scene.currentLevel >= 3 then
      randMax = 3 -- Small
    else
      randMax = 2 -- Large and medium
    end
    
    local rand = math.random(randMin, randMax)
    if rand == 1 then
      spriteRes = Resources.Animations.LargePixel
      points = Resources.Points.LargePixel
      randForce = 10
      randForceAngular = 2
    elseif rand == 2 then
      spriteRes = Resources.Animations.MediumPixel
      points = Resources.Points.MediumPixel
      randForce = 5
      randForceAngular = 1
    elseif rand == 3 then
      spriteRes = Resources.Animations.SmallPixel
      points = Resources.Points.SmallPixel
      randForce = 1
      randForceAngular = 1
    elseif rand == 4 then
      spriteRes = Resources.Animations.HeavyPixel
      points = Resources.Points.HeavyPixel
      randForce = 125
      randForceAngular = 15
      densityOverride = 50
      heavyBomb = true
      restitionOverride = 1
    elseif rand == 5 then
      spriteRes = Resources.Animations.ForcePixel
      points = Resources.Points.ForcePixel
      randForce = 10
      randForceAngular = 2
      frictionOverride = 1
      forceBomb = true
    elseif rand == 6 then
      spriteRes = Resources.Animations.PixelBomb
      points = Resources.Points.PixelBomb
      randForce = 10
      randForceAngular = 2
      pixelBomb = true
    end
  end
  
  -- Create the pixel
  local pixelSprite = director:createSprite({
      x = 0,
      y = 0,
      source = spriteRes})
  if playAnimation == true then
    pixelSprite:play({ startFrame = frame })
  else
    pixelSprite:setFrame(frame)
  end
  scene.livePixelSprites[pixelSprite.name] = pixelSprite
  
  -- Calculate the pixel location based on what direction
  -- the cannon is facing towards...
  pixelSprite.x = scene.pixelCannonSprite.x + scene.pixelCannonSprite.w/2 - pixelSprite.w/2
  pixelSprite.y = scene.pixelCannonSprite.y + scene.pixelCannonSprite.h/2 - pixelSprite.h/2
  pixelSprite.alpha = 0.2
  
  -- Set the pause flag
  pixelSprite.canPause = canPause
  
  -- Set the remaining sprite properties
  pixelSprite.isPowerup = powerUp
  pixelSprite.isPowerupGranted = false
  
  pixelSprite.isForceBomb = forceBomb
  pixelSprite.isActiveForceBomb = true
  
  pixelSprite.isPixelBomb = pixelBomb
  pixelSprite.isActiveBomb = true
  
  pixelSprite.isHeavyBomb = heavyBomb
  pixelSprite.isActiveHeavyBomb = true
  
  pixelSprite.isDead = false
  pixelSprite.points = points
  pixelSprite.randForce = randForce
  pixelSprite.randForceAngular = randForceAngular
  
  -- Add the pixel to the physics engine
  physics:addNode(pixelSprite,
    {
      friction = frictionOverride,
      density = densityOverride,
      restitution = restitionOverride
    })
  
  -- Fade in and out the pixel sprite so that the user
  -- only has a specific amount of time to get it
  fadeInMonster(pixelSprite)
  
  -- Apply a random impulse force to the pixel
  -- to give it a random direction...
  local randForceDirection = math.random(0 - pixelSprite.randForce, pixelSprite.randForce)
  pixelSprite.physics:applyLinearImpulseToCenter(randForceDirection)
  --pixelSprite.physics:applyAngularImpulse(randForceAngular)
  
  dbg.print("createPixel - created pixel monster " .. pixelSprite.name)
end

-- Create pixel timer elapsed function
local function createPixelTimerElapsed(event)
  -- Create pixel sprites
  local numPixels = scene.currentLevel
  if numPixels > Resources.GameData.MaxPixelMonsterPortal then
    numPixels = Resources.GameData.MaxPixelMonsterPortal
  end
  for i=1,numPixels do
    createPixel(false)
  end
  createPixel(true)
end

-- Display a notification
local function displayNotification(message, target, bad)
  if Resources.UserData.EnableNotifications == true then
    -- Notify the user with the messageg.
    local textColor = Resources.Colors.Blue
    if bad ~= nil and bad == true then
      textColor = Resources.Colors.Red
    end
    
    local notificationLabel = director:createLabel({
        font=Resources.Fonts.PlayWhite,
        color=textColor,
        zOrder = 1,
        text=message})
    scene.notificationLabels[notificationLabel.name] = notificationLabel
    
    -- Get the world point of the monster based on
    -- its local center coordinates.  This allows us
    -- to always get the center of the monster sprite
    -- even when its rotated, which if using the normal
    -- x,y cooridnates we would always be showing notifications
    -- relative to that corner of the monster, which if
    -- rotated would show up and odd locations rather than
    -- the center of the monster...
    local centerX, centerY = target:getPointInWorldSpace(target.w/2, target.h/2)
    notificationLabel.x = centerX - notificationLabel.wText/2
    notificationLabel.y = centerY + target.h/2
    dbg.print("Created notification " .. notificationLabel.name .. " " .. message)
    
    -- Fade out the notification
    tween:to(
      notificationLabel,
      {
        y = director.displayHeight/2,
        alpha = 0,
        time=1.5,
        onComplete=
          function(target)
            scene.notificationLabels[target.name] = tearDownSprite(target)
            dbg.print("Destroyed notification " .. target.name)
          end
      })
  end
end

-- Add a life to the user
local function addLife(message)
  dbg.print("added life " .. message)
  scene.lives = scene.lives + 1
  scene.lifeLabel.text = "LIVES: " .. scene.lives
  
  -- Set danger state
  sceneLocal:updateDanger(true)
  
  -- Notify the user that a new life was earned.
  displayNotification("+1 life", scene.monsterSprite)
end

-- Remove a life from the user
local function removeLife(message)
  if Resources.GameData.Invincible == false then
    dbg.print("removed life " .. message)
    scene.lives = scene.lives - 1
    scene.lifeLabel.text = "LIVES: " .. scene.lives
    
    -- Notify the user that a new life was earned.
    displayNotification("-1 life", scene.monsterSprite, true)
    
    -- Play hurt sound
    sceneLocal:playSound(Resources.Sounds.Hurt)
    
    -- Update the monster as hurt
    scene:updateHurt(true)
    
    -- Set danger state
    sceneLocal:updateDanger(false)
    
    -- End the game
    if scene.lives == 0 then
      dbg.print("game over - lost all lives")
      scene.gameOverFlag = true
    end
  end
end

-- Level timer elapsed
local function levelTimerElapsed(event)
  if scene.levelLabel.blinkTween ~= nil then
    tween:cancel(scene.levelLabel.blinkTween)
    scene.levelLabel.blinkTween = nil
  end
end

-- Update the level
local function updateLevel(iterations)
  -- Calculate the new level
  local level = math.floor((iterations/Resources.GameData.LevelDuration + 1))
  if scene.currentLevel < level then
    if level == Resources.GameData.MaxLevel then
      -- Do not continue the game
      Resources.Scenes.End.won = true
    end
    
    scene.allowNewPowerup = true
    scene.currentLevel = level

    if level >= Resources.GameData.MaxLevel then
      scene.levelLabel.text = "BONUS LEVEL " .. level
    else
      scene.levelLabel.text = "LEVEL " .. level .. " OF " .. Resources.GameData.MaxLevel - 1
    end
    
    scene.nextPowerupTicks = math.random(0, 59) + iterations
    dbg.print("next powerup at " .. scene.nextPowerupTicks)
    
    if level > 1 then
      sceneLocal:playSound(Resources.Sounds.Level)
      
      -- Blink the level label
      scene.levelLabel.blinkTween = tween:to(
        scene.levelLabel,
        {
          alpha = 0,
          time=0.5,
          mode="mirror"
        })
      
      -- Add a timer to stop the tween since we
      -- can't bound it with a repeating tween
      scene.levelLabel:addTimer(levelTimerElapsed, 5, 1, 0)
    end
    
    -- Create a new peg if needed
    sceneLocal:createPeg()
    sceneLocal:movePegs()
  end
  
  -- Continue the game
  return true
end

-- Game clock elapsed function
local function gameClockTimerElapsed(event)
  if scene.gameOverFlag == false then
    scene.gameClockTicks = event.doneIterations
    scene.gameClockLabel.text = "TIME: " .. event.doneIterations
    local continueGame = updateLevel(event.doneIterations)
    if continueGame then
      -- Update the portal animation
      scene.pixelCannonSprite:setFrame(scene.pixelCannonSprite.nextFrame)
      
      -- Piggy back on the game clock timer
      -- and execute every 3 iterations.
      if event.doneIterations % 3 == 0 then
        scene.pixelCannonSprite.nextFrame = 1
        createPixelTimerElapsed(event)
      else
        scene.pixelCannonSprite.nextFrame = scene.pixelCannonSprite.nextFrame + 1
      end
    else
      scene.gameOverFlag = true
    end
  end
end

-- The system update handler
local function systemUpdateHandler(event)
  if scene.gameOverFlag == true then
    scene:gameOver()
  else
    -- Cleanup dead pixel sprites
    clearDeadPixels()
    
    -- Refresh the nodes physics props
    refreshSpritesPhysics(scene.physicsUpdateSprites)
    
    -- Move the powerup sprite
    sceneLocal:movePowerupSprite()
  end
end

-- Monster touch clock elapsed function
local function monsterTouchTimerElapsed(event)
  scene.monsterSprite:cancelTouchJoint()
end

-- Web view events handler
local function adsWebViewLoadedEvent(event)
  -- TODO: handle errors
end

------------------------------------------------------------------------
-- Scene Local Members
------------------------------------------------------------------------

-- Update the danger state
function sceneLocal:updateDanger(newLife)
  if not newLife and scene.lives == 1 then
    tween:to(
      scene.monsterSprite,
      {
        alpha = 0.2,
        time=0.5,
        mode="mirror"
      })
    tween:to(
      scene.lifeLabel,
      {
        alpha = 0,
        time=0.5,
        mode="mirror"
      })
  elseif newLife and scene.lives == 2 then
    tearDownSpriteTweens(scene.monsterSprite)
    scene.monsterSprite.alpha = 1
    tearDownSpriteTweens(scene.lifeLabel)
    scene.lifeLabel.alpha = 1
  end
end

-- Clear the pixel
function sceneLocal:clearPixel(pixelNode, portalNode)
  if pixelNode.name == "monster" then
    return
  end
  
  if portalNode ~= nil then
    tearDownSpriteTweens(pixelNode)
    tween:to(pixelNode,
        {
          alpha = 0,
          rotation = 0,
          h = 0,
          w = 0,
          x = portalNode.x + portalNode.w/2 - pixelNode.w/2,
          y = portalNode.y + portalNode.h/2 - pixelNode.h/2,
          time=0.5,
          onStart=
            function(target)
              physics:removeNode(pixelNode)
            end,
          onComplete=
            function(target)
              sceneLocal:removePixel(target)
            end
        })
  else
    sceneLocal:removePixel(pixelNode)
  end
end

-- Remove the pixel
function sceneLocal:removePixel(pixelNode)
  dbg.print("removePixel - " .. pixelNode.name)
  local destroyNode = pixelNode
  local parentScene = pixelNode:getParent()
  
  if parentScene.gameOverFlag == false and destroyNode.isDead == false and destroyNode.isPowerupGranted == false then
    dbg.print("removePixel - flagged dead pixel for cleanup - " .. destroyNode.name)
    setPixelDead(destroyNode)
    
    -- Pixel bombs are harder to clear,
    -- so they are worth extra points
    if destroyNode.points > 0 then
      local oldDeadSpriteCounter = parentScene.deadSpriteCounter
      parentScene.deadSpriteCounter = parentScene.deadSpriteCounter + destroyNode.points
      parentScene.pointLabel.text = "SCORE: " .. parentScene.deadSpriteCounter
      displayNotification("+" .. destroyNode.points, destroyNode)
      sceneLocal:playSound(Resources.Sounds.Point)
      
      -- Check if the new score is exactly on the
      -- value needed for a new life... otherwise
      -- if we went over the values between the old
      -- and new value to see if we should grant a
      -- new life.
      if (parentScene.deadSpriteCounter % Resources.GameData.PointsExtraLife) == 0 then
        addLife("on point " .. parentScene.deadSpriteCounter)
      else
        for i=oldDeadSpriteCounter+1,parentScene.deadSpriteCounter do
          if (i % Resources.GameData.PointsExtraLife) == 0 then
            addLife("on point " .. parentScene.deadSpriteCounter .. " for " .. i)
            break
          end
        end
      end
    end
  end
end

-- Play the game sound
function sceneLocal:playSound(sound)
  if not scene.paused then
    playGameSound(sound)
  end
end

-- Display the powerup effect
function sceneLocal:displayPowerupEffect(monster, powerupFrame)
  dbg.print("displaying powerup effect " .. powerupFrame)
  
  local effectColor = nil
  if powerupFrame == Resources.Frames.Powerups.Clear then
    effectColor = {r=3, g=111, b=110}
  elseif powerupFrame == Resources.Frames.Powerups.Energy then
    effectColor = {r=41, g=186, b=246}
  elseif powerupFrame == Resources.Frames.Powerups.Sonic then
    effectColor = {r=251, g=195, b=15}
  end

  local centerX, centerY = monster:getPointInWorldSpace(monster.w/2, monster.h/2)
  local effect = director:createCircle({
        x = centerX, y = centerY,
        xAnchor=0.5, yAnchor=0.5,
        radius=1,
        color={r=0, g=0, b=0, a=0},
        strokeColor=effectColor,
        strokeWidth=8
      })
  scene.powerupEffects[effect.name] = effect
  tween:to(effect,
    {
      strokeWidth=0,
      strokeAlpha=0,
      radius=director.displayWidth,
      time=0.6,
      onComplete=
        function(target)
          scene.powerupEffects[target.name] = tearDownSprite(effect)
        end
    })
end

-- Clear the live pixels
function sceneLocal:clearLivePixels()
  if scene.livePixelSprites ~= nil then
    for key,value in pairs(scene.livePixelSprites) do
      if value ~= nil and value.isPowerup == false then
        sceneLocal:clearPixel(value)
      end
    end
  end
end

-- Stun all live pixels
function sceneLocal:stunLivePixels()
  if scene.livePixelSprites ~= nil then
    for key,pixelNode in pairs(scene.livePixelSprites) do
      if pixelNode ~= nil and pixelNode.isPowerup == false then
        if pixelNode.isForceBomb == true and pixelNode.isActiveForceBomb == true then
          pixelNode.isActiveForceBomb = false
          pixelNode:setFrame(Resources.Frames.ForcePixel.Stunned)
        end
        
        if pixelNode.isHeavyBomb == true and pixelNode.isActiveHeavyBomb == true then
          pixelNode.isActiveHeavyBomb = false
          pixelNode:setFrame(Resources.Frames.HeavyPixel.Stunned)
          pixelNode.physics:setRestitution(0.65)
        end
        
        if pixelNode.isPixelBomb == true and pixelNode.isActiveBomb == true then
          pixelNode.isActiveBomb = false
          pixelNode:setFrame(Resources.Frames.PixelBomb.Stunned)
        end
      end
    end
  end
end

-- Set the gravity of all live pixels
function sceneLocal:gravityLivePixels(forceFactor)
  if scene.livePixelSprites ~= nil then
    for key,pixelNode in pairs(scene.livePixelSprites) do
      if pixelNode ~= nil and pixelNode.isPowerup == false then
        pixelNode.color = color.yellow
        pixelNode.physics:setRestitution(0)
        pixelNode.physics:setGravityScale(5)
      end
    end
  end
end

-- Move the live pixels
function sceneLocal:moveLivePixels(forceFactor)
  if scene.livePixelSprites ~= nil then
    -- Generate a random impulse force on
    -- any pixels that are still alive...
    for key,value in pairs(scene.livePixelSprites) do
      if value.physics ~= nil then
        dbg.print("moveLivePixels - applying force to pixel - " .. value.name)
        -- Factor the force of the move based on the level
        value.color = color.lightBlue
        value.physics:setGravityScale(0)
        local adjustedRandForce
        if forceFactor ~= nil then
          adjustedRandForce = value.physics.density * forceFactor
        else
          adjustedRandForce = value.randForce + (value.randForce * (scene.currentLevel/10))
        end
        value.physics:applyLinearImpulse(
          math.random(0 - adjustedRandForce, adjustedRandForce),
          math.random(0 - adjustedRandForce, adjustedRandForce))
        local adjustedRandAngularForce = value.randForceAngular + (value.randForceAngular * (scene.currentLevel/10))
        value.physics:applyAngularImpulse(
          math.random(0 - adjustedRandAngularForce, adjustedRandAngularForce),
          math.random(0 - adjustedRandAngularForce, adjustedRandAngularForce))
      end
    end
  end
end

-- Create a peg
function sceneLocal:createPeg()
  local peg = nil
  local resource = nil
  if scene.currentLevel == 12 then
    resource = Resources.Animations.PegCircleSmall
  elseif scene.currentLevel == 15 then
    resource = Resources.Animations.PegCircleMedium
  elseif scene.currentLevel == 17 then
    resource = Resources.Animations.PegCircleLarge
  end
  if resource ~= nil then
    peg = director:createSprite({
      x = 0,
      y = 0,
      alpha = 0.2,
      source = resource})
    peg.x = scene.pixelCannonSprite.x + scene.pixelCannonSprite.w/2 - peg.w/2
    peg.y = scene.pixelCannonSprite.y + scene.pixelCannonSprite.h/2 - peg.h/2
    peg.firstMove = true
    scene.pegPixelSprites[peg.name] = peg
    dbg.print("createPeg - " .. peg.name .. " at level " .. scene.currentLevel)
  end
end

-- Get peg coords
function sceneLocal:getPegCoords(peg)
  local coords = {}
  coords.x = math.random(
    scene.leftSideSprite.x + scene.leftSideSprite.w + 50,
    scene.rightSideSprite.x - peg.w - 50)
  coords.y = math.random(
    scene.bottomSprite.y + scene.bottomSprite.h + 75,
    scene.topSprite.y - peg.h - 75)
  coords.w = peg.w
  coords.h = peg.h
  return coords
end

-- Check if a sprite is inside another sprite
function sceneLocal:doesIntersect(a, b, offset)
  if (a.x + a.w < b.x - offset) then return false end -- a is left of b
  if (a.x > b.x + b.w + offset) then return false end -- a is right of b
  if (a.y + a.h < b.y - offset) then return false end -- a is above b
  if (a.y > b.y + b.h + offset) then return false end -- a is below b
  return true -- boxes overlap
end

-- Set the peg coords
function sceneLocal:setPegCoords(coords)
  for key,value in pairs(scene.pegPixelSprites) do
    coords[value.name] = sceneLocal:getPegCoords(value)
  end
  
  for key1,value1 in pairs(coords) do
    for key2,value2 in pairs(coords) do
      if key1 ~= key2 then
        if sceneLocal:doesIntersect(value1, value2, 25) then
          dbg.print("setPegCoords - warn invalid coordinates")
          return false
        end
      end
    end
  end
  
  dbg.print("setPegCoords - valid coordinates")
  return true
end

-- Move the pegs
function sceneLocal:movePegs()
  local continue = true
  local coords = nil
  
  while continue do
    coords = {}
    continue = not sceneLocal:setPegCoords(coords)
  end
  
  for key,value in pairs(scene.pegPixelSprites) do
    sceneLocal:positionPeg(value, coords[value.name])
  end
end

-- Fade out the peg
function sceneLocal:fadeOutPeg(peg)
  tween:to(peg,
    {
      alpha = 0,
      time=1,
      onComplete=
        function(target)
          target.alpha = 0
          target.x = target.destinationCoords.x
          target.y = target.destinationCoords.y
          sceneLocal:fadeInPeg(target)
        end
    })
end

-- Fade in the peg
function sceneLocal:fadeInPeg(peg)
  tween:to(peg,
    {
      alpha = 1,
      time=1,
      onComplete=
        function(target)
          dbg.print("adding peg to physics - " .. target.name)
          physics:addNode(target, {type="static"})
          target.physics.radius = target.w/2
        end
    })
end

-- First move of the peg
function sceneLocal:firstMovePeg(peg)
  tween:to(peg,
    {
      x = peg.destinationCoords.x,
      y = peg.destinationCoords.y,
      alpha = 1,
      time=1,
      onComplete=
        function(target)
          dbg.print("adding peg to physics - " .. target.name)
          physics:addNode(target, {type="static"})
          target.physics.radius = target.w/2
        end
    })
end

-- Position the peg
function sceneLocal:positionPeg(peg, coords)
  dbg.print("positionPeg - " .. peg.name .. " at level " .. scene.currentLevel)
  peg.destinationCoords = coords
  physics:removeNode(peg)
  if peg.firstMove then
    peg.firstMove = false
    sceneLocal:firstMovePeg(peg)
  else
    sceneLocal:fadeOutPeg(peg)
  end
end

-- Set the powerup preview
function sceneLocal:setPowerupPreview()
  dbg.print("setPowerupPreview")
  local nextpu = scene.powerupQueue[2]
  if nextpu ~= nil then
    scene.powerupBoxPreviewSprite.alpha = 0.4
    scene.powerupBoxPreviewSprite:setFrame(nextpu:getFrame())
  else
    scene.powerupBoxPreviewSprite.alpha = 0
  end
end

-- Set the current powerup
function sceneLocal:setPowerupCurrent()
  dbg.print("setPowerupCurrent")
  local currentpu = scene.powerupQueue[1]
  if currentpu ~= nil then
    sceneLocal:setupPowerupTouch(currentpu)
  end
end

-- Dequeue from the powerup queue
function sceneLocal:dequeueFromPowerupQueue()
  dbg.print("dequeueFromPowerupQueue")
  table.remove(scene.powerupQueue, 1)
  scene.powerupCount = scene.powerupCount - 1
  
  if scene.powerupCount < 1 then
    scene.powerupBoxLabel.alpha = 0
  else
    scene.powerupBoxLabel.text = scene.powerupCount
  end
  
  sceneLocal:setPowerupCurrent()
  sceneLocal:setPowerupPreview()
  dbg.printTable(scene.powerupQueue)
end

-- Setup the powerup touch event handler
function sceneLocal:setupPowerupTouch(target)
  -- Hook up the powerup sprite to touch events
  function target:touch(event)
    if event.phase == "began" then
      dbg.print("setupPowerupTouch - touch - began")
      if self.powerUpApply ~= nil then
        tween:to(self,
          {
            alpha = 0,
            time=0.2,
            onComplete=
              function(tweenTarget)
                sceneLocal:dequeueFromPowerupQueue()
                tweenTarget.powerUpApply(scene.monsterSprite, tweenTarget)
                tearDownSprite(tweenTarget)
                sceneLocal:playSound(Resources.Sounds.Powerup)
              end
          })
      end
      self.isTouchable = false
      return true
    end
  end
  target:addEventListener("touch", target)
  tween:to(target,
    {
      alpha = 1,
      time=0.2,
      onComplete=
        function(tweenTarget)
          tweenTarget.isTouchable = true
        end
    })
  dbg.print("setupPowerupTouch - set next powerup")
end

-- Enqueue to the powerup queue
function sceneLocal:enqueueToPowerupQueue(target)
  dbg.print("addToPowerupQueue - " .. target.name)
  table.insert(scene.powerupQueue, target)
  scene.powerupCount = scene.powerupCount + 1
  scene.powerupBoxLabel.text = scene.powerupCount
  scene.powerupBoxLabel.alpha = 1
  sceneLocal:setPowerupCurrent()
  sceneLocal:setPowerupPreview()
  dbg.printTable(scene.powerupQueue)
end

-- Moves the powerup sprite to the save box
function sceneLocal:movePowerupSprite()
  for key,value in pairs(scene.powerupMoveQueue) do
    if value ~= nil then
      scene.powerupMoveQueue[key] = nil
      scene.powerupMovingQueue[value.name] = value
      physics:removeNode(value)
      value.isTouchable = false
      tween:to(value,
        {
          x = scene.powerupBoxSprite.x + scene.powerupBoxSprite.w/2 - value.w/2,
          y = scene.powerupBoxSprite.y + scene.powerupBoxSprite.h/2 - value.h/2,
          alpha = 0,
          rotation = 0,
          time=1,
          onComplete=
            function(target)
              dbg.print("movePowerupSprite - tween - onComplete " .. target.name)
              scene.powerupMovingQueue[target.name] = nil
              sceneLocal:enqueueToPowerupQueue(target)
            end
        })
    end
  end
end

------------------------------------------------------------------------
-- Scene Public Members
------------------------------------------------------------------------

-- Setup the scene resources
function scene:setUp(event)
  dbg.print("playScene - scene:setUp")
  -- Game scene state
  self.notificationLabels = { }
  self.deadPixelSprites = { }
  self.livePixelSprites = { }
  self.pegPixelSprites = { }
  self.physicsUpdateSprites = { }
  self.powerupMoveQueue = { }
  self.powerupMovingQueue = { }
  self.powerupEffects = { }
  self.powerupQueue = { }
  self.gameOverFlag = false
  self.deadSpriteCounter = 0
  self.gameClockTicks = 0
  self.nextPowerupTicks = 0
  self.currentLevel = 0
  self.powerupCount = 0
  self.lives = Resources.GameData.InitialLives
  self.allowNewPowerup = false
  self.paused = false
  Resources.Scenes.End.won = false
  
  -- Attach all particles to this scene
  initializeParticles()
  
  -- Turn on the sound track
  updateSound()
  
  -- Resume the physics engine
  physics:resume()
  
  -- Hook into the update handler
  system:addEventListener("update", systemUpdateHandler)
  
  -- Hook into web view events
  system:addEventListener("webViewLoaded", adsWebViewLoadedEvent)
  
  -- Background sprite
  self.backgroundSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.BackgroundPlain})

  -- Create the exit sprite
  self.exitSprite = director:createLabel({
    x = 22,
    y = -2,
    font=Resources.Fonts.PlayWhite,
    color=color.black,
    zOrder = 1,
    text="QUIT"})
  createBackSprite(false, nil, gameOverNotify, self.exitSprite)
  
  -- Bottom sprite
  local borderRestitution = 0
  self.bottomSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.Top})
  self.bottomSprite.x = director.displayCenterX - self.bottomSprite.w/2 - 1
  self.bottomSprite.y = self.bottomSprite.y + 18
  physics:addNode(self.bottomSprite, {type="static", restitution = borderRestitution})
  
  -- Top sprite
  self.topSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.Top})
  self.topSprite.x = director.displayCenterX - self.topSprite.w/2 - 1
  self.topSprite.y = director.displayHeight - self.topSprite.h - 17
  physics:addNode(self.topSprite, {type="static", restitution = borderRestitution})
  
  -- Left side sprite
  self.leftSideSprite = director:createSprite({
    x = 24,
    y = 0,
    source = Resources.Animations.Side})
  self.leftSideSprite.y = self.topSprite.y - self.leftSideSprite.h + 2
  physics:addNode(self.leftSideSprite, {type="static", restitution = borderRestitution})
  
  -- Right side sprite
  self.rightSideSprite = director:createSprite({
    x = director.displayWidth - self.leftSideSprite.w - 26,
    y = 0,
    source = Resources.Animations.Side})
  self.rightSideSprite.y = self.topSprite.y - self.rightSideSprite.h + 2
  physics:addNode(self.rightSideSprite, {type="static", restitution = borderRestitution})
  
  -- Powerup box sprite
  self.powerupBoxSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.PowerupBox})
  self.powerupBoxSprite.x = self.rightSideSprite.x - self.powerupBoxSprite.w - 1
  self.powerupBoxSprite.y = self.topSprite.y - self.powerupBoxSprite.h - 1
  
  -- Left clear portal (animation)
  self.leftClearAnimSprite = director:createSprite({
    xAnchor = 0.5,
    yAnchor = 0.5,
    source = Resources.Animations.ClearPortal})
  self.leftClearAnimSprite.x = self.leftSideSprite.x + self.leftSideSprite.w + (self.leftClearAnimSprite.w/2)
  self.leftClearAnimSprite.y = self.bottomSprite.y + self.bottomSprite.h + (self.leftClearAnimSprite.h/2)
  tween:to(
    scene.leftClearAnimSprite,
    {
      rotation=-360,
      time=2,
      mode="repeat"
    })

  -- Left clear portal (physics)
  self.leftClearSprite = director:createSprite({
      x = self.leftSideSprite.x + self.leftSideSprite.w,
      y = self.bottomSprite.y + self.bottomSprite.h,
      alpha = 0,
      source = Resources.Animations.ClearPortal})
  self.leftClearSprite.name = "leftClear"
  function self.leftClearSprite:collision(event)
    if event.phase == "began" then
      local destroyNode
      local portalNode
      local parentScene = self:getParent()
      if event.nodeA.name == "leftClear" then
        destroyNode = event.nodeB
        portalNode = event.nodeA
      else
        destroyNode = event.nodeA
        portalNode = event.nodeB
      end
      sceneLocal:clearPixel(destroyNode, portalNode)
    end
  end
  self.leftClearSprite:addEventListener("collision", self.leftClearSprite)
  physics:addNode(self.leftClearSprite, {isSensor = true, type="static"})

  -- Right clear portal (animation)
  self.rightClearAnimSprite = director:createSprite({
    xAnchor = 0.5,
    yAnchor = 0.5,
    source = Resources.Animations.ClearPortal})
  self.rightClearAnimSprite.x = self.rightSideSprite.x - self.leftClearSprite.w + (self.rightClearAnimSprite.w/2)
  self.rightClearAnimSprite.y = self.leftClearAnimSprite.y
  tween:to(
    scene.rightClearAnimSprite,
    {
      rotation=-360,
      time=3,
      mode="repeat"
    })

  -- Right clear portal (physics)
  self.rightClearSprite = director:createSprite({
    x = self.rightSideSprite.x - self.leftClearSprite.w,
    y = self.leftClearSprite.y,
    alpha = 0,
    source = Resources.Animations.ClearPortal})
  self.rightClearSprite.name = "rightClear"
  function self.rightClearSprite:collision(event)
    if event.phase == "began" then
      local destroyNode
      local portalNode
      local parentScene = self:getParent()
      if event.nodeA.name == "rightClear" then
        destroyNode = event.nodeB
        portalNode = event.nodeA
      else
        destroyNode = event.nodeA
        portalNode = event.nodeB
      end
      sceneLocal:clearPixel(destroyNode, portalNode)
    end
  end
  self.rightClearSprite:addEventListener("collision", self.rightClearSprite)
  physics:addNode(self.rightClearSprite, {isSensor = true, type="static"})
  
--  -- Platform sprite
--  self.platformSprite = director:createSprite({
--    x = 0,
--    y = self.bottomSprite.y + self.bottomSprite.h,
--    source = Resources.Animations.Platform})
--  self.platformSprite.x = self.bottomSprite.x + self.bottomSprite.w/2 - self.platformSprite.w/2
--  self.platformSprite.tx = self.platformSprite.x
--  physics:addNode(self.platformSprite, {type="static"})
--  tween:to(self.platformSprite,
--    {
--      time=3,
--      tx=self.leftClearSprite.x,
--      onComplete=
--        function(target)
--          tween:to(target,
--            {
--              time=6,
--              tx=self.rightSideSprite.x - target.w,
--              mode="mirror",
--            })
--        end
--    })
--  self.physicsUpdateSprites[self.platformSprite.name] = self.platformSprite
  
  -- Powerup box preview sprite
  self.powerupBoxPreviewSprite = director:createSprite({
    x = 0,
    y = 0,
    alpha = 0,
    source = Resources.Animations.Powerups})
  self.powerupBoxPreviewSprite:setFrame(1)
  self.powerupBoxPreviewSprite.x = self.powerupBoxSprite.x + self.powerupBoxSprite.w/2 - self.powerupBoxPreviewSprite.w/2
  self.powerupBoxPreviewSprite.y = self.powerupBoxSprite.y - self.powerupBoxPreviewSprite.h - 2
  
  -- Powerup box label
  self.powerupBoxLabel = director:createLabel({
    hAlignment="right",
    font=Resources.Fonts.PlayWhite,
    alpha = 0,
    text="0"})
  self.powerupBoxLabel.w = self.powerupBoxLabel.wText*5
  self.powerupBoxLabel.x = self.powerupBoxSprite.x - self.powerupBoxLabel.w - 2
  self.powerupBoxLabel.y = self.powerupBoxSprite.y + self.powerupBoxSprite.h/2 - self.powerupBoxLabel.hText/2

  -- Level label
  local levelText = "LEVEL 1 OF " .. Resources.GameData.MaxLevel - 1
  self.levelLabel = director:createLabel({
    hAlignment="center",
    y=-2,
    font=Resources.Fonts.PlayWhite,
    text=levelText})
  
  -- Point label
  self.pointLabel = director:createLabel({
    hAlignment="center",
    font=Resources.Fonts.PlayWhite,
    text="SCORE: 0"})
  self.pointLabel.y = director.displayHeight - self.pointLabel.hText + 3
  
  -- Life label
  self.lifeLabel = director:createLabel({
    hAlignment="right",
    y = self.pointLabel.y,
    font=Resources.Fonts.PlayWhite,
    text="LIVES: " .. Resources.GameData.InitialLives})
  self.lifeLabel.w = self.lifeLabel.wText*2
  self.lifeLabel.x = self.rightSideSprite.x + self.rightSideSprite.w - self.lifeLabel.w + 1
  
  -- Game clock label
  self.gameClockLabel = director:createLabel({
    hAlignment="left",
    y = self.pointLabel.y,
    font=Resources.Fonts.PlayWhite,
    text="TIME: 0"})
  self.gameClockLabel.x = self.exitSprite.x
  
  -- Create the pause label
  self.pauseLabel = director:createLabel({
    hAlignment="right",
    y = -2,
    font=Resources.Fonts.PlayWhite,
    color=color.black,
    zOrder = 1,
    text="PAUSE"})
  self.pauseLabel.w = self.pauseLabel.wText*2
  self.pauseLabel.x = self.rightSideSprite.x + self.rightSideSprite.w - self.pauseLabel.w + 1
  function self.pauseLabel:blinkNotify(event)
    if event.phase == "ended" then
      local parentScene = self:getParent()
      parentScene:updatePause()
    end
  end
  initButton(self.pauseLabel, false)
  
  -- Create the monster sprite
  self.monsterSprite = director:createSprite({
    x = 0,
    y = self.bottomSprite.y + self.bottomSprite.h,
    source = Resources.Animations.Monster})
  self.monsterSprite:setFrame(Resources.Frames.Monster.Normal)
  self.monsterSprite.x = director.displayCenterX - self.monsterSprite.w/2
  self.monsterSprite.name = "monster"
  self.monsterSprite.alpha = 0
  self.monsterSprite.zOrder = 1
  self.monsterSprite.isInvincible = false
  self.monsterSprite.invincibleCount = 0
  self.monsterSprite.isHurt = false
  physics:addNode(self.monsterSprite, { restitution = 0.3})
  
  -- Monster cancel touch joint
  function self.monsterSprite:cancelTouchJoint()
    if self.touchJoint ~= nil then
      self.touchJoint = self.touchJoint:destroy()
      dbg.print("touch end - destroyed joint")
    end
    if self.touchTimer ~= nil then
      self.touchTimer = self.touchTimer:cancel()
      dbg.print("touch end - destroyed timer")
    end
  end
  
  -- Add the system touch handler for our touch joint.
  function self:touch(event)
    if event.phase == "began" then
      if self.monsterSprite.touchJoint == nil then
        if self.monsterSprite:isPointInside(event.x, event.y) == true then
          self.monsterSprite.touchJoint = physics:createTouchJoint(
            self.monsterSprite, 0.7, 5,
            self.monsterSprite.physics:getMass() * 300,
            event.x, event.y)
          self.monsterSprite.touchJoint:setTarget(event.x, event.y)
          self.monsterSprite.touchTimer = self:addTimer(monsterTouchTimerElapsed, 1, 1, 0)
        end
      end
    elseif event.phase == "moved" then
      if self.monsterSprite.touchJoint ~= nil then
        self.monsterSprite.touchJoint:setTarget(event.x, event.y)
      end
    elseif event.phase == "ended" then
      self.monsterSprite:cancelTouchJoint()
    end
  end
  system:addEventListener("touch", self)
  
  -- Hook into collision events for the monster
  -- and if we hit a pixel bomb then the game is over.
  function self.monsterSprite:collision(event)
    if event.phase == "began" then
      local parentScene = self:getParent()
      local pixelNode = event.nodeA
      if event.nodeA.name == "monster" then
        pixelNode = event.nodeB
      end
      
      -- If we are invincible then set the monster
      -- we hit as a dead monster.
      if self.isInvincible and not pixelNode.isPowerup then
        sceneLocal:clearPixel(pixelNode)
        return
      end
      
      if pixelNode.isPowerup == true and pixelNode.isPowerupGranted == false then
        dbg.print("flagging powerup sprite for move!")
        
        -- Apply the powerup function to the sprite
        pixelNode.canPause = false
        pixelNode:pause()
        local currentFrame = pixelNode:getFrame()
        if currentFrame == Resources.Frames.Powerups.Clear then
          dbg.print("applied clear powerup function.")
          pixelNode.powerUpApply =
            function (monster, pixel)
              sceneLocal:displayPowerupEffect(monster, Resources.Frames.Powerups.Clear)
              sceneLocal:clearLivePixels()
            end
        elseif currentFrame == Resources.Frames.Powerups.Invincible then
          dbg.print("applied invincible powerup function.")
          pixelNode.powerUpApply =
            function (monster, pixel)
              if monster.isInvincible == false then
                scene:updateInvincible(true)
              end
            end
        elseif currentFrame == Resources.Frames.Powerups.Energy then
          dbg.print("applied energy burst powerup function.")
          pixelNode.powerUpApply =
            function (monster, pixel)
              sceneLocal:displayPowerupEffect(monster, Resources.Frames.Powerups.Energy)
              sceneLocal:moveLivePixels(10)
              sceneLocal:stunLivePixels()
            end
        elseif currentFrame == Resources.Frames.Powerups.Sonic then
          pixelNode.powerUpApply =
            function (monster, pixel)
              sceneLocal:displayPowerupEffect(monster, Resources.Frames.Powerups.Sonic)
              sceneLocal:gravityLivePixels(10)
              sceneLocal:stunLivePixels()
            end
        end
        
        table.insert(parentScene.powerupMoveQueue, pixelNode)
        parentScene.livePixelSprites[pixelNode.name] = nil
        tearDownSpriteTweens(pixelNode)
        tearDownSpriteTimers(pixelNode)
        pixelNode.isPowerupGranted = true
      end
      
      if pixelNode.isForceBomb == true and pixelNode.isActiveForceBomb == true and parentScene.lives > 0 then
        pixelNode.isActiveForceBomb = false
        pixelNode:setFrame(Resources.Frames.ForcePixel.Stunned)
        
        local adjustedRandForce = 300
        parentScene.monsterSprite.physics:applyLinearImpulse(
          math.random(0 - adjustedRandForce, adjustedRandForce),
          math.random(0 - adjustedRandForce, adjustedRandForce))
      end
      
      if pixelNode.isHeavyBomb == true and pixelNode.isActiveHeavyBomb == true and parentScene.lives > 0 then
        pixelNode.isActiveHeavyBomb = false
        pixelNode:setFrame(Resources.Frames.HeavyPixel.Stunned)
        pixelNode.physics:setRestitution(0.65)
      end
      
      if pixelNode.isPixelBomb == true and pixelNode.isActiveBomb == true and parentScene.lives > 0 then
        pixelNode.isActiveBomb = false
        pixelNode:setFrame(Resources.Frames.PixelBomb.Stunned)
        
        if self.isInvincible == false then
          removeLife("on bomb collision.")
        end
      end
    end
  end
  self.monsterSprite:addEventListener("collision", self.monsterSprite)
  
  -- Fade in the monster and then start the game...
  tween:to(self.monsterSprite, { alpha=1, time=1 } )
  
  -- Pixel cannon sprite on top middle.
  self.pixelCannonSprite = director:createSprite({
    x = 0,
    y = 0,
    source = Resources.Animations.PixelCannonTop})
  self.pixelCannonSprite:setFrame(1)
  self.pixelCannonSprite.nextFrame = 2
  self.pixelCannonSprite.x = director.displayCenterX - self.pixelCannonSprite.w/2
  self.pixelCannonSprite.y = self.topSprite.y - self.pixelCannonSprite.h
  self.pixelCannonSprite.alpha = 0
  self.pixelCannonSprite.zOrder = 1
  tween:to(self.pixelCannonSprite, { alpha=1, time=1 })
  
  -- Set the game clock timer to start
  self:addTimer(gameClockTimerElapsed, 1, 0, 0)
  
  dbg.print("playScene - scene:setUp - complete")
end

-- Update the pause state in the game
function scene:updatePause(pause)
  if pause == nil then
    pause = not self.paused
  end
  
  if pause == true then
    if self.paused == false then
      dbg.print("pausing game")
      self.paused = true
      physics:pause()
      pauseSprite(self)
      self.pauseLabel.text = "RESUME"
      updateSound(false, true)
      resumeSprite(scene.exitSprite)
    end
  else
    if self.paused == true then
      dbg.print("resuming game")
      self.paused = false
      physics:resume()
      resumeSprite(self)
      self.pauseLabel.text = "PAUSE"
      updateSound(false, true)
    end
  end
end

-- Update the monsters invincible state
function scene:updateInvincible(invincible)
  invincible = invincible or false
  if invincible == true then
    self.monsterSprite.invincibleCount = self.monsterSprite.invincibleCount + 1
    self.monsterSprite.isInvincible = true
    if self.monsterSprite.invincibleCount == 1 then
      self.monsterSprite:setFrame(Resources.Frames.Monster.Invincible)
    end
    self.monsterSprite:addTimer(invincibleTimerElapsed, 5, 1, 0)
  else
    self.monsterSprite.invincibleCount = self.monsterSprite.invincibleCount - 1
    if self.monsterSprite.invincibleCount == 0 then
      self.monsterSprite.isInvincible = false
      self.monsterSprite:setFrame(Resources.Frames.Monster.Normal)
    end
  end
end

-- Remove the life
function scene:removeLife(message)
  removeLife(message)
end

-- Update the monsters hurt state
function scene:updateHurt(hurt)
  hurt = hurt or false
  if hurt == true then
    if self.monsterSprite.isHurt == false then
      self.monsterSprite.isHurt = true
      self.monsterSprite:setFrame(Resources.Frames.Monster.Hurt)
      self.monsterSprite:addTimer(hurtTimerElapsed, 1, 1, 0)
    end
  elseif self.monsterSprite.isHurt == true and self.monsterSprite.isInvincible == false then
    self.monsterSprite.isHurt = false
    self.monsterSprite:setFrame(Resources.Frames.Monster.Normal)
  end
end

-- Game over function
function scene:gameOver()
  -- Save this games data
  Resources.UserData.LastScore = self.deadSpriteCounter
  Resources.UserData.LastTime = self.gameClockTicks
  Resources.UserData.LastLevel = self.currentLevel
  
  -- Note that the top lives user data in resources
  -- is maintained actively during game play since
  -- this value will fluctuate... where as the time
  -- and score only ever goes up, the lives may
  -- go up and down, so we save new values as
  -- they are achieved, where for score and time
  -- we just save them at the end.
  
  -- Save the user data
  saveUserData()
  
  -- Move the end scene
  moveToGameScene(Resources.Scenes.End)
end

-- Tear down the scene resources
function scene:tearDown(event)
  dbg.print("playScene - scene:tearDown")
  
  -- Unhook from the update handler
  system:removeEventListener("update", systemUpdateHandler)
  
  -- Unhook into web view events
  system:removeEventListener("webViewLoaded", adsWebViewLoadedEvent)
  
  -- Ensure that the game is not
  -- paused when we exit
  self:updatePause(false)
  
  -- Turn off the sound track
  updateSound(true)
  
  -- Pause the physics engine
  physics:pause()
  
  -- Clear the animations
  self.animations = nil
  
  -- Cleanup all the timers on this scene
  dbg.print("playScene - scene:tearDown - scene timers")
  tearDownTimers(self.timers)
  
  -- Remove the system event lister
  system:removeEventListener("touch", self)
  
  -- Cleanup all powerups in the queue
  dbg.print("playScene - scene:tearDown - powerups")
  tearDownSprites(self.powerupQueue)
  self.powerupQueue = nil
  
  -- Cleanup all powerups effects
  dbg.print("playScene - scene:tearDown - powerup effects")
  tearDownSprites(self.powerupEffects)
  self.powerupEffects = nil
  
  -- Cleanup all powerups in the move queue
  dbg.print("playScene - scene:tearDown - powerups move")
  tearDownSprites(self.powerupMoveQueue)
  self.powerupMoveQueue = nil
  
  -- Cleanup all powerups in the moving queue
  dbg.print("playScene - scene:tearDown - powerups moving")
  tearDownSprites(self.powerupMovingQueue)
  self.powerupMovingQueue = nil
  
  -- Cleanup all the pegs
  dbg.print("playScene - scene:tearDown - pegs")
  tearDownSprites(self.pegPixelSprites)
  self.pegPixelSprites = nil
  
  -- Cleanup all the blockers
  dbg.print("playScene - scene:tearDown - blockers")
  tearDownSprites(self.physicsUpdateSprites)
  self.physicsUpdateSprites = nil
  
  dbg.print("playScene - scene:tearDown - dead explosion sprites")
  tearDownParticles()
  
  -- Cleanup all the dead sprites
  dbg.print("playScene - scene:tearDown - dead sprites")
  clearDeadPixels()
  self.deadPixelSprites = nil
  
  -- Cleanup all the live sprites
  dbg.print("playScene - scene:tearDown - live sprites")
  tearDownSprites(self.livePixelSprites)
  self.livePixelSprites = nil
  
  -- Cleanup all the notification labels
  dbg.print("playScene - scene:tearDown - notification labels")
  tearDownSprites(self.notificationLabels)
  self.notificationLabels = nil
  
  -- Cleanup all the static sprites
  dbg.print("playScene - scene:tearDown - monster sprite - " .. self.monsterSprite.name)
  if self.monsterSprite.touchTimer ~= nil then
    self.monsterSprite.touchTimer = self.monsterSprite.touchTimer:cancel()
    dbg.print("playScene - destroyed touch timer")
  end
  if self.monsterSprite.touchJoint ~= nil then
    self.monsterSprite.touchJoint = self.monsterSprite.touchJoint:destroy()
    dbg.print("playScene - destroyed touch joint")
  end
  self.monsterSprite:removeEventListener("collision", self.monsterSprite)
  self.monsterSprite = tearDownSprite(self.monsterSprite)
  
  dbg.print("playScene - scene:tearDown - bottom sprite - " .. self.bottomSprite.name)
  self.bottomSprite = tearDownSprite(self.bottomSprite)
  
  dbg.print("playScene - scene:tearDown - top sprite - " .. self.topSprite.name)
  self.topSprite = tearDownSprite(self.topSprite)
  
  dbg.print("playScene - scene:tearDown - left sprite - " .. self.leftSideSprite.name)
  self.leftSideSprite = tearDownSprite(self.leftSideSprite)
  
  dbg.print("playScene - scene:tearDown - right sprite - " .. self.rightSideSprite.name)
  self.rightSideSprite = tearDownSprite(self.rightSideSprite)
  
  dbg.print("playScene - scene:tearDown - background sprite - " .. self.backgroundSprite.name)
  self.backgroundSprite = tearDownSprite(self.backgroundSprite)
  
  dbg.print("playScene - scene:tearDown - portal sprite - " .. self.pixelCannonSprite.name)
  self.pixelCannonSprite = tearDownSprite(self.pixelCannonSprite)
  
  dbg.print("playScene - scene:tearDown - powerup box sprite - " .. self.powerupBoxSprite.name)
  self.powerupBoxSprite = tearDownSprite(self.powerupBoxSprite)
  
  dbg.print("playScene - scene:tearDown - powerup box preview sprite - " .. self.powerupBoxPreviewSprite.name)
  self.powerupBoxPreviewSprite = tearDownSprite(self.powerupBoxPreviewSprite)
  
  dbg.print("playScene - scene:tearDown - exit sprite - " .. self.exitSprite.name)
  self.exitSprite = tearDownBackSprite(self.exitSprite)
  
  dbg.print("playScene - scene:tearDown - clock label - " .. self.gameClockLabel.name)
  self.gameClockLabel = tearDownSprite(self.gameClockLabel)
  
  dbg.print("playScene - scene:tearDown - points label - " .. self.pointLabel.name)
  self.pointLabel = tearDownSprite(self.pointLabel)
  
  dbg.print("playScene - scene:tearDown - life label - " .. self.lifeLabel.name)
  self.lifeLabel = tearDownSprite(self.lifeLabel)
  
  dbg.print("playScene - scene:tearDown - pause label - " .. self.pauseLabel.name)
  self.pauseLabel = tearDownSprite(self.pauseLabel)
  
  dbg.print("playScene - scene:tearDown - level label - " .. self.levelLabel.name)
  self.levelLabel.blinkTween = nil
  self.levelLabel = tearDownSprite(self.levelLabel)
  
  dbg.print("playScene - scene:tearDown - right clear sprite - " .. self.rightClearSprite.name)
  self.rightClearSprite = tearDownSprite(self.rightClearSprite)
  self.rightClearAnimSprite = tearDownSprite(self.rightClearAnimSprite)
  
  dbg.print("playScene - scene:tearDown - left clear sprite - " .. self.leftClearSprite.name)
  self.leftClearSprite = tearDownSprite(self.leftClearSprite)
  self.leftClearAnimSprite = tearDownSprite(self.leftClearAnimSprite)
  
  dbg.print("playScene - scene:tearDown - powerup label - " .. self.powerupBoxLabel.name)
  self.powerupBoxLabel = tearDownSprite(self.powerupBoxLabel)
  
  dbg.print("playScene - scene:tearDown - release resources")
  self:releaseResources()
  dbg.print("playScene - scene:tearDown - complete")
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
