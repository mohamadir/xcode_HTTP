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
}

struct ChatUser {
    static var currentUser: Message?
}

struct GroupMembers{
    static var currentMemmber: GroupMember?
}


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
    var group_leader_first_name: String?
    var group_leader_last_name:  String?
    var group_leader_image: String?
    var group_leader_email: String?
    var is_company: Int?
    var group_leader_company_name: String?
    var group_leader_company_image: String?
    var translations: [GroupTranslation]?
    var group_leader_birth_date: String?
    var group_leader_about: String?
    var group_leader_gender: String?
    
}
struct GroupTranslation: Codable {
    var locale: String?
    var title: String?
    var description: String?
    var origin: String?
    var destination: String?
    
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
    var hotels: [Hotels]?
    var restaurants: [Restaurants]?
    var tour_guides: [TourGuide]?
    var places: [Places]?
    var transports: [Transports]?
    var activities: [Activities]?
    var locations: [dayLocation]?
}

struct DayImage: Codable {
    var id : Int?
    var path: String?
}


// hotel
struct Hotels: Codable {
    var id: Int?
    var website: String?
    var translations: [Hotel]?
}

struct Hotel: Codable{
    var id: Int?
    var name: String?
}

// restaurants

struct Restaurants: Codable{
    var id: Int?
    var translations: [Restaurant]?
}

struct Restaurant: Codable{
    var id: Int?
    var name: String?
  //  var restaurant_translations: [RestaurantTranslations]?
}
struct RestaurantTranslations: Codable{
    var id: Int?
    var name: String?
}



// tour guides
struct TourGuides: Codable{
    var id: Int?
    var translations: [TourGuide]?
}
struct TourGuide: Codable{
    var id: Int?
    var translations: [TourGuideTranslation]?
}

struct TourGuideTranslation: Codable{
    var id: Int?
    var first_name: String?
    var last_name: String?
    
}


// places
struct Places: Codable{
    var id: Int?
    var name: String?
}

// transports

struct Transports: Codable{
    var id: Int?
    var company_name: String?
}

// Activities
struct Activities: Codable{
    var id: Int?
    var name: String?
}

// Locations

struct dayLocation: Codable{
    var id: Int?
    var day_id: Int?
    var location: String?
    var lat: String?
    var long: String?
    var title: String?
}








