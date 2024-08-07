function AddMessage(chatHistory, senderID, chat)
    table.insert(chatHistory, {senderID = senderID, chat = chat})
end
