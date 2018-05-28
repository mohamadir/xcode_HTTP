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
     static var prefContry: String?
     static var phoneNumber: String?
    static var fileName: String?
    static var arrayGdpr : GdprPost?
    static var currntUrl: String?
    static var currentType: String?
    static var currentGroup: TourGroup?
    static var isMember: Bool = false
    static var currentMember: Member?
    static var roleStatus: String = ""
    static var shouldRefresh: Bool = false
    static var currentInboxMessage: InboxMessage?
    static var MemberInboxShouldRefresh: Bool = false
    static var CurrentTopic: String = ""
    static var TopicSubscribe: Bool = true
    static var shouldRefreshBusStation: Bool = false
    static var IsFromArrival: Bool = false
    static var imageUrl: String = ""
    
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
    static var isGoing: Bool?
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
  //  var age: Int?
    var translations: [ServiceTranslations]?
    var name: String?
    var phone: String?
    var first_day: Int?
    var last_day: Int?
    var company_name: String?
    var city: String?
    var rating: Double?
    var booking_rating: Double?
}
struct ServiceTranslations: Codable {
    var name: String?
    var first_name: String?
    var last_name: String?
    var languages: String?
    var city: String?
    var company_name: String?
    
}
///////////////////////////Ratings model ////////////////////////////////////


struct RatingModel: Codable {
    var first_name: String?
    var last_name: String?
    var image_path: String?
    var rating: Double?
    var review: String?
}




//////////////////////////////Arrival confirmation///////////////////////////

struct StationModel: Codable {
    var id: Int?
    var location: String?
    var my_station: String?
}
struct ArriveChecked: Codable {
    var going: Bool?
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
    var rating: Double?
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
    var group_leader_id: Int?
    var translations: [GroupTranslation]?
    var group_tools: GroupTools?
    var chat: ChatObject?
    var group_conditions: String?
    
}
struct ChatObject: Codable{
    var id: Int?
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
    var total_unread_messages: Int?
    var total_unread_notifications: Int?
    
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
struct ChatGroup: Codable{
    var messages: [ChatListGroupItem]?
}
struct ChatListGroupItem: Codable{
    var member_id: Int?
    var sender_name: String?
    var profile_image: String?
    var type: String?
    var message: String?
    var image_path: String?
    var created_at: String?
}


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
/********** CHAT *****************/

struct RecentAction: Codable {
    var id: Int?
    var member_id: Int?
    var group_id: Int?
    var partner_id: Int?
    var type: String?
    var created_at: String?
    var group: TourGroup?
}
struct DocumentObject: Codable {
    var required_documents: [ReqireDocuments]
}
struct DownloadDocObject: Codable {
    var files: [FilesObecjt]
}

struct ReqireDocuments: Codable {
    var id: Int?
    var item: String?
    var files: [FilesObecjt]
}
struct FilesObecjt: Codable {
    var id: Int?
    var filename: String?
    var original_filename: String?
    var mime: String?
    var path: String?
}
struct GdprPost {
    var profile_details: Bool
    var phone_number: Bool
    var groups_relations: Bool
    var chat_messaging: Bool
    var pairing: Bool
    var real_time_location: Bool
    var files_upload: Bool
    var push_notifications: Bool
    var rating_reviews: Bool
    
}





















