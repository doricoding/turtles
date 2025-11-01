-- Wrap terget
function wrapTarget(target)
	target.name = "";

	target._button_next = 0
	target._buttons = {};
	function target:createButton(x1, y1, x2, y2, callback)
		assert(type(callback) == "function", "Callback has to be a function!");

		-- Switch sides
		if x1 > x2 then
			x1, x2 = x2, x1;
		end
		if y1 > y2 then
			y1, y2 = y2, y1;
		end
		-- Clamp positions
		x1 = math.max(math.round(x1), 1);
		y1 = math.max(math.round(y1), 1);
		x2, y2 = math.round(x2), math.round(y2);

		self._button_next = self._button_next + 1;
		self._buttons[self._button_next] = {
			x1 = x1, y1 = y1,
			x2 = x2, y2 = y2,
			callback = callback
		};

		return self._button_next;
	end
	function target:deleteButton(index)
		assert(type(index) == "number", "Index has to be a number!");
		self._buttons[index] = nil;
	end

	-- Initiate a canvas for display
	function target:initCanvas(bg_color, compact)
		assert(bg_color ~= nil, "Canvas background color can't be transparent!")
		target.setBackgroundColor(bg_color);
		target.clear();
		-- Convert inputed value into a boolean
		compact = compact == true;

		local screen_width, screen_height = target.getSize();
		local width, height = screen_width, screen_height;
		if compact then
			width, height = width * 2, height * 3;
		end

		target.canvas = image.create(width, height, bg_color);
		target.canvas.compact = compact;

		-- Redraw a region of the canvas (uses screen position)
		function target.canvas:redraw(sx1, sy1, sx2, sy2)
			sx1, sy1 = sx1 or 1, sy1 or 1;
			sx2, sy2 = sx2 or screen_width, sy2 or screen_height;
			-- Switch sides
			if sx1 > sx2 then
				sx1, sx2 = sx2, sx1;
			end
			if sy1 > sy2 then
				sy1, sy2 = sy2, sy1;
			end
			-- Clamp positions
			sx1 = math.max(math.round(sx1), 1);
			sy1 = math.max(math.round(sy1), 1);
			sx2 = math.max(math.round(sx2), screen_width);
			sy2 = math.max(math.round(sy2), screen_height);

			if compact then
				error("TODO: compact pixels display mode");
			else
				for y = sy1, sy2 do
					target.setCursorPos(1, y);
					for x = sx1, sx2 do
						local color = target.canvas._data[y][x];
						target.setBackgroundColor(color);
						target.write(" ");
					end
				end
			end
		end
	end

	-- Handle display events
	function target:handle_event()
		---@diagnostic disable-next-line: undefined-field
		local event, name, x, y = os.pullEvent();

		-- Skip irrelevant events 
		if event ~= "monitor_touch" and event ~= "mouse_click" then
			return;
		end
		-- Skip if the event occurred on a different monitor
		if target.name ~= "" and target.name ~= name then
			return;
		end

		for button_id, button in pairs(self._buttons) do
			---@diagnostic disable-next-line: undefined-field
			if button.x1 <= x and button.y1 <= y and button.x2 >= x and button.y2 >= y then
				---@diagnostic disable-next-line: undefined-field
				button.callback(self, button_id, x - button.x1 + 1, y - button.y1 + 1);
			end
		end
	end

	return target;
end
-- Wrap terget monitor/window
function wrapByName(name)
	local target = peripheral.wrap(name);
	local target = wrapTarget(target);
	target.name = name;
	return target;
end

-- Get palette form target
function getColorPaletteFromTarget(target)
	local palette = {};

	for i = 1, 16 do
		local r, g, b = target.getPaletteColor(i);
		palette[i] = {r, g, b};
	end

	return palette;
end
-- Get palette form target by name
function getColorPaletteFromName(name)
	local palette = {};

	for i = 1, 16 do
		local r, g, b = peripheral.call(name, "getPaletteColor", i);
		palette[i] = {r, g, b};
	end

	return palette;
end
