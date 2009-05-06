delegateClass = {
	--generic to all instances
	signatures =
	{
		"void collidedWith:mphandle atXYZ:double:double:double";
	}
}
function delegateClass:newDelegateWithObject(obj)
	instance = setmetatable(
	{
		--specific to all instances
		object=obj;
	}, {__index = delegateClass} )
	return instance
end

tramplineImpulse = 10

function delegateClass:collidedWithatXYZ(objh, x, y, z)
	obj = MPObjectByHandle(objh)
	local sx = obj:getX() - x
	local sy = obj:getY() - y
	local length = math.sqrt(sx*sx + sy*sy)
	sx = sx / length
	sy = sy / length
	local alpha = math.acos(-sx)
	if sy>0 then
		alpha = 2*math.pi - alpha
	end
	if alpha > 2*math.pi then
		alpha = alpha - 2*math.pi
	end
	-- tambourine
	alpha = alpha-math.pi 
	if alpha < 0 then
		alpha = alpha + 2*math.pi
	end

	local cornerInterval = 0.3
	local tramplineAngle = 0
	
	local function between(a, b)
		return (alpha >= a) and (alpha <= b)
	end

	if between(math.pi/4 - cornerInterval, math.pi/4 + cornerInterval) then
		tramplineAngle = math.pi/4 -- /^
	elseif between(math.pi/4 + cornerInterval, 3*math.pi/4 - cornerInterval) then
		tramplineAngle = math.pi/2 -- |^
	elseif between(3*math.pi/4 - cornerInterval, 3*math.pi/4 + cornerInterval) then
		tramplineAngle = 3*math.pi/4 -- ^\
	elseif between(3*math.pi/4 + cornerInterval, 5*math.pi/4 - cornerInterval) then
		tramplineAngle = math.pi -- <-
	elseif between(5*math.pi/4 - cornerInterval, 5*math.pi/4 + cornerInterval) then
		tramplineAngle = 5*math.pi/4 -- </
	elseif between(5*math.pi/4 + cornerInterval, 7*math.pi/4 - cornerInterval) then
		tramplineAngle = 3*math.pi/2 -- v|
	elseif between(7*math.pi/4 - cornerInterval, 7*math.pi/4 + cornerInterval) then
		tramplineAngle = 7*math.pi/4 -- \>
	elseif between(7*math.pi/4 + cornerInterval, 2*math.pi) or between(0, math.pi/4-cornerInterval) then
		tramplineAngle = 0 -- ->
	end

	obj:applyImpulseWithXYZ_relativePosWithXYZ(
								tramplineImpulse*math.cos(tramplineAngle),
								tramplineImpulse*math.sin(tramplineAngle),
								0,
								0,
								0,
								0)
end

function init()
	MPMethodAliasTable["applyImpulseWithXYZ_relativePosWithXYZ"]	= "applyImpulseWithXYZ:::relativePosWithXYZ:::"

	MPRegisterDelegateClassForFeature(delegateClass, "trampline")
end

