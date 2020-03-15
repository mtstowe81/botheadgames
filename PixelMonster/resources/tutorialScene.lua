-- Create our scene
local scene = director:createScene()
scene.nextScene = Resources.Scenes.Main

-- Video events table
local videoEvents = {}
function videoEvents:video(event)
  dbg.print("video " .. event.phase)
  if event.phase == "ended" then
    moveToGameScene(scene.nextScene)
  end
end

-- Touch events table
local touchEvents = {}
function touchEvents:touch(event)
  dbg.print("touch " .. event.phase)
  if event.phase == "began" then
    if video:isVideoPlaying() then
      video:stopVideo()
    end
    moveToGameScene(scene.nextScene)
  end
end

-- Setup resources
function scene:setUp(event)
  dbg.print("tutorialScene - scene:setUp")
  
  -- Make sure we have a scene
  if scene.nextScene == nil then
    scene.nextScene = scene
  end
  
  -- Show the tutorial onces then disable
  -- it from then on.
  if Resources.UserData.ShowTutorial then
    Resources.UserData.ShowTutorial = false
    saveUserData()
  end
  
  -- Touch events
  system:addEventListener("touch", touchEvents)
  
  -- Play video
  system:addEventListener("video", videoEvents)
  if not video:playVideo(Resources.Videos.Tutorial, 1, 0, 0) then
    dbg.print("video failed")
    moveToGameScene(scene.nextScene)
  end
  dbg.print("tutorialScene - scene:setUp - complete")
end

-- Create the tear down scene event that
-- we will use to cleanup our scenese resources
function scene:tearDown(event)
  dbg.print("tutorialScene - scene:tearDown")
  
  scene.nextScene = nil
  system:removeEventListener("touch", touchEvents)
  system:removeEventListener("video", videoEvents)
  self:releaseResources()
  
  dbg.print("tutorialScene - scene:tearDown - complete")
end

-- Add setup and teardown event handlers
scene:addEventListener({"setUp", "tearDown"}, scene)

-- Return the scene we created
return scene
