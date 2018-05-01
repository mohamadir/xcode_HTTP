//
//  Models.swift
//  Snapgroup
//
//  Created by snapmac on 3/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
// ********************************    CURRENT OPJECT *****************************
struct MyVriables {
    static var currentGroup: TourGroup?
    static var isMember: Bool = false
    static var currentMember: Member?
    static var roleStatus: String = ""
    static var shouldRefresh: Bool = false
    static var currentInboxMessage: InboxMessage?
    static var MemberInboxShouldRefresh: Bool = false
    
}

struct ChatUser {
    static var currentUser: Partner?
    static var ChatId: Int?
}
 struct PlanProvider {
 static var CurrentService: [Any]?
}
struct GroupMembers{
    static var currentMemmber: GroupMember?
}

/////////////////////////////////////////////// servivices model ///////////////
struct ServicesModel: Codable {
    var hotels: [ServiceModel]?
    var restaurants: [ServiceModel]?
    var tourguides: [ServiceModel]?
    var places: [ServiceModel]?
    var activities: [ServiceModel]?
    var transports: [ServiceModel]?
}
struct ServiceModel: Codable {
    var id: Int?
    var age: Int?
    var translations: [ServiceTranslations]?
    var name: String?
    var phone: String?
    var first_day: Int?
    var last_day: Int?
    var company_name: String?
    var city: String?
}
struct ServiceTranslations: Codable {
    var name: String?
    var first_name: String?
    var last_name: String?
    var languages: String?
    var city: String?
    var company_name: String?
    
}
/////////////////////////////////////////////////////////////////////////////

////////////////////////Provider Model///////////////////////////////////////
struct ProviderModel: Codable {
    var id: Int?
    var images: [GroupImage]?
    var contacts: [ContactsModel]?
    var translations: [ServiceTranslations]?
    var name: String?
    var company_name: String?
    var phone: String?
    var first_name: String?
    var last_name: String?
    var bio: String?
    var city: String?
    var description: String?
    var webSite: String?
}
struct ProviderImages: Codable {
    var id: Int?
    var path: String?
}
struct ContactsModel: Codable {
    var email: String?
}

//////////////////////////////////////////////////////////////////////////////
// ********************************    Group Model *****************************
struct TourGroup: Codable {
    var id: Int?
    var title: String?
    var image: String?
    var description: String?
    var open: Bool?
    var role: String?
    var registration_end_date: String?
    var start_date: String?
    var target_members: Int?
    var max_members: Int?
    var end_date: String?
    var is_company: Int?
    var group_leader_first_name: String?
    var group_leader_last_name:  String?
    var group_leader_image: String?
    var group_leader_email: String?
    var group_leader_company_name: String?
    var group_leader_company_image: String?
    var group_leader_birth_date: String?
    var group_leader_about: String?
    var group_leader_gender: String?
    var translations: [GroupTranslation]?
    var group_tools: GroupTools?
    
}

struct InboxMessage: Codable{
    var notification_id: Int?
    var sender_id: Int?
    var group_id: Int?
    var member_id: Int?
    var type: String?
    var read: Int?
    var accepted: String?
    var created_at: String?
    var subject: String?
    var body: String?
    var title: String?
    var first_name: String?
    var last_name: String?
}
struct GroupTranslation: Codable {
    var locale: String?
    var title: String?
    var description: String?
    var origin: String?
    var destination: String?
    
}
struct GroupTools: Codable {
    var itinerary: Bool?
    var map: Bool?
    var members: Bool?
    var chat: Bool?
    var documents: Bool?
    var checklist: Bool?
    var services: Bool?
    var group_leader: Bool?
    var rooming_list: Bool?
    var voting: Bool?
    var arrival_confirmation: Bool?
    
}

struct GroupImage: Codable {
    var id: Int?
    var path: String?
}



// ********************************     Member Model       *****************************

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

struct ElasticMember : Codable{
    var id: Int?
    var email: String?
    var first_name: String?
    var last_name: String?
    var images: [Memberimage]?
}
struct Memberimage: Codable{
    var path: String?
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

// ********************************    Itinerary  Model     *****************************

struct PlanDays: Codable{
    var days: [Day]?
}

struct Day: Codable{
    var id: Int?
    var group_id: Int?
    var day_number: Int?
    var date: String?
    var title: String?
    var images: [DayImage]?
    var description: String?
    var sleep_location: String?
    var hotels: [ServiceModel]?
    var restaurants: [ServiceModel]?
    var tour_guides: [ServiceModel]?
    var places: [ServiceModel]?
    var transports: [ServiceModel]?
    var activities: [ServiceModel]?
    var locations: [dayLocation]?
}

struct DayImage: Codable {
    var id : Int?
    var path: String?
}



struct dayLocation: Codable{
    var id: Int?
    var day_id: Int?
    var location: String?
    var lat: String?
    var long: String?
    var title: String?
}

//CHECKLIST

struct GroupCheckList: Codable{
    
    var item: String?
    var required : Bool?
    var id : Int?
    var checked : Bool?
    
    init(item : String? , required : Bool? , id : Int? , checked : Bool?)
    {
        self.item = item
        self.required = required
        self.id = id
        self.checked = checked
    }
}


/********** CHAT *****************/


struct ChatListItem: Codable{
    var id: Int?
    var name: String?
    var type: String?
    var group_id: Int?
    var created_at: String?
    var updated_at: String?
    var partner: Partner?
    var last_message: Message?
    var total_unread: Int?
}

struct Partner: Codable{
    var id: Int?
    var email: String?
    var profile_image: String?
    var first_name: String?
    var last_name: String?
}

struct Message: Codable{
    var id: Int?
    var member_id: Int?
    var receiver_id: Int?
    var group_id: Int?
    var created_at: String?
    var updated_at: String?
    var chat_id: Int?
    var message: String?
    var type: String?
    var read: Int?
    var image_path: String?
    var file_path: String?
    var video_path: String?
    var first_name: String?
    var last_name: String?
    var video_thumbnail: String?
    var sender_name: String?
    
}





