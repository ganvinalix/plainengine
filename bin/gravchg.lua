X=0;
Y=0;
k=2.0;

function MPMessageHandlers.mouseButton(args)
	if args.button == "3" then
		if args.state == "down" then
			X = args.X;
			Y = args.Y;
		elseif args.state == "up" then
			X = args.X - X;
			Y = args.Y - Y;
			X = X*k;
			Y = Y*k;
			MPPostMessage("setGravity", {X=X, Y=Y});
		end
	end
end
