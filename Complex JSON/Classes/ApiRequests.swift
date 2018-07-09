//
//  ApiRequests.swift
//  Snapgroup
//
//  Created by snapmac on 2/28/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import SwiftHTTP
class ApiRouts{
 static let Web: String = "https://api.snapgroup.co"
 static let ChatServer: String = "\(Web):3030/"
 static let Api: String  = "https://api.snapgroup.co/api"
 static let AllGroupsRequest: String = "\(Api)/groups"
 static let OpenGroups: String = "\(Api)/filter/open"
 static let RegisterCode: String = "\(Api)/getregistercode"
 static let Register: String = "\(Api)/register"
    
 // action types
    
    static let CreateGroupType: String = "create_group"
    static let DeleteGroupType: String = "delete_group"
    static let JoinGroupType: String = "join_group"
    static let LeaveGroupType: String = "leave_group"
    static let VisitGroupType: String = "visit_group"
    static let MessageSentType: String = "messag_sent"
    static let PairType: String = "pair_sent"

    
// private chat
 static let HistoryConversation: String = "\(Api)/getprivatemessages/" // .../myId/opponentid
    
 // action request
 static func actionRequest(parameters: [String: Any]){
        HTTP.POST(self.Web + "/api/members/actions", parameters: parameters) { response in
           print(response)
        }
 }
    
    
    
}

