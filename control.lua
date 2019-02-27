function define_quick_craft (pre, num, count_fn)
    script.on_event(pre .. num, function(event)
        player = game.players[event.player_index]
        local page = player.get_active_quick_bar_page(1)
        if page == nil then
            return
        end

        local slot = player.get_quick_bar_slot(num + 10 * page)
        if slot ~= null and slot.valid then
            try_craft(player, slot, count_fn)
        end
    end)
end

for i=1,10 do
    define_quick_craft("quick-craft-", i, function() return 1 end)
    define_quick_craft("quick-craft-many-", i, function (player)
        return settings.get_player_settings(player)["quick-craft-many-count"].value
    end)
end

function find_recipe(player, item_prototype)
    local name = item_prototype.name
    local first = nil
    for _, recipe in pairs(player.force.recipes) do
        if not recipe.hidden then
            for _, prod in pairs(recipe.products) do
                if prod.name == name and player.get_craftable_count(recipe) > 0 then
                    return recipe  
                end
                if prod.name == name and first == nil then
                    first = recipe
                    break
                end
            end
        end
    end
    return first
end

function try_craft (player, item_prototype, count_fn)
    local recipe = find_recipe(player, item_prototype)
    if recipe ~= nil and player.valid then
        player.begin_crafting({
            count = count_fn(player),
            recipe = recipe,
            silent = false
        })
    end
end