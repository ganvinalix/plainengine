function init()
	prevtime = MPGetMilliseconds();

	MPMethodAliasTable["applyImpulseWithXYZ_relativePosWithXYZ"]	= "applyImpulseWithXYZ:::relativePosWithXYZ:::"
	MPMethodAliasTable["setLinearVelocityWithXYZ"] 					= "setLinearVelocityWithXYZ:::"
end

function update()
	newtime = MPGetMilliseconds()
	dt = newtime-prevtime
	prevtime = newtime

	local curobj = MPObjects.ctrl
	if curobj and curobj:hasFeature("controllable") and curobj:hasFeature("physical") then
		dt = dt*accel
		local x = curobj:getLinearVelocityX()
		local y = curobj:getLinearVelocityY()
		local changed=false
		if keyLeft then
			x = x - dt
			changed = true
		end
		if keyRight then
			x = x + dt
			changed = true
		end
		if changed then
			curobj:setLinearVelocityWithXYZ(x, y, 0)
		end
	end
end

keyLeft = false
keyRight = false

accel = 0.01
vaccel = 0.5
jumpImpulse = 1.8


function MPMessageHandlers.keyUp(args)
	if args.keyName == "left" then
		keyLeft = false
	elseif args.keyName == "right" then
		keyRight = false
	end
end

function MPMessageHandlers.keyDown(args)
	if args.keyName == "left" then
		keyLeft = true
	elseif args.keyName == "right" then
		keyRight = true
	elseif args.keyName == "up" then
		ctrl = MPObjects.ctrl
		if ctrl then
			ctrl:applyImpulseWithXYZ_relativePosWithXYZ(0, vaccel, 0, 0, 0, 0)
		end
	elseif args.keyName == "down" then
		ctrl = MPObjects.ctrl
		if ctrl then
			ctrl:applyImpulseWithXYZ_relativePosWithXYZ(0, -vaccel, 0, 0, 0, 0)
		end
	elseif args.keyName == "space" then
		ctrl = MPObjects.ctrl
		if ctrl then
			ctrl:applyImpulseWithXYZ_relativePosWithXYZ(0, jumpImpulse, 0, 0, -ctrl:getRadius(), 0)
		end
	end
end

