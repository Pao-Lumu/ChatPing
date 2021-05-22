Hooks:PostHook(
    ChatManager,
    "_receive_message",
    "ChatPingOnReceivedMessage",
    function(self, channel_id, name, message)
        if ChatPing and ChatPing.settings.enable then
            if string.match(string.sub(message, 1, 4), "GN.P") == nil then
                managers.menu_component:post_event(ChatPing.settings.sound)
            end
        end
    end
)
