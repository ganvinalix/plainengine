evilBubbleDelegate = {
	--generic to all instances
	signatures =
	{
		"void collidedWith:mphandle atXYZ:double:double:double";
	}
}
function evilBubbleDelegate:newDelegateWithObject(obj)
	instance = setmetatable(
	{
		--specific to all instances
		object = obj;
		isRed = false;
	}, {__index = evilBubbleDelegate} )
	return instance
end

function evilBubbleDelegate:collidedWithatXYZ(objh, x, y, z)
	--if not self.isRed then
		local red = "";
		if self.isRed then 
			red = "_red"
		end

		self.object:setFeature("renderable", "",
			{
				textureName="bubble"..red..".png",
				scaleX=1,
				scaleY=1,
			})
		self.isRed = not self.isRed;
	--end
end

function init()
	MPRegisterDelegateClassForFeature(evilBubbleDelegate, "evil_bubble")
end

