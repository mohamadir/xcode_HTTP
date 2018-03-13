//
//  Models.swift
//  Snapgroup
//
//  Created by snapmac on 3/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation

struct MyVriables {
    static var currentGroup: TourGroup?
}

struct ChatUser {
    static var currentUser: Message?
}

struct GroupMembers{
    static var currentMemmber: GroupMember?
    
}

struct TourGroup: Codable {
    var id: Int?
    var title: String?
    var image: String?
    var description: String?
    var registration_end_date: String?
    var start_date: String?
    var end_date: String?
    var group_leader_first_name: String?
    var group_leader_last_name:  String?
    var group_leader_image: String?
    var is_company: Int?
    var group_leader_company_name: String?
}

struct GroupImage: Codable {
    var id: Int?
    var path: String?
}




struct CurrentMember: Codable{
    //var message: String?
    var member: Member?
    var profile: MemberProfile?
    
}

struct Member: Codable{
    var email: String?
    var phone: String?
    var id: Int?
}
struct MemberProfile: Codable{
    var member_id: Int?
    var first_name: String?
    var last_name: String?
    var email: String?
    var gender: String?
    var birth_date: String?
    var profile_image: String?
    
    
}

struct Toy: Codable {
    var name: String?
    var last: String?
}

struct PlanDays: Codable{
    var days: [Day]?
}

struct Day: Codable{
    var id: Int?
    var group_id: Int?
    var day_number: Int?
    var title: String?
    var description: String?
    var sleep_location: String?
}


