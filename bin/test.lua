function dropBox(name, x, y)
	local boxObj = MPCreateObject(name)
	boxObj.mass = 1
	boxObj.restitution = 0.1
	boxObj.friction = 0.7

	boxObj:setFeature("renderable", "",
		{
			textureName="metal.jpg",
			scaleX=2.1,
			scaleY=2.1,
		})
	boxObj:setFeature("physical", 1,
		{
			shapeType="box",
			XShape=2.1,
			YShape=2.1,
			ZShape=0.1
		})
	boxObj:setXY(x, y)

	return boxObj
end

function dropBubble(name, x, y)
	local bubbleObj = MPCreateObject(name)
	bubbleObj.mass = 0.55
	bubbleObj.restitution = 0.6
	bubbleObj.friction = 0.9
	bubbleObj:setFeature("physical", 1,
		{
			shapeType="sphere",
			radius=1
		})
	bubbleObj:setFeature("renderable", "",
		{
			textureName="bubble.png",
			scaleX=1,
			scaleY=1,
		})
	bubbleObj:setXY(x, y)
	return bubbleObj
end

uniqueCounter=0
function dropNew(x, y)
	local newName=string.format("_%u_", uniqueCounter)
	dropBubble(newName, x, y)
	uniqueCounter=uniqueCounter+1 
end

function init()
	MPMethodAliasTable["setXY"] = "setXY::"
	MPMethodAliasTable["setScaleXY"] = "setScaleXY::"
end

function start()
	local function putborder(name, x, y)
		local function getNormal(w)
			if w == 0 then
				return 0
			else
				return -w/math.abs(w)
			end
		end
		local border = MPCreateObject(name)
		border:setFeature("physical", 1,
			{
				shapeType="plane",
				XNormal=getNormal(x),
				YNormal=getNormal(y)
			})
		border:setXY(x, y)
		border.restitution = 0.0
		border.friction = 1.0
		border.quietcollisions = 1
	end


	putborder("upborder",		0,		9)
	putborder("downborder",		0,		-9)
	putborder("rightborder",	12,		0)
	putborder("leftborder",		-12,	0)

	back  = MPCreateObject("back")
	back:setFeature("renderable", "",
		{
			textureName="stars.jpg",
			scaleX=17,
			scaleY=10,
			textureAnimator="ConstantMovement|fps:0.2"
		})

	floor = MPCreateObject("floor")
	floor:setFeature("renderable", "",
		{
			textureName="floor.png",
			scaleX=20,
			scaleY=1,
			textureAnimator="ConstantMovement|fps:0.9"
		})
	floor:setFeature("physical", 1,
		{
			shapeType="box",
			XShape=20,
			YShape=1,
			ZShape=0.1
		})
	floor:setXY(0.0, -10.0)
	floor.friction = 0.5
	floor.restitution = 0.6
	floor.quietcollisions = 1
	
	ceil = MPCreateObject("ceil")
	ceil:setFeature("renderable", "",
		{
			textureName="floor.png",
			scaleX=20,
			scaleY=1,
			textureAnimator="ConstantMovement|fps:0.9"
		})
	ceil:setFeature("physical", 1,
		{
			shapeType="box",
			XShape=20,
			YShape=1,
			ZShape=0.1
		})
	ceil:setXY(0.0, 10.0)
	ceil.friction = 0.5
	ceil.restitution = 0.1
	ceil.quietcollisions = 1

	wall = MPCreateObject("wall")
	wall:setFeature("renderable", "",
		{
			textureName="floor.png",
			scaleY=20.0,
			scaleX=1.0,
			textureAnimator="ConstantMovement|fps:1.9"
		})
	wall:setFeature("physical", 1,
		{
			shapeType="box",
			XShape=1.0,
			YShape=20.0,
			ZShape=0.1
		})
	wall:setXY(-13.0, 0.0)
	wall.friction = 0.5
	wall.restitution = 0.5
	wall.quietcollisions = 1

	wall2 = MPCreateObject("wall2")
	wall2:setFeature("renderable", "",
		{
			textureName="floor.png",
			scaleY=20.0,
			scaleX=1.0,
			textureAnimator="ConstantMovement|fps:1.9"
		})
	wall2:setFeature("physical", 1,
		{
			shapeType="box",
			XShape=1.0,
			YShape=20,
			ZShape=0.1
		})
	wall2:setXY(13.0, 0.0)
	wall2.friction = 0.5
	wall2.restitution = 0.5
	wall2.quietcollisions = 1

	cur = MPCreateObject("cur")
	cur.mouse = 1
	cur.restitution = 0.1
	cur.quietcollisions = 1
	cur:setFeature("renderable", "",
		{
			textureName="./bubble.png",
			scaleX=0.5,
			scaleY=0.5,
		})
	cur:setFeature("physical", 1,
		{
			shapeType="sphere",
			radius=0.5
		})

	ctrl = dropBubble("ctrl", 0, 0)
	ctrl.controllable = 1
	tr = dropBox("tr", 0, 0)
	tr.mass = 0
	tr.trampline = 1
	tr.obs = 1

	camera = MPCreateObject("camera")
	camera.camera = 1
	camera:setScaleXY(0.1, 0.1)
end

function MPMessageHandlers.keyDown(args)
	if args.keyCode == "27" then
		MPPostMessage("exit")
	elseif args.keyName == "d" then
		dropNew(0, 4)
	end
end

function MPMessageHandlers.mouseButton(args)
	if (args.button == "1") and (args.state == "down") then
		MPPostMessage("explosion",
			{
				X=args.X,
				Y=args.Y,
				radius=10.0,
				impulseCoefficient=40
				--maximalImpulse=25
			})
	end
end

