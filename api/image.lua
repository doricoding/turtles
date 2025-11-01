FILE_SIGNATURE = "BLIT";

-- Helper function
local function fillRow(image, from, to, y, color)
	y = math.round(y);
	if y < 1 or y > image.height then
		return;
	end

	from = math.max(math.round(from), 1);
	to = math.min(math.round(to), image.width);

	for x = from, to do
		image._data[y][x] = color;
	end
end

-- color_formats = {
-- 	blit = 1,
-- 	rgb = 2
-- }

-- Create a new empty image object
local function createImageInstance()
	local image = {
		width = 0,
		height = 0,
		-- color_format = 0,
		_data = {}
	};

	-- Save image to file
	function image:save(file_path)
		local file = fs.open(file_path, "wb");
		-- File signature
		file.write(FILE_SIGNATURE);
		-- Width
		file.write(bit.band(bit.brshift(image.width, 8), 0xFF));
		file.write(bit.band(image.width, 0xFF));
		-- Height
		file.write(bit.band(bit.brshift(image.height, 8), 0xFF));
		file.write(bit.band(image.height, 0xFF));

		local flags = {
			contains_transparency = false;
			-- custom_palette = false; -- (TODO)
		};

		-- Palette (TODO)

		-- Split image data to sections
		local alphas = {};
		local pixels = {};
		for i = 0, image.width*image.height - 1 do
			local x, y = i%image.width + 1, math.floor(i/image.width) + 1;

			alphas[i+1] = image._data[y][x] ~= nil;
			if alphas[i+1] then
				pixels[#pixels+1] = math.floor(math.log(image._data[y][x], 2));
			else
				flags.contains_transparency = true;
			end
		end

		-- Write flags
		local flag_byte = 0;
		local flag_index = 0;
		for _, flag in pairs(flags) do
			if flag then
				flag_byte = bit.bor(flag_byte, bit.blshift(1, flag_index));
			end
			flag_index = flag_index + 1;
		end
		file.write(flag_byte);
		-- Write alpha section
		if flags.contains_transparency then
			for i = 1, image.width*image.height, 8 do
				local byte = 0;
				for j = 0, 7 do
					if alphas[i+j] then
						byte = bit.bor(byte, bit.blshift(1, j));
					end
				end
				file.write(byte);
			end
		end
		-- Write pixel section
		for i = 1, #pixels, 2 do
			local byte = pixels[i];
			if pixels[i+1] then
				byte = bit.bor(byte, bit.blshift(pixels[i+1], 4));
			end
			file.write(byte);
		end

		file.close();
	end
	-- Clone an image
	function image:clone()
		local new_image = createImageInstance();
		new_image.width = self.width;
		new_image.height = self.height;
		new_image.color_format = self.color_format;
		-- Deep copy data
		for y = 1, self.height do
			new_image._data[y] = {};
			for x = 1, self.width do
				new_image._data[y][x] = self._data[y][x];
			end
		end

		return new_image;
	end
	-- Resize image (todo)

	-- -- Convert color format (todo)
	-- function image:toBlitFormat(color_palette)
	-- 	if self.color_format == color_formats.rgb then

	-- 	end
	-- end
	-- Draw
	function image:pixel(x, y, color)
		x, y = math.round(x), math.round(y);
		if x < 1 or y < 1 or x > self.width or y > self.height then
			return;
		end

		self._data[y][x] = color;
	end
	function image:line(x1, y1, x2, y2, color)
		local dx = x2 - x1;
		local dy = y2 - y1;

		local step = math.max(math.abs(dx), math.abs(dy));
		if step == 0 then
			self:pixel(x1, y1, color);
			return;
		end

		local step_x = dx / step;
		local step_y = dy / step;
		for i = 0, step do
			self:pixel(x1 + i*step_x, y1 + i*step_y, color);
		end
	end
	function image:rectangle(x1, y1, x2, y2, color, fill)
		 fill = fill or true;

		-- Switch sides
		if x1 > x2 then
			x1, x2 = x2, x1;
		end
		if y1 > y2 then
			y1, y2 = y2, y1;
		end
		-- Clamp start positions
		x1 = math.max(math.round(x1), 1);
		y1 = math.max(math.round(y1), 1);
		-- Return early if possition is out of bounds
		if x1 > self.width or y1 > self.height then
			return;
		end
		-- Clamp end positions
		x2 = math.min(math.round(x2), self.width);
		y2 = math.min(math.round(y2), self.height);

		for y = y1, y2 do
			if fill or y == y1 or y == y2 then
				for x = x1, x2 do
					self._data[y][x] = color;
				end
			else
				self._data[y][x1] = color;
				self._data[y][x2] = color;
			end
		end
	end
	function image:circle(cx, cy, r, color, fill)
		if fill == nil then
			fill = false;
		end
		if r <= 0 then
			return;
		end

		local x = 0;
		local y = -r;
		local p = -r;

		local extra_loops = 0;
		if fill then
			extra_loops = 2;
		end

		while x - extra_loops < -y do
			if p > 0 then
				if fill then
					x = x - 1;
					fillRow(self, cx - x, cx + x, cy + y, color);
					fillRow(self, cx - x, cx + x, cy - y, color);
					x = x + 1;
				end

				y = y + 1;
				p = p + 2*(x+y) + 1;
			else
				p = p + 2*x + 1;
			end

			if fill then
				fillRow(image, cx + y, cx - y, cy + x, color);
				fillRow(image, cx + y, cx - y, cy - x, color);
			else
				self:pixel(cx + x, cy + y, color);
				self:pixel(cx - x, cy + y, color);
				self:pixel(cx + x, cy - y, color);
				self:pixel(cx - x, cy - y, color);
				self:pixel(cx + y, cy + x, color);
				self:pixel(cx + y, cy - x, color);
				self:pixel(cx - y, cy + x, color);
				self:pixel(cx - y, cy - x, color);
			end

			x = x + 1;
		end
	end
	function image:drawImage(image, x, y, dx, dy, sx, sy)
		x, y = math.round(x), math.round(y);
		dx, dy = math.floor(dx), math.floor(dy);
		assert(dx >= 1, "Draw image delta x can't be nagative!");
		assert(dy >= 1, "Draw image delta y can't be nagative!");
		if x > self.width or y > self.height or x+dx < 1 or y+dy < 1 then
			return;
		end
		-- Start position
		if sx ~= nil then
			sx = math.round(sx);
			assert(sx >= 1, "Draw image starting x offset can't be negative!");
		else
			sx = 1;
		end
		if sy ~= nil then
			sy = math.round(sy);
			assert(sx >= 1, "Draw image starting y offset can't be negative!");
		else
			sy = 1;
		end

		local x_start = math.max(-(x-1), 0);
		local y_start = math.max(-(y-1), 0);
		for i = y_start, math.min(image.height-sy, dy-1, self.height-y) do
			for j = x_start, math.min(image.width-sx, dx-1, self.width-x) do
				local color = image._data[sy+i][sx+j];
				if color ~= nil then
					self._data[y+i][x+j] = color;
				end
			end
		end
	end

	return image;
end

-- Create a new image object
function create(width, height, bg_color)
	-- assert(color_format >= 1 and color_format <= #color_formats, "Image color format out of range!");

	width = math.floor(width);
	height = math.floor(height);
	assert(width >= 1, "Image width can't be smaller then 1!");
	assert(height >= 1, "Image height can't be smaller then 1!");

	local image = createImageInstance();
	image.width = width;
	image.height = height;
	-- image.color_format = color_format;
	-- -- `blit_color_palette` is only present when the format is set to blit
	-- if color_format == color_formats.blit then
	-- 	assert(type(blit_color_palette) == "table", "Image blit_color_palette is missing or the wrong type!");
	-- 	image.blit_color_palette = blit_color_palette;
	-- end

	-- Fill image with color
	for y = 1, height do
		image._data[y] = {};
		if bg_color ~= nil then
			for x = 1, width do
				image._data[y][x] = bg_color;
			end
		end
	end

	return image;
end
function load(file_path)
	local file = fs.open(file_path, "rb");
	-- Check file signature
	if file.read(#FILE_SIGNATURE) ~= FILE_SIGNATURE then
		file.close();
		error("File signature doesn't match!", 2);
	end

	local image = createImageInstance();

	-- Get size
	local width = file.read(2);
	image.width = bit.bor(bit.blshift(width:byte(1), 8), width:byte(2));
	local height = file.read(2);
	image.height = bit.bor(bit.blshift(height:byte(1), 8), height:byte(2));
	-- Get flags
	local flag_byte = file.read(1):byte(1);
	local flags = {
		contains_transparency = bit.band(flag_byte, 1) > 0;
	}

	-- Construct image
	local alphas;
	if flags.contains_transparency then
		alphas = file.read(math.ceil(image.width*image.height / 8));
	end
	local pixels = file.readAll();
	file.close()

	local pixel_index = 0;
	for y = 1, image.height do
		image._data[y] = {};
		for x = 1, image.width do
			if flags.contains_transparency then
				local alpha_index = x + (y-1)*image.width - 1;
				local alpha_byte = alphas:byte(math.floor(alpha_index/8) + 1);
				if bit.band(alpha_byte, 2 ^ (alpha_index%8)) == 0 then
					goto skip_pixel;
				end
			end
			local pixel_byte = pixels:byte(math.floor(pixel_index/2) + 1);
			image._data[y][x] = 2 ^ bit.band(bit.brshift(pixel_byte, (pixel_index%2) * 4), 0xF);
			pixel_index = pixel_index + 1;
			::skip_pixel::
		end
	end

	return image;
end
