//
//  DutyBot.swift
//  DutyBot
//
//  Created by Artem Novichkov on 17.07.16.
//  Copyright © 2016 Artem Novichkov. All rights reserved.
//

import Foundation
import SlackKit

let botName = "dutybot"

class DutyBot: MessageEventsDelegate {
    
    var dutyList = Dictionary<String, Array<String>>()
    var client: Client
    
    enum Duty: String {
        case Week = "кто дежурный"
        case Schedule = "расписание"
        case Instruction = "инструкция"
    }
    
    init(token: String) {
        client = Client(apiToken: token)
        client.messageEventsDelegate = self
        loadStubData()
    }
    
    private func loadStubData() {
        dutyList["15.07"] = ["@vladimir.savchenko", "@konstantin.sedanov"]
        dutyList["29.07"] = ["@anton.kovalev", "@evgenia.bratolubova"]
        dutyList["12.08"] = ["@victor.bezrodin", "@evgeniy.nagibin"]
        dutyList["26.08"] = ["@anastasiya.kazakova", "@artem.novichkov"]
        dutyList["09.09"] = ["@dima.kashchenko", "@dmitry_rabetsky"]
        dutyList["23.09"] = ["@nikita.ermolenko", "@dmitry.frishbuter"]
    }
    
    // MARK: - MessageEventsDelegate
    
    func messageSent(message: Message) {}
    
    func messageReceived(message: Message) {
        listen(message)
    }
    
    func messageChanged(message: Message) {}
    func messageDeleted(message: Message?) {}
    
    // MARK: - Actions
    
    private func listen(message: Message) {
        if let id = client.authenticatedUser?.id, text = message.text {
            if text.containsString(id) {
                sendMessageIfNeeded(message)
            }
        }
    }
    
    func sendMessageIfNeeded(message: Message) {
        if let text = message.text, channelID = message.channel {
            if text.containsString(Duty.Week.rawValue) {
                sendWeekDuty(channelID)
            } else if (text.containsString(Duty.Schedule.rawValue)) {
                sendSchedule(channelID)
            } else if (text.containsString(Duty.Instruction.rawValue)) {
                sendInstruction(channelID)
            }
        }
    }
    
    private func sendWeekDuty(channelID: String) {
        if let text = dutyString("29.07") {
            sendText(text, attachment: nil, channelID: channelID)
        }
    }
    
    private func sendSchedule(channelID: String) {
        var fullText = ""
        for dateKey in dutyList.keys {
            fullText += dutyString(dateKey)! + "\n"
        }
        sendText(fullText, attachment: nil, channelID: channelID)
    }
    
    private func sendMeDutySchedule(userID: String, channelID: String) {
        for (dateKey, users) in dutyList {
            let user = client.users[userID]!
            if users.contains(user.name!) {
                let text = "Вы дежурите \(dateKey)"
                sendText(text, attachment: nil, channelID: channelID)
            }
        }
    }
    
    private func sendInstruction(channelID: String) {
        sendText("", attachment:instructionAttachment(), channelID: channelID)
    }
    
    private func sendText(text: String, attachment: Attachment?, channelID: String) {
        client.webAPI.sendMessage(channelID, text: text, username: botName, asUser: true, parse: .None, linkNames: true, attachments: [attachment], unfurlLinks: true, unfurlMedia: true, iconURL: nil, iconEmoji: nil, success: { (_: (ts: String?, channel: String?)) in
            
        }) { (error) in
            
        }
    }
    
    // MARK: - Helpers
    
    private func dutyString(key: String) -> String? {
        if let dutyUsers = dutyList[key] {
            return "\(dutyUsers.first!) и \(dutyUsers.last!) дежурят \(key)"
        }
        return nil
    }
    
    private func instructionAttachment() -> Attachment {
        let instructions = ["Помыть внутри", "Помыть снаружи", "Помыть зеленую крышку"]
        var attachmentFields = [AttachmentField]()
        for (index, instruction) in instructions.enumerate() {
            let title = "\(index + 1). \(instruction)"
            let attachmentField = AttachmentField(title: "", value: title)
            attachmentFields.append(attachmentField)
        }
        return Attachment(fallback: "Инструкция", title: "Инструкция", colorHex: AttachmentColor.Good.rawValue, text: "", fields: attachmentFields)
    }
}