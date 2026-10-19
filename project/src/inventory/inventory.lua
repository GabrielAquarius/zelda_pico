-- ============================================================
-- inventory.lua
-- Tela de inventário isolada (prototype standalone)
--
-- Depende das tabelas definidas em items_coordianates.lua
-- (numbers, pick_up, equipament) — carregue esse arquivo como
-- outra tab no mesmo cartridge, ou via #include se for separar
-- em arquivos de verdade.
-- ============================================================

-- ---------- CONFIG / POSIÇÕES NA TELA ----------
-- ⚠️ Estes são valores de exemplo. Ajuste para bater com a arte
-- real do spr(128,0,0,60,2) quando você desenhar o layout final.
layout = {
	a_slot   = {x=8,   y=6},
	a_item   = {x=20,  y=6},
	b_slot   = {x=40,  y=6},
	b_item   = {x=52,  y=6},
	rupee    = {x=104, y=8},           -- início dos 3 dígitos
	hearts_top    = {x=8, y=28, gap=16},
	hearts_bottom = {x=8, y=40, gap=16},
	grid     = {x=8, y=64, cols=4, gap_x=18, gap_y=18}
}

digit_names = {
	"zero","one","two","three","four",
	"five","six","seven","eight","nine"
}

-- ordem fixa dos itens equipáveis (tabelas lua não têm ordem
-- garantida, então listamos manualmente)
item_order = {
	"sword","shield","bow","hookshot","shovel","bomb",
	"boomerang","magic_rod","ocarina","magic_powder",
	"pegasus_boots","bracelet","feather"
}

-- ---------- ESTADO ----------
state = {}
nodes = {}
cur = 1 -- índice do node selecionado atualmente

function _init()
	palt(0,false)
	palt(14,true)

	init_state()
	build_nodes()
end

function init_state()
	state.equipped_a = nil
	state.equipped_b = nil

	state.hearts = {}
	for i=1,8 do state.hearts[i] = true end

	-- itens de exemplo "possuídos", só pra ter algo pra navegar/testar
	state.owned = {
		sword   = true,
		shield  = true,
		bow     = true,
		bomb    = true,
		feather = true
	}

	-- quantidade de exemplo pro contador de rupees
	pick_up.rupee.qty = 42
end

-- ---------- GRAFO DE NAVEGAÇÃO ----------
-- Cada elemento navegável (slot A, slot B, cada coração, cada
-- item da grade) vira um "node" com posição na tela. Depois
-- ligamos os nodes entre si por proximidade (up/down/left/right),
-- então btnp() simplesmente segue o link na direção pressionada.
-- Isso evita ter que escrever casos especiais pra cada seção da
-- tela na hora de navegar.

function build_nodes()
	nodes = {}

	add_node("a_slot", layout.a_slot.x, layout.a_slot.y)
	add_node("b_slot", layout.b_slot.x, layout.b_slot.y)

	for i=1,4 do
		add_node("heart", layout.hearts_top.x + (i-1)*layout.hearts_top.gap,
			layout.hearts_top.y, i)
	end
	for i=1,4 do
		add_node("heart", layout.hearts_bottom.x + (i-1)*layout.hearts_bottom.gap,
			layout.hearts_bottom.y, i+4)
	end

	for i,name in ipairs(item_order) do
		local col = (i-1) % layout.grid.cols
		local row = flr((i-1) / layout.grid.cols)
		local x = layout.grid.x + col*layout.grid.gap_x
		local y = layout.grid.y + row*layout.grid.gap_y
		add_node("item", x, y, name)
	end

	link_nodes()
end

function add_node(kind, x, y, data)
	add(nodes, {kind=kind, x=x, y=y, data=data, up=nil, down=nil, left=nil, right=nil})
end

-- liga cada node ao vizinho mais próximo em cada direção
function link_nodes()
	for i,n in ipairs(nodes) do
		local best = {up=nil, down=nil, left=nil, right=nil}
		local bestd = {up=32767, down=32767, left=32767, right=32767}

		for j,m in ipairs(nodes) do
			if i ~= j then
				local dx = m.x - n.x
				local dy = m.y - n.y
				local d = dx*dx + dy*dy

				if dy < 0 and abs(dx) <= abs(dy) + 8 and d < bestd.up then
					bestd.up = d; best.up = j
				end
				if dy > 0 and abs(dx) <= abs(dy) + 8 and d < bestd.down then
					bestd.down = d; best.down = j
				end
				if dx < 0 and abs(dy) <= abs(dx) + 8 and d < bestd.left then
					bestd.left = d; best.left = j
				end
				if dx > 0 and abs(dy) <= abs(dx) + 8 and d < bestd.right then
					bestd.right = d; best.right = j
				end
			end
		end

		n.up, n.down, n.left, n.right = best.up, best.down, best.left, best.right
	end
end

-- ---------- UPDATE ----------
function _update()
	local n = nodes[cur]

	if btnp(2) and n.up    then cur = n.up end
	if btnp(3) and n.down  then cur = n.down end
	if btnp(0) and n.left  then cur = n.left end
	if btnp(1) and n.right then cur = n.right end

	if btnp(4) then confirm() end -- 🅾️ / z
	if btnp(5) then cancel()  end -- ❎ / x
end

-- 🅾️ : equipa o item selecionado no slot A / cura o coração
function confirm()
	local n = nodes[cur]
	if n.kind == "item" and state.owned[n.data] then
		state.equipped_a = n.data
	elseif n.kind == "heart" then
		state.hearts[n.data] = true
	end
end

-- ❎ : equipa o item selecionado no slot B / desequipa slot / perde coração
function cancel()
	local n = nodes[cur]
	if n.kind == "item" and state.owned[n.data] then
		state.equipped_b = n.data
	elseif n.kind == "a_slot" then
		state.equipped_a = nil
	elseif n.kind == "b_slot" then
		state.equipped_b = nil
	elseif n.kind == "heart" then
		state.hearts[n.data] = false
	end
end

-- ---------- DRAW ----------
function _draw()
	cls(0)
	spr(128, 0, 0, 60, 2) -- Hub layout

	draw_slot(layout.a_slot, state.equipped_a)
	draw_slot(layout.b_slot, state.equipped_b)

	draw_rupee_counter(pick_up.rupee.qty, layout.rupee.x, layout.rupee.y)

	draw_hearts()
	draw_item_grid()
	draw_cursor()
end

function draw_item_sprite(item, x, y)
	sspr(item.spr.sx, item.spr.sy, item.spr.sw, item.spr.sh, x, y)
end

function draw_slot(pos, item_name)
	if item_name then
		draw_item_sprite(equipament[item_name], pos.x, pos.y)
	end
end

function draw_rupee_counter(qty, x, y)
	qty = mid(0, qty, 999)
	local hundreds = flr(qty/100)
	local tens = flr((qty%100)/10)
	local ones = qty%10

	spr(numbers[digit_names[hundreds+1]], x,    y)
	spr(numbers[digit_names[tens+1]],     x+8,  y)
	spr(numbers[digit_names[ones+1]],     x+16, y)
end

function draw_hearts()
	for i=1,4 do
		draw_heart(i, layout.hearts_top.x + (i-1)*layout.hearts_top.gap, layout.hearts_top.y)
	end
	for i=1,4 do
		draw_heart(i+4, layout.hearts_bottom.x + (i-1)*layout.hearts_bottom.gap, layout.hearts_bottom.y)
	end
end

function draw_heart(i, x, y)
	if state.hearts[i] then
		draw_item_sprite(pick_up.recovery_heart, x, y)
	else
		-- ⚠️ não existe sprite de coração vazio em items_coordianates.lua
		-- ainda; por enquanto desenhamos um contorno como placeholder
		rect(x, y, x+6, y+6, 5)
	end
end

function draw_item_grid()
	for i,name in ipairs(item_order) do
		if state.owned[name] then
			local col = (i-1) % layout.grid.cols
			local row = flr((i-1) / layout.grid.cols)
			local x = layout.grid.x + col*layout.grid.gap_x
			local y = layout.grid.y + row*layout.grid.gap_y
			draw_item_sprite(equipament[name], x, y)
		end
	end
end

function draw_cursor()
	local n = nodes[cur]
	rect(n.x-2, n.y-2, n.x+9, n.y+17, 7)
end