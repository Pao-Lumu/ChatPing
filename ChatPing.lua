if not _G.ChatPing then
    _G.ChatPing = {}
    ChatPing.mod_path = ModPath
    ChatPing.save_path = SavePath
    ChatPing.settings_path = ChatPing.save_path .. "ChatPing.json"
    ChatPing.languages = {}

    ChatPing.settings = {
        enable = true,
        lang = "en",
        sound = "zoom_out"
    }

    function ChatPing:Load()
        local file = io.open(ChatPing.settings_path, "r")
        if file then
            local data = json.decode(file:read("*all")) or {}
            file:close()
            for k, v in pairs(data) do
                self.settings[k] = v
            end
        end
    end
    function ChatPing:Save()
        local file = io.open(ChatPing.settings_path, "w+")
        if file then
            file:write(json.encode(self.settings))
            file:close()
        end
    end

    ChatPing:Load()

    Hooks:Add(
        "LocalizationManagerPostInit",
        "LocalizationManagerPostInitChatPing",
        function(loc)
            loc:load_localization_file(string.format("%s/%s.json", ChatPing.mod_path .. "loc/", ChatPing.settings.lang))
        end
    )

    local chat_ping_menu_id = "chat_ping_menu"
    Hooks:Add(
        "MenuManagerSetupCustomMenus",
        "MenuManagerSetupCustomMenusChatPing",
        function(menu_manager, nodes)
            MenuHelper:NewMenu(chat_ping_menu_id)
        end
    )

    Hooks:Add(
        "MenuManagerPopulateCustomMenus",
        "MenuManagerPopulateCustomMenusChatPing",
        function(menu_manager, nodes)
            MenuCallbackHandler.ChatPing_enable = function(self, item)
                ChatPing.settings.enable = item:value()
                ChatPing:Save()
            end

            MenuCallbackHandler.ChatPing_lang = function(self, item)
                ChatPing.settings.lang = item:value()
                ChatPing:Save()
            end

            MenuCallbackHandler.ChatPing_sound = function(self, item)
                ChatPing.settings.sound = item:value()
                ChatPing:Save()
                managers.menu_component:post_event(ChatPing.settings.sound)
            end

            local function BetterMultipleChoice(multi_data) -- Copy the entirety of MenuHelper:AddMultipleChoice() to here and swapping `ipairs` for `pairs` to allow for strings to be returned by multiple choice
                local data = {
                    type = "MenuItemMultiChoice"
                }

                for k, v in pairs(multi_data.items or {}) do
                    table.insert(data, {_meta = "option", text_id = v, value = k})
                end

                local params = {
                    name = multi_data.id,
                    text_id = multi_data.title,
                    help_id = multi_data.desc,
                    callback = multi_data.callback,
                    filter = true,
                    localize = multi_data.localized
                }

                local menu = MenuHelper:GetMenu(multi_data.menu_id) -- change `self` to `MenuHelper` because we're no longer in the right scope
                local item = menu:create_item(data, params)
                item._priority = multi_data.priority
                item:set_value(multi_data.value or 1)

                if multi_data.disabled then
                    item:set_enabled(not multi_data.disabled)
                end

                menu._items_list = menu._items_list or {}
                table.insert(menu._items_list, item)
            end

            MenuHelper:AddToggle(
                {
                    id = "chat_ping_enable",
                    title = "chat_ping_enable_title",
                    description = "chat_ping_enable_desc",
                    callback = "ChatPing_enable",
                    value = ChatPing.settings.enable,
                    menu_id = chat_ping_menu_id
                }
            )
            BetterMultipleChoice(
                {
                    id = "chat_ping_lang",
                    title = "chat_ping_lang_title",
                    description = "chat_ping_lang_desc",
                    callback = "ChatPing_lang",
                    value = ChatPing.settings.lang,
                    items = {
                        ["en"] = "chat_ping_lang_en",
                        ["de"] = "chat_ping_lang_de"
                    },
                    menu_id = chat_ping_menu_id
                }
            )
            BetterMultipleChoice(
                {
                    id = "chat_ping_sound",
                    title = "chat_ping_switcher_title",
                    description = "chat_ping_switcher_desc",
                    callback = "ChatPing_sound",
                    value = ChatPing.settings.sound,
                    items = {
                        ["zoom_in"] = "chat_ping_zoom_in_desc",
                        ["zoom_out"] = "chat_ping_zoom_out_desc",
                        ["menu_error"] = "chat_ping_menu_error_desc",
                        ["menu_exit"] = "chat_ping_menu_exit_desc",
                        ["menu_enter"] = "chat_ping_menu_enter_desc",
                        ["finalize_mask"] = "chat_ping_finalize_mask_desc",
                        ["menu_skill_investment"] = "chat_ping_menu_skill_investment_desc"
                    },
                    menu_id = chat_ping_menu_id
                }
            )
        end
    )
    Hooks:Add(
        "MenuManagerBuildCustomMenus",
        "MenuManagerBuildCustomMenusPlayerChatPing",
        function(menu_manager, nodes)
            nodes[chat_ping_menu_id] = MenuHelper:BuildMenu(chat_ping_menu_id, {})
            MenuHelper:AddMenuItem(
                nodes["blt_options"],
                chat_ping_menu_id,
                "chat_ping_menu_title",
                "chat_ping_menu_desc"
            )
        end
    )
end
