//
//  Models.swift
//  Snapgroup
//
//  Created by snapmac on 3/9/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
import SwiftHTTP
import SwiftEventBus
// ********************************    CURRENT OPJECT *****************************
struct MyVriables {
    
    static var currentIndexCompanion: Int = 0
    static var currentComapnion: CompanionInfo = CompanionInfo(first_name: "", last_name: "", group_id: -1, gender: "male", birth_date: "01/01/18", id: -1)
    static var currentPhoneNumber: String?
    static var facebookMember: FacebookMember?
    static var currentGdbr: ModalGDPR?
    static var enableGdpr: GdprObject?
    static var fromGroup: String? = ""
    static var joinToGroup: String? = ""
    static var prefContry: String?
    static var phoneNumber: String?
     static var phoneNumberr: String?
    static var fileName: String?
    static var arrayGdpr : GdprPost?
    static var currntUrl: String?
    static var kindRegstir: String?
    static var currentType: String?
    static var currentGroup: TourGroup?
    static var isBookClick: Bool = false
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

struct CompanionInfo : Codable{
    var first_name: String?
    var last_name: String?
    var group_id: Int?
    var gender: String?
    var birth_date: String?
    var id: Int?

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
struct AccessToken: Codable {
    var token_type: String?
    var expires_in: Int?
    var access_token: String?
}

 struct PlanProvider {
 static var CurrentService: [Any]?
}
struct GroupMembers{
    static var currentMemmber: GroupMember? = GroupMember(id : -1, email : "", first_name : "", last_name : "", profile_image : "", companion_number : 0, status : "", role : "")
    static var isGoing: Bool?
}


func setCheckTrue(type:String,groupID: Int) {
    var params: [String : Any] = ["" : ""]
    if groupID == -1 {
        params = [type : true]
    }else {
        params = [type : true, "group_id" : groupID]
    }
    print("Type : \(type) , group _ id : \(groupID)")
    let strMethod: String = ApiRouts.Api + "/downloads/\(UIDevice.current.identifierForVendor!.uuidString)"
    HTTP.PUT(strMethod, parameters: params) { response in
        if response.error != nil {
            print("error \(String(describing: response.error?.localizedDescription))")
            return
        }
        print("SETchek true \(response.description)")

    }
    
}
func setUnreadMessages(member_id:Int) {
    let strMethod: String = ApiRouts.Api + "/members/\(member_id)/unread"
    HTTP.GET(strMethod, parameters: []) { response in
        if response.error != nil {
            print("error \(String(describing: response.error?.localizedDescription))")
            return
        }
        do {
            let  totalUnreads = try JSONDecoder().decode(UnreadMesages.self, from: response.data)
            if totalUnreads.total_unread_messages != nil {
                    setToUserDefaults(value: (totalUnreads.total_unread_messages)!, key: "chat_counter")
            }
            if totalUnreads.total_unread_notifications != nil {
                    setToUserDefaults(value: (totalUnreads.total_unread_notifications)!, key: "inbox_counter")
            }
            SwiftEventBus.post("counters")
            
            print("SETchek true \(response.description)")
        }catch{
            
        }
        
        
        
    }
}
func setToUserDefaults(value: Any?, key: String){
    if value != nil {
        let defaults = UserDefaults.standard
        defaults.set(value!, forKey: key)
    }
    else{
        let defaults = UserDefaults.standard
        
        defaults.set("no value", forKey: key)
    }
    
    
}
struct UnreadMesages: Codable {
    var total_unread_notifications: Int?
    var total_unread_messages: Int?
}
func sendSms(phonenum : String) {
    let params = ["phone": phonenum]
    
    HTTP.POST(ApiRouts.RegisterCode, parameters: params) { response in
        if response.error != nil {
            print("error \(response.error?.localizedDescription)")
            return
        }
        setCheckTrue(type: "sms_sent", groupID: -1)
        
        
        //do things...
    }
}
func getTodayString() -> String{
    
    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second
    
    let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
    print("Today is \(today_string)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    let dt = dateFormatter.date(from: today_string)
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Jerusalem")
    return dateFormatter.string(from: dt!)
    
}
func gmtToLocal(date:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Jerusalem")
    print("Tine zon is \(TimeZone.current)")
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: dt!)
}
func setFormat(date:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    let dt = dateFormatter.date(from: date)
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: dt!)
}

struct CompanionsRequset: Codable {
    var campanions: [CompanionInfo]?
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
    var id: Int?
    var rating: Double?
    var review: String?
}
struct ExistMember: Codable {
    var exist: Bool?
}
func convertToUTC(dateToConvert:String)  {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"//Input Format
//    dateFormatter.timeZone = NSTimeZone(name: "UTC+02") as TimeZone!
//    let UTCDate = dateFormatter.date(from: dateToConvert)
//    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // Output Format
//    dateFormatter.timeZone = TimeZone.current
//    print("My time zone is \(dateFormatter.timeZone!)    Time zone is \(TimeZone.current.description)")
//    let UTCToCurrentFormat = dateFormatter.string(from: UTCDate!)
//    return UTCToCurrentFormat
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    dateFormatter.timeZone = TimeZone(abbreviation: "GMT‎+03")
//    let dt = dateFormatter.date(from: "2018-08-08 10:42:00")
//    print("Date dt = \(String(describing: dt))")
//    dateFormatter.timeZone = TimeZone.current
//    //dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
//    print("current time zone is \(TimeZone.current) and time zone is \(dateFormatter.timeZone) AND new date is \(dateFormatter.string(from: dt!))")
//    return dateFormatter.string(from: dt!)
    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//    let date = dateFormatter.date(from: dateToConvert)
//    dateFormatter.timeZone = TimeZone.current
//    let timeStamp = dateFormatter.string(from: date!)
//    print("Date is \(String(describing: date)) and timestamp id = \(timeStamp)")
//    return date!

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
    var days: Int?
    var description: String?
    var open: Bool?
    var role: String?
    var price: String?
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
    var rotation: String?
    var hours_of_operation: String?
    var frequency: String?
    var start_time: String?
    var end_time: String?
    var group_leader_id: Int?
    var special_price: Float?
    var special_price_tagline: String?
    var translations: [GroupTranslation]?
    var group_tools: GroupTools?
    var group_settings: GroupSettings?
    var chat: ChatObject?
    var group_conditions: String?
    
}
struct GroupItemObject: Codable {
    var id: Int?
    var start_date: String?
    var end_date: String?
    var registration_end_date: String?
    var is_company: Int?
    var open: Bool?
    var rotation: String?
    var start_time: String?
    var end_time: String?
    var frequency: String?
    var special_price: Float?
    var hours_of_operation: String?
    var group_leader_id: Int?
    var days: Int?
    var group_leader: GroupLeaderStruct?
    var translations: [GroupTranslation]?
    var images: [ImageStruct]?
    var role: String?
}
struct GroupLeaderStruct: Codable{
    var id: Int?
    var profile: GroupLeaderProfileStruct?
    var images: [ImageStruct]?
}
struct ImageStruct: Codable{
    var path: String?
}
struct GroupLeaderProfileStruct: Codable{
    var first_name: String?
    var last_name: String?
    var company_name: String?
    var company_image: String?
}
struct GroupSettings: Codable{
    var payments_url: String?
}
struct ChatObject: Codable{
    var id: Int?
}
struct InboxMessageObj: Codable{
    var data: [InboxMessage]
    var current_page: Int?
    var last_page: Int?
    var total: Int?
}
struct InboxMessage: Codable{
    var id: Int?
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
    var payments: Bool?
    
    
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





















