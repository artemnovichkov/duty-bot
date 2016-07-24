//
//  main.swift
//  DutyBot
//
//  Created by Artem Novichkov on 17.07.16.
//  Copyright © 2016 Artem Novichkov. All rights reserved.
//

import Foundation
import SlackKit

let dutyBot = DutyBot(token: "SLACK_API_TOKEN")
dutyBot.client.connect()
NSRunLoop.mainRunLoop().run()