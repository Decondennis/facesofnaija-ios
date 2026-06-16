import Foundation

class GetStoriesModel {
    struct StoriesScuccessModel {
        var apiStatus: Int?
        var stories: [UserDataElement]?
        init() {}
    }
    
    struct StoriesErrorModel: Codable {
        var apiStatus: String?
        var errors: Errors?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    
    struct Errors: Codable {
        var errorID, errorText: String?
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

    // Simplified for story display - only fields the UI needs
    struct UserDataStory {
        var id, userID, title, storyDescription: String?
        var posted, expire: String?
        var thumbnail: String?
        var isOwner: Bool?
        var timeText: String?
        var videos: [StoryVideo]?
        init() {}
    }
    
    struct StoryVideo {
        var id, storyID, type: String?
        var filename: String?
        var expire: String?
        init() {}
    }

    struct UserDataElement {
        var userID, username, name: String?
        var firstName, lastName: String?
        var avatar, cover: String?
        var gender: String?
        var stories: [UserDataStory]?
        init() {}
    }
}

class CreateStoryModel {
    struct CreateStorySuccessModel: Codable {
        let apiStatus, storyID: Int?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case storyID = "story_id"
        }
    }
    struct CreateStoryErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    struct Errors: Codable {
        let errorID: Int?
        let errorText: String?
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }
}

class DeleteStoryModel {
    struct DeleteStorySuccessModel: Codable {
        let apiStatus: Int?
        let message: String?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case message
        }
    }
    struct DeleteStoryErrorModel: Codable {
        let apiStatus: String?
        let errors: Errors?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    struct Errors: Codable {
        let errorID: Int?
        let errorText: String?
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }
}
