//
//  ApiRequests.swift
//  Snapgroup
//
//  Created by snapmac on 2/28/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
class ApiRouts{
 static let Web: String = "http://api.snapgroup.co.il"
 static let Api: String  = "https://api.snapgroup.co.il/api"
 static let AllGroupsRequest: String = "\(Api)/getallgroups"
 static let OpenGroups: String = "\(Api)/filter/open"
 static let RegisterCode: String = "\(Api)/getregistercode"

    
}

typealias DownloadComplete = () -> ()

func test(completed: @escaping DownloadComplete)
