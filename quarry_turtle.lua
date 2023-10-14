--	Minecraft Mining Turtle Ore Quarry v3 by nrszero                                           
--		
--	Instructions:
--		- To start place chest on the right side of turtle on the same level 
--			and put fuel in turtle inventory. Then change, if needed, the depth and width
--			and to_bedrock variable in script and run it.
--		- To continue quarry if stopped bring turtle back to starting position
--			by chest and run script.
--		- If turtle runs out of fuel or has full inventory it will go back to start
--			and prompt for fuel or empty inventory. Then continue mining.
--		- If you want turtle to go to bedrock set the to_bedrock variable to true,
--			if not set it to false.
--                
--	Change Log:
--		- 2/16/2021: v2 Inventory check is quicker now.
--		- 2/16/2021: v3 Turtle will return to chest when inventory is full.
--		- 2/16/2021: v3.1 Inputing odd number width will work now.
--		- 2/23/2021: v3.2 Added Blacklist and going to Bedrock ability.
--		- 3/3/2021: v3.3 Won't go off course if mob or player touch it.
--		- 3/3/2021: v3.4 Changed paths of turtles to avoid collision that throw it off track.
--	To Do:
--		- Test turning off item on blacklist.
--		- Make miner detect and avoid other miners.
-- 		- How to deploy and return multiple turtles.
--		- set label if none set then place from inventory and run immediatly.
-- 		- Figure out better way than moving turtle to dodge when going down from refuel.
--			Still collide if on same level and ones going to refuel and ones not. 
-- pastebin get gNA3Zisz quarry.lua
--	CHANGEABLE VARIABLES
depth = 16
width = 84
to_bedrock = false
found_up_dig_up = false

--  Blacklist Key 0: Won't Touch
--  Blacklist Key 1: Will Drop
--	Blacklist Key 2: Turn off Blacklist for item
blacklist = {
	["computercraft:turtle_advanced"]=0,
	["computercraft:turtle_expanded"]=0,
	["minecraft:stone"]=1,
	["minecraft:dirt"]=2,
	["traverse:red_rock"]=1
}

--	NON-CHANGEABLE VARIABLES
--	x is left/right, y is up/down, z is forward/backward
x = 0
y = 0
z = 0

curr_dir_z = 1
curr_dir_x = 0

if(os.getComputerLabel() == "Turty_2_Q")
then
	print("Label is already set")
else
	os.setComputerLabel("Turty_2_Q")
	print("Label is set now")
end

function check_inv_full()
	check_var = 0
	for p=1,14,1
	do  
		if(turtle.getItemCount(p) == 0)
		then
			return false
		else
			check_var = 1
		end 
	end
	
	if(check_var)
	then
		print("Inventory Full")
		prev_x = x
		prev_y = y
		prev_z = z
		
		-- Make when going up and x and z = 0 first go left then up then back left to chest
		if(prev_y > 0)then move_up(prev_y) end
		if(prev_z > 0)then dig_backward(prev_z) end
		if(prev_x > 0)then dig_right(prev_x) end
		empty_inv()
		
		print("Going Back to Mine")	

		if(prev_z > 0)then dig_forward(prev_z)else dig_forward(1) end
		if(prev_x > 0)then dig_left(prev_x)else dig_left(1) end	
		if(prev_z == 0)then dig_backward(1) end
		if(prev_x == 0)then dig_right(1) end
		if(prev_y > 0)then dig_down(prev_y) end
		
	end	
end

function empty_inv()
	print("Emptying Inventory")
	face_right()
	for s=1,16,1
	do
		turtle.select(s)
		turtle.drop()
	end
end

function check_fuel()
	if(turtle.getFuelLevel() < 500)
	then
		print("Fuel Level:", turtle.getFuelLevel())
		print("Fuel Low. Going Back to Start")
		prev_x = x
		prev_y = y
		prev_z = z
		
		if(prev_y > 0)then move_up(prev_y) end
		if(prev_z > 0)then dig_backward(prev_z) end
		if(prev_x > 0)then dig_right(prev_x) end
		face_forward()
	
		print("Refuel to 500 or Greater")
		print("Place Fuel in Slot 16")
		
		while(turtle.getFuelLevel() < 500)
		do
			turtle.select(16)
			if(turtle.refuel())
			then
				print("Fuel Level:", turtle.getFuelLevel())
			end
		end
		
		print("Going Back to Mine")
		if(prev_z > 0)then dig_forward(prev_z)else dig_forward(1) end
		if(prev_x > 0)then dig_left(prev_x)else dig_left(1) end	
		if(prev_z == 0)then dig_backward(1) end
		if(prev_x == 0)then dig_right(1) end
		if(prev_y > 0)then dig_down(prev_y) end
	else
		turtle.select(16)
		if(turtle.refuel())
		then
			print("Fuel Level:", turtle.getFuelLevel())
		end
		turtle.select(1)
	end
end

function whole_num(num)
	return math.ceil(num)
end

function dig_down(num)
	print("Digging Down:", num)
	turtle.select(1)
	for d=1,num,1
	do
		success_down, data_down = turtle.inspectDown()
		if not(blacklist[data_down.name] == 0)
		then
			turtle.digDown()
		end
		
		while not(turtle.down()) 
		do
			sleep(1)
		end
		
		y = y + 1
	end
	return success
end 

function dig_up(num)
	print("Digging Up:", num)
	for u=1,num,1
	do	
		turtle.digUp()
		while not(turtle.up()) 
		do
			sleep(1)
		end
		
		y = y - 1
	end
	return success
	-- print("y equals ", y)
end

function move_up(num)
	print("Moving Up:", num)
	for u=1,num,1
	do
		while not(turtle.up()) 
		do
			sleep(1)
		end
		
		y = y - 1
	end
	return success
	-- print("y equals ", y)
end

function dig(num)
	for f=1,num,1
	do
		success_up, data_up = turtle.inspectUp()
		if(success_up)
		then
			if not(blacklist[data_up.name] == 0)
			then
				print("Block Above:", data_up.name)
				if(found_up_dig_up)then dig_up(1) end
			else
				print("Blacklisted Block Above:", data_up.name)
			end
		end
		
		if(curr_dir_z == 1)then z = z + 1 end
		if(curr_dir_z == -1)then z = z - 1 end
		if(curr_dir_x == 1)then x = x + 1 end
		if(curr_dir_x == -1)then x = x - 1 end
		
		success, data = turtle.inspect()
		if(success)
		then
			-- print("Block:", data.name)
			if not(blacklist[data.name] == 0 or blacklist[data.name] == 1)
			then
				turtle.select(1)
				turtle.dig()
				while not(turtle.forward())
				do
					success, data = turtle.inspect()
					if(data.name == "minecraft:gravel")then turtle.dig()else sleep(1) end
					if(data.name == "minecraft:sand")then turtle.dig()else sleep(1) end
				end
			else
				-- Turtle waits if detects block ahead in blacklist, key 0
				if(blacklist[data.name] == 0)
				then
					while(blacklist[data.name] == 0)
					do
						sleep(1)
						success, data = turtle.inspect()
					end
					turtle.select(1)
					turtle.dig()
					while not(turtle.forward())
					do
						success, data = turtle.inspect()
						if(data.name == "minecraft:gravel")then turtle.dig()else sleep(1) end
						if(data.name == "minecraft:sand")then turtle.dig()else sleep(1) end
					end
				end
				
				-- Drops Items that are in blacklist, key 1
				if(blacklist[data.name] == 1)
				then
					turtle.select(15)
					turtle.dig()
					while not(turtle.forward())
					do
						success, data = turtle.inspect()
						if(data.name == "minecraft:gravel")then turtle.dig()else sleep(1) end
						if(data.name == "minecraft:sand")then turtle.dig()else sleep(1) end
					end
					turtle.drop()
				end
			end
		else
			while not(turtle.forward())do end
		end

	end
end

function turn_left(num)
	for f=1,num,1
	do
		turtle.turnLeft()
	end
end

function turn_right(num)
	for f=1,num,1
	do
		turtle.turnRight()
	end
end

function face_forward()
	if(curr_dir_z == 1)then end
	if(curr_dir_z == -1)then
		turn_left(2)
		curr_dir_z = 1
	end
	if(curr_dir_x == 1)then
		turn_right(1)
		curr_dir_x = 0
		curr_dir_z = 1
	end
	if(curr_dir_x == -1)then
		turn_left(1)
		curr_dir_x = 0
		curr_dir_z = 1
	end
	-- print("Current Direction:", "X:", curr_dir_x, "Z:", curr_dir_z)
end

function face_backward()
	if(curr_dir_z == -1)then end
	if(curr_dir_z == 1)then
		turn_right(2)
		curr_dir_z = -1
	end
	if(curr_dir_x == 1)then
		turn_left(1)
		curr_dir_x = 0
		curr_dir_z = -1
	end
	if(curr_dir_x == -1)then
		turn_right(1)
		curr_dir_x = 0
		curr_dir_z = -1
	end
	-- print("Current Direction:", "X:", curr_dir_x, "Z:", curr_dir_z)
end

function face_left()
	if(curr_dir_x == 1)then end
	if(curr_dir_x == -1)then
		turn_left(2)
		curr_dir_x = 1
	end
	if(curr_dir_z == 1)then
		turn_left(1)
		curr_dir_z = 0
		curr_dir_x = 1
	end
	if(curr_dir_z == -1)then
		turn_right(1)
		curr_dir_z = 0
		curr_dir_x = 1
	end
	-- print("Current Direction:", "X:", curr_dir_x, "Z:", curr_dir_z)
end

function face_right()
	if(curr_dir_x == -1)then end
	if(curr_dir_x == 1)then
		turn_right(2)
		curr_dir_x = -1
	end
	if(curr_dir_z == 1)then
		turn_right(1)
		curr_dir_z = 0
		curr_dir_x = -1
	end
	if(curr_dir_z == -1)then
		turn_left(1)
		curr_dir_z = 0
		curr_dir_x = -1
	end
	-- print("Current Direction:", "X:", curr_dir_x, "Z:", curr_dir_z)
end

function dig_forward(num)
	print("Digging Forward:", num)
	face_forward()
	dig(num)
end

function dig_backward(num)
	print("Digging Backward:", num)
	face_backward()
	dig(num)
end

function dig_left(num)
	print("Digging Left:", num)
	face_left()
	dig(num)
end

function dig_right(num)
	print("Digging Right:", num)
	face_right()
	dig(num)
end

-- Start of Action
print("Fuel Level:", turtle.getFuelLevel())
print("Target Depth:", depth)

width_minus_1 = whole_num(width - 1)
run_width = whole_num(width)
print("Target Width:", run_width)

if(to_bedrock)
then
	print("Finding Bedrock Depth")
	
	check_fuel()
	check_inv_full()
	
	face_forward()
	while(to_bedrock)
	do
		if not(dig_down(1))
		then
			print("Hit Bedrock!")
			depth = y - 5
			to_bedrock = false
		end
	end
	move_up(depth + 5)
end

-- Main Loop
while(y <= depth)
do 
	print("Depth:", y)

	check_fuel()
	check_inv_full()
	face_forward()
	
	if(y >= 0)
	then
		if(y < depth)
		then
			success, data = turtle.inspect()
			while not(success)
			do
				dig_down(1)
				if(y == depth)then break end
				
				success, data = turtle.inspect()
				-- print("Block:", data.name)
			end
			while(success and blacklist[data.name] == 0)
			do
				dig_down(1)
				if(y == depth)then break end
				
				success, data = turtle.inspect()
				-- print("Block:", data.name)
			end
			print("Turtle Depth:", y)
		end
	end
	
	for i=1,whole_num(run_width/2),1
	do	
		-- Digs forward if at backward edge and not at left edge
		if(z == 0)
		then
			if(run_width % 2 == 1 and x == width_minus_1)
			then
				dig_forward(width_minus_1)
			end
			
			if not(x == width_minus_1)
			then
				dig_forward(width_minus_1)
			end
		end
		
		-- Digs left if not at right edge and digs right once at ending left edge.
		if(x < width_minus_1)
		then
			dig_left(1)
		else
			dig_right(width_minus_1)
			print("Fuel Level:", turtle.getFuelLevel())
		end
		
		check_fuel()
		check_inv_full()
		
		-- Digs backwards if at forward edge
		if(z == width_minus_1)
		then
			dig_backward(width_minus_1)
		end
		
		-- Digs left if not at right edge and digs right once at ending left edge.
		if(x < width_minus_1)
		then
			-- Won't dig left if already has dug to the right edge.
			if not(x == 0)
			then
				dig_left(1)
			end
		else
			-- Will move up and return to start if reached depth and left edge.
			if(y == depth)
			then
				print("Reached Target Depth:", depth)
				move_up(depth)
				dig_right(width_minus_1)
				empty_inv()
				face_forward()
				return       
			end
			-- Will move right and continue mining.
			dig_right(width_minus_1)
			print("Fuel Level:", turtle.getFuelLevel())
		end
		
		check_fuel()
		check_inv_full()
	end
end