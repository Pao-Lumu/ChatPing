Hooks:PostHook(
    ChatManager,
    "_receive_message",
    "ChatPingOnReceivedMessage",
    function(self, channel_id, name, message)
        if ChatPing and ChatPing.settings.enable then
            if string.match(string.sub(message, 1, 4), "GN.P") == nil then
                if string.sub(ChatPing.settings.sound, 1, 5) == "ping_" then
                    local volume = managers.user:get_setting("sfx_volume")
                    local percentage =
                        (volume - tweak_data.menu.MIN_SFX_VOLUME) /
                        (tweak_data.menu.MAX_SFX_VOLUME - tweak_data.menu.MIN_SFX_VOLUME)
                    managers.menu_component._main_panel:video(
                        {
                            name = "chatping_" .. ChatPing.settings.sound,
                            video = ChatPing.settings.sound,
                            visible = false,
                            loop = false
                        }
                    ):set_volume_gain(percentage)
                else
                    managers.menu_component:post_event(ChatPing.settings.sound)
                end
            end
        end
    end
)
