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
    
    static var facebookMember: FacebookMember?
    static var currentGdbr: ModalGDPR?
    static var enableGdpr: GdprObject?
    static var fromGroup: String? = ""
    static var joinToGroup: String? = ""
    static var prefContry: String?
    static var phoneNumber: String?
    static var fileName: String?
    static var arrayGdpr : GdprPost?
    static var currntUrl: String?
    static var currentType: String?
    static var currentGroup: TourGroup?
    static var isAvailble: Bool = true
    static var isMember: Bool = false
    var profile: MemberProfile?
    var gdpr: GdprStruct?
    static var currentMember: Member? = Member(email: "", phone : "", id : -1, type: "", facebook_id: "", profile_image: "", profile : MemberProfile(member_id : -1, first_name : "", last_name: "", email: "", gender: "male", birth_date: "", profile_image: nil,facebook_profile_image: nil), gdpr : GdprStruct(profile_details: false, phone_number: true, groups_relations: true, chat_messaging: true, pairing: true, real_time_location: true, files_upload: true, push_notifications: true, rating_reviews: true, group_details: true, billing_payments : false, checkAllSwitch: false))
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
struct ModalGDPR {
    var title: String
    var description: String
    var gdbrParmter: String
    var isDeleteAcount: Bool
    
}

 struct PlanProvider {
 static var CurrentService: [Any]?
}
struct GroupMembers{
    static var currentMemmber: GroupMember? = GroupMember(id : -1, email : "", first_name : "", last_name : "", profile_image : "", status : "", role : "")
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
    var reviewer_id: Int?
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
struct GdprUpdate: Codable {
    var gdpr: GdprStruct?
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
    var group_leader_company_about: String?
    var group_leader_company_website: String?
    var group_leader_company_occupation: String?
    var group_leader_company_phone: String?
    var group_leader_birth_date: String?
    var group_leader_about: String?
    var group_leader_company_physical_address: String?
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
struct MyMemberInfo: Codable{
    //var message: String?
    var member: Member?
    var total_unread_messages: Int?
    var total_unread_notifications: Int?
}

struct Member: Codable{
    var email: String?
    var phone: String?
    var id: Int?
    var type: String?
    var facebook_id: String?
    var profile_image: String?
    var profile: MemberProfile?
    var gdpr: GdprStruct?
    
}
struct GdprStruct: Codable{
    var profile_details: Bool?
    var phone_number: Bool?
    var groups_relations: Bool?
    var chat_messaging: Bool?
    var pairing: Bool?
    var real_time_location: Bool?
    var files_upload: Bool?
    var push_notifications: Bool?
    var rating_reviews: Bool?
    var group_details: Bool?
    var billing_payments: Bool?
    var checkAllSwitch: Bool?
}


struct ElasticMember : Codable{
    var member_id: Int?
    var email: String?
    var first_name: String?
    var last_name: String?
    var profile_image: String?
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
    var facebook_profile_image: String?

    
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
struct MemberMap: Codable {
     var members: [MemberStruct]?
}

struct MemberStruct: Codable{
    var lon: String?
    var lat: String?
    var profile_image: String?
    var phone: String?
    var first_name: String?
    var last_name: String?
    var member_id: Int?
    var updated_at: String?
}

struct DayImage: Codable {
    var id : Int?
    var path: String?
}
struct SubscribeGroups: Codable {
    var groups: [TourGroup]?
}
struct FacebookMember: Codable {
    var first_name: String?
    var last_name: String?
    var facebook_id: String?
    var facebook_profile_image: String?

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
}


/********** CHAT *****************/
struct ChatGroup: Codable{
    
    var messages: ChatGroupStruct?
}
struct ChatGroupStruct: Codable{
    var data: [ChatListGroupItem]?
    var current_page: Int?
    var last_page: Int?
    var total: Int?
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





















