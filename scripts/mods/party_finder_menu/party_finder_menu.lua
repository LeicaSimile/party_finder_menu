-- Author: LeicaSimile

local mod = get_mod("party_finder_menu")
local menu_path = "scripts/ui/views/system_view/system_view_content_list"
local menu = require(menu_path)
local PresenceSettings = require("scripts/settings/presence/presence_settings")
local orig_state_main_menu = menu.StateMainMenu

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

mod:hook_require(menu_path, function(instance)
    mod.on_enabled = function(initial_call)
        local group_finder_text = "loc_group_finder_menu_title"

        -- Don't add party finder if it already exists in the menu
        if table.find_by_key(instance.StateMainMenu, "text", group_finder_text) then
            return
        end

        local new_item = {}
        for _, item in ipairs(instance.default) do
            -- Copy the party finder menu option from the game hub
            if item.text == group_finder_text then
                for k, v in pairs(item) do
                    new_item[k] = v
                end
                new_item.validation_function = nil
                break
            end
        end

        local new_menu = {}
        for _, item in ipairs(orig_state_main_menu) do
            if item.text == "loc_store_view_display_name" then
                table.insert(new_menu, new_item)
            end
            table.insert(new_menu, item)
        end
        instance.StateMainMenu = new_menu
    end

    mod.on_disabled = function(initial_call)
        instance.StateMainMenu = orig_state_main_menu
    end
end)

-- Ensure that joining a party while viewing party finder at character select doesn't result in an empty screen
mod:hook("UIViewHandler", "close_all_views", function(func, self, force_close, optional_excepted_views)
    local has_group_finder = false
    local has_main_menu = false
    local active_views = self._active_views_array
    for i=1, #active_views do
        local view = active_views[i]
        if view == "group_finder_view" then
            has_group_finder = true
        elseif starts_with(view, "main_menu") then
            has_main_menu = true
        end
    end
    if has_group_finder and has_main_menu then
        if optional_excepted_views == nil then
            optional_excepted_views = Script.new_array(2)
        end
        table.insert(optional_excepted_views, "main_menu_view")
        table.insert(optional_excepted_views, "main_menu_background_view")
        mod:notify(mod:localize("join_notification"))
    end

    func(self, force_close, optional_excepted_views)
end)

-- Send join request notifications at character select
local cur_num_join_requests = 0
mod:hook_safe("PartyImmateriumManager", "_handle_advertisement_request_to_join_list_update_event_trigger", function(self, event)
    local join_requests, _ = self:advertisement_request_to_join_list()
    local num_join_requests = table.size(join_requests)
    local current_state = PresenceSettings.evaluate_presence(Managers.presence._current_game_state_name)
    if current_state == "main_menu" and num_join_requests > cur_num_join_requests then
        mod:notify(mod:localize("join_request_notification"))
    end
	cur_num_join_requests = num_join_requests
end)
