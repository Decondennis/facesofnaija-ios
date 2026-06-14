//
//  APIClientCustom.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 13/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import Foundation


public struct APIClientCustom {
    public static let baseURl = "\(APIClient.baseURl)/api"
    public struct Get_Community_Names {
        public static let Get_Community_Names = "\(baseURl)/communities-custom"
    }
    public struct ReqeustCommunity{
        public static let requestCommunityApi = "\(baseURl)/request-community"
    }
    
    public struct GetCommunityData {
        public static let getCommunitiesDataApi =  "\(baseURl)/get-community-data"
    }
    
    public struct GetCommunityPost{
        public static let getCommunityPostApi = "\(baseURl)/posts"
    }
    
    public struct JoinCommunity{
        public static let joinCommunityAPi = "\(baseURl)/join-community"
    }
    
    public struct AddMembertoCommunity {
        public static let addMmembertoCommunityApi = "\(baseURl)/community_add"
    }
    
    public struct GetCommunityMember {
        public static let getCommunityMemberApi = "\(baseURl)/get_community_members"
    }
    
    public struct UpdateCommunityData {
        public static let updateCommunityDataApi = "\(baseURl)/update-community-data"
    }
    
    public struct Params {
        public static let name = "name"
        public static let country = "country"
        public static let state = "state"
        public static let lga = "lga"
        public static let about = "about"
        public static let privacy = "privacy"
        public static let community_id = "community_id"
        public static let communityId = "communityId"
    }
    
}
