//
//  main.swift
//  DutyBot
//
//  Created by Artem Novichkov on 17.07.16.
//  Copyright © 2016 Artem Novichkov. All rights reserved.
//

import Foundation
import SlackKit

let dutyBot = DutyBot(token: "1311735748:AAGtBeKbDlg5RsVrRhV36TAENexdx0QiARY")
dutyBot.client.connect()
NSRunLoop.mainRunLoop().run()
