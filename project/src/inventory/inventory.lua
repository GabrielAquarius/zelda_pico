-- ============================================================
-- inventory.lua
-- Gerenciador do menu de inventário (2 páginas) e equipamentos
-- ============================================================

layout = {
	a_slot        = {x=6,   y=1,   w=28, h=14},
	b_slot        = {x=43,  y=1,   w=28, h=14},
	rupee         = {x=72,  y=8},
	hearts_top    = {x=96,  y=1,   gap=8},
	hearts_bottom = {x=96,  y=9,   gap=8},
	grid          = {x=4,   y=24,  cols=4, rows=4, gap_x=30, gap_y=21},
	arrow_slot    = {x=96,  y=110, w=28, h=14}
}

GRID_SLOTS = 16
ARROW_NODE = 17

instrument_order = split("moon_cello,conch_horn,lilly_bell,surf_harp,wind_marimba,coral_triangle,calm_organ,thunder_drum")

-- Posições circulares dos 8 instrumentos na Página 2 (ordem horária 1..8)
instrument_slots = {
	{x=31, y=28}, {x=43, y=48}, {x=43, y=68}, {x=31, y=88},
	{x=13, y=88}, {x=1,  y=68}, {x=1,  y=48}, {x=13, y=28}
}

key_order = split("tail_key,angler_key,face_key,bird_key,slime_key")

trading_order = split("yoshi_doll,ribbon,dog_food,bananas,honeycomb,stick,pineapple,necklace,magnifying_lens,broom,goat_letter,hibiscus,mermaid_scale,fishing_hook,pink_bra")

state = {}
nodes = {}
cur = 1
inv_timer = 0

function inventory_init()
	init_state()
	build_nodes()
end

function init_state()
	state.page = 1
	state.equipped_a = nil
	state.equipped_b = nil
	state.hearts = {}
	state.grid = {}
	state.instruments = {}

	local current_hp = p_stats and p_stats.hp or 3
	for i=1,8 do
		state.hearts[i] = (i <= current_hp)
		state.instruments[i] = false
	end

	state.grid[1] = "bow"
	state.grid[2] = "bomb"
	state.grid[3] = "feather"

	-- itens coletáveis da Página 2 habilitados para visualização/teste
	non_equippable.flippers.equipped = true
	non_equippable.secret_medicine.equipped = true
	non_equippable.secret_seashell.equipped = true
	non_equippable.golden_leaf.picked = true
	non_equippable.heart_piece.picked = true
	trading_sequence.yoshi_doll.picked = true
	for k in all(key_order) do keys[k].equipped = true end

	if inv and inv.sword == 1 then add_item_to_inventory("sword") end
	if inv and inv.shield == 1 then add_item_to_inventory("shield") end

	pick_up.rupee.qty = p_stats and p_stats.rupees or 0
	sync_equipment_state()
end

function has_item_in_inventory(item_name)
	if state.equipped_a == item_name or state.equipped_b == item_name then
		return true
	end
	for i=1,GRID_SLOTS do
		if state.grid[i] == item_name then return true end
	end
	return false
end

function add_item_to_inventory(item_name)
	if has_item_in_inventory(item_name) then return end
	for i=1,GRID_SLOTS do
		if state.grid[i] == nil then
			state.grid[i] = item_name
			break
		end
	end
	sync_equipment_state()
end

function sync_equipment_state()
	for name, item in pairs(equipament) do
		item.equipped = (state.equipped_a == name or state.equipped_b == name)
	end
	if inv then
		inv.sword = has_item_in_inventory("sword") and 1 or 0
		inv.shield = has_item_in_inventory("shield") and 1 or 0
	end
end

function sync_hearts_from_stats()
	if not p_stats then return end
	for i=1,8 do state.hearts[i] = (i <= p_stats.hp) end
end

-- ---------- GRAFO DE NAVEGAÇÃO (PÁGINA 1: GRID + SETA) ----------
function build_nodes()
	nodes = {}
	local g = layout.grid
	local bw, bh = brackets_selector.sw, brackets_selector.sh

	for i=1,GRID_SLOTS do
		local col = (i-1) % g.cols
		local row = flr((i-1) / g.cols)
		add(nodes, {
			kind="grid",
			x=g.x + col*g.gap_x, y=g.y + row*g.gap_y, w=bw, h=bh,
			up=(row > 0) and (i - g.cols) or nil,
			down=(row < g.rows - 1) and (i + g.cols) or ARROW_NODE,
			left=(col > 0) and (i - 1) or nil,
			right=(col < g.cols - 1) and (i + 1) or nil
		})
	end

	nodes[GRID_SLOTS].right = ARROW_NODE

	local a = layout.arrow_slot
	add(nodes, {
		kind="arrow", x=a.x, y=a.y, w=a.w, h=a.h,
		up=GRID_SLOTS, left=GRID_SLOTS - 1
	})
end

-- ---------- UPDATE ----------
function update_inventory()
	inv_timer += 1

	if p_stats then
		pick_up.rupee.qty = p_stats.rupees
		sync_hearts_from_stats()
	end

	if state.page == 1 then
		local n = nodes[cur]

		if btnp(2) and n.up    then cur = n.up;    inv_timer = 0 end
		if btnp(3) and n.down  then cur = n.down;  inv_timer = 0 end
		if btnp(0) and n.left  then cur = n.left;  inv_timer = 0 end
		if btnp(1) and n.right then cur = n.right; inv_timer = 0 end

		if btnp(4) or btnp(5) then
			if n.kind == "arrow" then
				state.page = 2
				inv_timer = 0
			elseif btnp(4) then
				state.equipped_a, state.grid[cur] = state.grid[cur], state.equipped_a
				sync_equipment_state()
			else
				state.equipped_b, state.grid[cur] = state.grid[cur], state.equipped_b
				sync_equipment_state()
			end
		end
	elseif btnp(4) or btnp(5) then
		state.page = 1
		inv_timer = 0
	end
end

-- ---------- DRAW ----------
function draw_inventory()
	camera(0, 0)
	cls(7)

	spr(128, 0, 0, 16, 2)
	draw_separators()
	draw_slot(layout.a_slot, state.equipped_a)
	draw_slot(layout.b_slot, state.equipped_b)
	draw_rupee_counter(pick_up.rupee.qty, layout.rupee.x, layout.rupee.y)
	draw_hearts()

	if state.page == 1 then
		for i=1,GRID_SLOTS do
			draw_slot(nodes[i], state.grid[i])
		end
		draw_page_arrow(false)
		draw_cursor(nodes[cur])
	else
		draw_page2_collectibles()
		draw_page_arrow(true)
		draw_cursor(layout.arrow_slot)
	end
end

function draw_separators()
	local sh = separator.hor
	for x=0,127,sh.sw+1 do
		sspr(sh.sx, sh.sy, sh.sw, sh.sh, x, 18)
	end
	if state.page == 2 then
		local sv = separator.ver
		for y=22,120,sv.sh+1 do
			sspr(sv.sx, sv.sy, sv.sw, sv.sh, 60, y)
		end
	end
end

function draw_item_sprite(item, x, y)
	local s = item.spr
	sspr(s.sx, s.sy, s.sw, s.sh, x, y)
end

function draw_slot(slot, item_name)
	local item = item_name and equipament[item_name]
	if item then
		draw_item_sprite(
			item,
			slot.x + flr((slot.w - item.spr.sw) / 2),
			slot.y + flr((slot.h - item.spr.sh) / 2)
		)
	end
end

function draw_rupee_counter(qty, x, y)
	qty = mid(0, qty, 999)
	rectfill(x+1, y+1, x+22, y+6, 7)
	spr(numbers[flr(qty/100)+1],      x,    y)
	spr(numbers[flr((qty%100)/10)+1], x+8,  y)
	spr(numbers[(qty%10)+1],          x+16, y)
end

function draw_hearts()
	for i=1,4 do
		if state.hearts[i] then
			draw_item_sprite(pick_up.recovery_heart, layout.hearts_top.x + (i-1)*8, layout.hearts_top.y)
		end
		if state.hearts[i+4] then
			draw_item_sprite(pick_up.recovery_heart, layout.hearts_bottom.x + (i-1)*8, layout.hearts_bottom.y)
		end
	end
end

function draw_page_arrow(flip_h)
	local slot = layout.arrow_slot
	local ax = slot.x + flr((slot.w - page_arrow.sw) / 2)
	local ay = slot.y + flr((slot.h - page_arrow.sh) / 2)
	sspr(page_arrow.sx, page_arrow.sy, page_arrow.sw, page_arrow.sh, ax, ay, page_arrow.sw, page_arrow.sh, flip_h, false)
end

function draw_page2_collectibles()
	for i=1,8 do
		local pos = instrument_slots[i]
		local inst_id = instruments[instrument_order[i]]
		if state.instruments[i] and inst_id then
			spr(inst_id, pos.x - 4, pos.y - 4, 2, 2)
		else
			spr(instruments.empty_slot, pos.x, pos.y, 2, 2)
			print(i, pos.x + 2, pos.y + 2, 7)
		end
	end

	if non_equippable.flippers.equipped then draw_item_sprite(non_equippable.flippers, 66, 24) end
	if non_equippable.secret_medicine.equipped then draw_item_sprite(non_equippable.secret_medicine, 80, 24) end
	if non_equippable.secret_seashell.equipped then draw_item_sprite(non_equippable.secret_seashell, 66, 44) end
	if non_equippable.golden_leaf.picked then draw_item_sprite(non_equippable.golden_leaf, 80, 44) end
	if non_equippable.heart_piece.picked then draw_item_sprite(non_equippable.heart_piece, 66, 86) end

	for tname in all(trading_order) do
		local titem = trading_sequence[tname]
		if titem and titem.picked then
			draw_item_sprite(titem, 66, 64)
			break
		end
	end

	for i,kname in ipairs(key_order) do
		local kitem = keys[kname]
		if kitem and kitem.equipped then
			local kx = (i == 5) and 106 or (100 + ((i-1)%2)*12)
			local ky = 24 + flr((i-1)/2)*20
			draw_item_sprite(kitem, kx, ky)
		end
	end
end

function draw_cursor(target)
	if (inv_timer % 30) < 22 then
		sspr(brackets_selector.sx, brackets_selector.sy, brackets_selector.sw, brackets_selector.sh, target.x, target.y)
	end
end
