import Foundation
import UIKit

// MARK: - Server Environment Configuration
// Change APP_ENVIRONMENT below to switch between servers.
// No other code changes are needed.

public enum ServerEnvironment {
    case development
    case production
    
    var url: String {
        switch self {
        case .development:  return "http://172.236.19.52"
        case .production:   return "https://facesofnaija.ng"
        }
    }
}

// MARK: - Centralized Base URL Configuration
// ╔══════════════════════════════════════════════╗
// ║  CHANGE ONLY THIS VALUE TO SWITCH SERVERS   ║
// ╚══════════════════════════════════════════════╝
private let APP_ENVIRONMENT: ServerEnvironment = .development

public class ServerCredentials {
    public static let instance = ServerCredentials()
    
    private var baseUrl: String = APP_ENVIRONMENT.url
    private var serverKey: String = "facesofnaija_ios_key"
    private var purchaseCode: String = ""
    
    public static func setServerDataWithKey(key: String) {
        instance.decodeKey(key)
    }
    
    public static func setBaseUrl(url: String) {
        instance.baseUrl = url
    }
    
    public static func setServerKey(serverKey: String) {
        instance.serverKey = serverKey
    }
    
    public static func setPurchaseCode(purchaseCode: String) {
        instance.purchaseCode = purchaseCode
    }
    
    public static func convertKeyString(refresh: String) -> (String, Int) {
        return (instance.baseUrl, 200)
    }
    
    private func decodeKey(_ key: String) {
        if let data = Data(base64Encoded: key),
           let decodedString = String(data: data, encoding: .utf8) {
            let components = decodedString.components(separatedBy: "/")
            if components.count > 0 {
                baseUrl = components[0]
            }
            if components.count > 1 {
                serverKey = components[1]
            }
        }
    }
    
    public func getBaseUrl() -> String {
        return baseUrl
    }
    
    public func getServerKey() -> String {
        return serverKey
    }
}

public struct APIClient {
    public static var baseURl: String {
        return ServerCredentials.instance.getBaseUrl()
    }
    
    public struct SERVER_KEY {
        public static var Server_Key: String {
            return ServerCredentials.instance.getServerKey()
        }
    }
    
    public struct LOCAL {
        public static let siteSetting = "siteSetting"
    }
    
    public struct Params {
        public static let s = "access_token"
        public static let accessToken = "access_token"
        public static let serverKey = "server_key"
        public static let api_key = "api_key"
        public static let userName = "username"
        public static let user_name = "user_name"
        public static let password = "password"
        public static let email = "email"
        public static let confirmPassword = "confirm_password"
        public static let ios_n_device_id = "ios_n_device_id"
        public static let userId = "user_id"
        public static let postId = "post_id"
        public static let commentId = "comment_id"
        public static let text = "text"
        public static let postText = "postText"
        public static let postPrivacy = "postPrivacy"
        public static let post_color = "post_color"
        public static let postSticker = "postSticker"
        public static let feeling = "feeling"
        public static let feeling_type = "feeling_type"
        public static let location = "location"
        public static let postPhotos = "postPhotos"
        public static let imageType = "image_type"
        public static let FileType = "file_type"
        public static let type = "type"
        public static let action = "action"
        public static let status = "status"
        public static let limit = "limit"
        public static let offset = "offset"
        public static let off_set = "off_set"
        public static let myOffset = "my_offset"
        public static let afterPostId = "after_post_id"
        public static let hash = "hash"
        public static let keyword = "keyword"
        public static let search_keyword = "search_keyword"
        public static let q = "q"
        public static let category = "category"
        public static let categoryId = "category_id"
        public static let distance = "distance"
        public static let currentLat = "current_lat"
        public static let currentLng = "current_lng"
        public static let gender = "gender"
        public static let age_from = "age_from"
        public static let age_to = "age_to"
        public static let filterbyage = "filterbyage"
        public static let relship = "relship"
        public static let verified = "verified"
        public static let country = "country"
        public static let fetch = "fetch"
        public static let groupId = "group_id"
        public static let group_id = "group_id"
        public static let groupName = "group_name"
        public static let groupTitle = "group_title"
        public static let groupPrivacy = "group_privacy"
        public static let pageId = "page_id"
        public static let page_id = "page_id"
        public static let pageName = "page_name"
        public static let pageTitle = "page_title"
        public static let pageDecription = "page_description"
        public static let pageCategory = "page_category"
        public static let pagePhone = "page_phone"
        public static let eventId = "event_id"
        public static let event_id = "event_id"
        public static let eventName = "event_name"
        public static let eventDescription = "event_description"
        public static let eventLocation = "event_location"
        public static let eventStartDate = "event_start_date"
        public static let eventEndDate = "event_end_date"
        public static let eventStarttime = "event_start_time"
        public static let eventEndtime = "event_end_time"
        public static let blogId = "blog_id"
        public static let movie_id = "movie_id"
        public static let story_id = "story_id"
        public static let reaction_type = "reaction_type"
        public static let reactionType = "reaction_type"
        public static let reactions = "reactions"
        public static let blockUser = "block_action"
        public static let code = "code"
        public static let two_factor = "two_factor"
        public static let newPassword = "new_password"
        public static let currentPassword = "current_password"
        public static let firstName = "first_name"
        public static let lastName = "last_name"
        public static let birthday = "birthday"
        public static let usr_birthday = "usr_birthday"
        public static let phone = "phone"
        public static let phoneNumber = "phone_number"
        public static let address = "address"
        public static let website = "website"
        public static let facebook = "facebook"
        public static let twitter = "twitter"
        public static let linkedin = "linkedin"
        public static let youtube = "youtube"
        public static let instgram = "instgram"
        public static let vk = "vk"
        public static let working = "working"
        public static let i_currently_work = "i_currently_work"
        public static let school = "school"
        public static let about = "about"
        public static let description = "description"
        public static let title = "title"
        public static let albumName = "album_name"
        public static let privacy = "privacy"
        public static let cover = "cover"
        public static let avatar = "avatar"
        public static let provider = "provider"
        public static let googleKey = "google_key"
        public static let googleMapKey = "google_key"
        public static let headerKey = "header_key"
        public static let id = "id"
        public static let val = "val"
        public static let lenght = "lenght"
        public static let amount = "amount"
        public static let currency = "currency"
        public static let callActionType = "call_action_type"
        public static let callActionUrl = "call_action_type_url"
        public static let productTitle = "product_title"
        public static let productDescription = "product_description"
        public static let productPrice = "product_price"
        public static let productLocation = "product_location"
        public static let productCategory = "product_category"
        public static let productType = "product_type"
        public static let jobTitle = "job_title"
        public static let jobDescription = "job_description"
        public static let jobType = "job_type"
        public static let jobCategory = "job_category"
        public static let jobC_id = "job_c_id"
        public static let jobId = "job_id"
        public static let minimumSalary = "minimum"
        public static let maximumSalary = "maximum"
        public static let salaryDate = "salary_date"
        public static let experience_description = "experience_description"
        public static let experience_start_date = "experience_start_date"
        public static let experience_end_date = "experience_end_date"
        public static let company = "company"
        public static let followersOffset = "followers_offset"
        public static let followingOffset = "following_offset"
        public static let genre = "genre"
        public static let thumbnail = "thumbnail"
        public static let device_id = "device_id"
        public static let mobile = "mobile"
        public static let position = "position"
        public static let workspace = "workspace"
        public static let where_did_you_work = "where_did_you_work"
    }
    
    public struct Login_Authentication {
        public static let loginAuthApi = "\(baseURl)/api/auth"
    }
    
    public struct SignUp_Authentication {
        public static let signupAuthApi = "\(baseURl)/api/create-account"
    }
    
    public struct SocialLogin {
        public static let socailLoginApi = "\(baseURl)/api/social-login"
    }
    
    public struct ForgetPassword {
        public static let forgetPasswordApi = "\(baseURl)/api/send-reset-password-email"
    }
    
    public struct TwoFactorAuthentication {
        public static let TwoFactorAuthApi = "\(baseURl)/api/two-factor"
    }
    
    public struct UpdateTwoFactor {
        public static let updateTwoFactorApi = "\(baseURl)/api/update_two_factor"
    }
    
    public struct UserInfo {
        public static let userInfoApi = "\(baseURl)/api/get-user-data"
    }
    
    public struct User_Data {
        public static let getUserDataApi = "\(baseURl)/api-v2.php?type=get-user-data"
    }
    
    public struct User_Images {
        public static let getUserImagesApi = "\(baseURl)/api/get-user-albums"
    }
    
    public struct User_Posts_Data {
        public static let getUserPostsApi = "\(baseURl)/api/posts"
    }
    
    public struct UpdateProfile {
        public static let updateProfileApi = "\(baseURl)/api/update-user-data"
    }
    
    public struct DeleteUser {
        public static let deleteUserApi = "\(baseURl)/api/delete-user"
    }
    
    public struct Session {
        public static let getSession = "\(baseURl)/api/sessions"
    }
    
    public struct Block_User {
        public static let bockUserApi = "\(baseURl)/api/block-user"
        public static let getBlockUserApi = "\(baseURl)/api/get-blocked-users"
    }
    
    public struct Get_News_Feed {
        public static let get_News_Feed_Posts = "\(baseURl)/api-v2.php?type=get_news_feed"
    }
    
    public struct AddPost {
        public static let AddPostApi = "\(baseURl)/api-v2.php?type=create-post"
    }
    
    public struct DeletePost {
        public static let deletePostApi = "\(baseURl)/api-v2.php?type=post-actions"
    }
    
    public struct EditPost {
        public static let editPostApi = "\(baseURl)/api-v2.php?type=post-actions"
    }
    
    public struct GetPostById {
        public static let getPostApi = "\(baseURl)/api/get-post-data"
    }
    
    public struct FetchComment {
        public static let fetchComment = "\(baseURl)/api-v2.php?type=comments"
    }
    
    public struct CreateComment {
        public static let createCommentApi = "\(baseURl)/api-v2.php?type=comments"
    }
    
    public struct CreateCommentReply {
        public static let createCommentReply = "\(baseURl)/api-v2.php?type=comments"
    }
    
    public struct LikeComment {
        public static let likeComment = "\(baseURl)/api-v2.php?type=comments"
    }
    
    public struct ReportComment {
        public static let reportComment = "\(baseURl)/api-v2.php?type=report_comment"
    }
    
    public struct ReportPost {
        public static let reportPostApi = "\(baseURl)/api-v2.php?type=report_post"
    }
    
    public struct BlogComments {
        public static let blogCommentApi = "\(baseURl)/api/blogs"
    }
    
    public struct AddReactions {
        public static let addReactionApi = "\(baseURl)/api-v2.php?type=get-reactions"
    }
    
    public struct GetReactions {
        public static let getPostReactionApi = "\(baseURl)/api-v2.php?type=get-reactions"
    }
    
    public struct Share {
        public static let sharePosts = "\(baseURl)/api-v2.php?type=post-actions"
    }
    
    public struct SavePost {
        public static let savePostApi = "\(baseURl)/api-v2.php?type=post-actions"
    }
    
    public struct GetSavedPost {
        public static let getSavedPostApi = "\(baseURl)/api-v2.php?type=posts"
    }
    
    public struct PopularPost {
        public static let getPopularPostApi = "\(baseURl)/api-v2.php?type=most_liked"
    }
    
    public struct VideoView {
        public static let addVideoView = "\(baseURl)/api-v2.php?type=post-actions"
    }
    
    public struct GetHashtagPost {
        public static let getHashtagPostApi = "\(baseURl)/api/search_for_posts"
    }
    
    public struct SEARCH_FOR_POST {
        public static let search_for_post = "\(baseURl)/api/search_for_posts"
    }
    
    public struct FollowRequest {
        public static let followRequestApi = "\(baseURl)/api/follow-user"
    }
    
    public struct Follow_Request {
        public static let followRequestApi = "\(baseURl)/api/follow-request-action"
    }
    
    public struct GetFriends {
        public static let getFriendsApi = "\(baseURl)/api/get-friends"
    }
    
    public struct CommonThings {
        public static let getCommonThings = "\(baseURl)/api/common_things"
    }
    
    public struct GeneralData {
        public static let getGeneralDataApi = "\(baseURl)/api/get-general-data"
    }
    
    public struct Stie_Setting {
        public static let siteSettingApi = "\(baseURl)/api/get-site-settings"
    }
    
    public struct Activities {
        public static let getActivities = "\(baseURl)/api/get-activities"
    }
    
    public struct MY_ACTIVITIES {
        public static let My_Activities = "\(baseURl)/api/my_activities"
    }
    
    public struct GetMemories {
        public static let getMemories = "\(baseURl)/api/get_memories"
    }
    
    public struct Search {
        public static let getSearchDataApi = "\(baseURl)/api/search"
    }
    
    public struct GetCommunity {
        public static let getcummunityApi = "\(baseURl)/api/get-community"
    }
    
    public struct GetGroupData {
        public static let getGroupsDataApi = "\(baseURl)/api/get-group-data"
    }
    
    public struct GetGroupMember {
        public static let getGroupMemberApi = "\(baseURl)/api/get_group_members"
    }
    
    public struct GetGroupPost {
        public static let getGroupPostApi = "\(baseURl)/api/posts"
    }
    
    public struct GetSuggestedGroups {
        public static let suggestedGroupApi = "\(baseURl)/api/fetch-recommended"
    }
    
    public struct GetMyGroups {
        public static let getMyGroupsApi = "\(baseURl)/api/get-my-groups"
    }
    
    public struct GetNotGroupMemebers {
        public static let getNotGroupMemebrsApi = "\(baseURl)/api/not_in_group_member"
    }
    
    public struct CreateGroup {
        public static let createGroupApi = "\(baseURl)/api/create-group"
    }
    
    public struct DeleteGroup {
        public static let deleteGroupApi = "\(baseURl)/api/delete_group"
    }
    
    public struct UpdateGroupData {
        public static let updateGroupDataApi = "\(baseURl)/api/update-group-data"
    }
    
    public struct JoinGroup {
        public static let joinGroupAPi = "\(baseURl)/api/join-group"
    }
    
    public struct AddMembertoGroup {
        public static let addMmembertoGroupApi = "\(baseURl)/api/group_add"
    }
    
    public struct GetPageData {
        public static let getPageDataApi = "\(baseURl)/api/get-page-data"
    }
    
    public struct GetPageInfo {
        public static let getPageInfoApi = "\(baseURl)/api/get-page-data"
    }
    
    public struct GetPagePost {
        public static let getPagePostApi = "\(baseURl)/api/posts"
    }
    
    public struct GetMyPages {
        public static let getMyPagesApi = "\(baseURl)/api/get-my-pages"
    }
    
    public struct GetLikedPages {
        public static let getMyLikedPagesApi = "\(baseURl)/api/get-my-pages"
    }
    
    public struct GetNotPageMemebers {
        public static let getNotPageMemebrsApi = "\(baseURl)/api/not_in_page_member"
    }
    
    public struct CreatePage {
        public static let createPageApi = "\(baseURl)/api/create-page"
    }
    
    public struct DeletePage {
        public static let deletePageAPi = "\(baseURl)/api/delete_page"
    }
    
    public struct UpdatePageData {
        public static let updatePageDataApi = "\(baseURl)/api/update-page-data"
    }
    
    public struct LikePage {
        public static let likePageApi = "\(baseURl)/api/like-page"
    }
    
    public struct AddMembertoPage {
        public static let addMmembertoPageApi = "\(baseURl)/api/page_add"
    }
    
    public struct RatePage {
        public static let ratePageApi = "\(baseURl)/api/rate_page"
    }
    
    public struct GetPageReview {
        public static let getPageReviewApi = "\(baseURl)/api/page_reviews"
    }
    
    public struct Events {
        public static let getEventsApi = "\(baseURl)/api/get-events"
        public static let createEventApi = "\(baseURl)/api/create-event"
        public static let editEvent = "\(baseURl)/api/create-event"
        public static let gotoEventApi = "\(baseURl)/api/go-to-event"
        public static let interestEventApi = "\(baseURl)/api/interest-event"
    }
    
    public struct Album {
        public static let albumApi = "\(baseURl)/api/albums"
    }
    
    public struct Stories {
        public static let getUserStories = "\(baseURl)/api-v2.php?type=get-user-stories"
        public static let createStories = "\(baseURl)/api-v2.php?type=create-story"
        public static let deleteStory = "\(baseURl)/api-v2.php?type=delete-story"
    }
    
    public struct Articles {
        public static let getBlogsApi = "\(baseURl)/api/get-articles"
    }
    
    public struct Get_Latest_Blog_POST {
        public static let BlogPost = "\(baseURl)/api/blogs"
    }
    
    public struct Products {
        public static let getProductApi = "\(baseURl)/api/get-products"
        public static let createProductApi = "\(baseURl)/api/create-product"
    }
    
    public struct Job {
        public static let jobApi = "\(baseURl)/api/job"
    }
    
    public struct Jobs {
        public static let ApplyJob = "\(baseURl)/api/job"
        public static let searchJob = "\(baseURl)/api/job"
    }
    
    public struct DeleteJob {
        public static let deleteJobApi = "\(baseURl)/api/delete_job"
    }
    
    public struct Funding {
        public static let getfundingApi = "\(baseURl)/api/funding"
        public static let createFundingApi = "\(baseURl)/api/funding"
    }
    
    public struct Wallet {
        public static let walletApi = "\(baseURl)/api/wallet"
    }
    
    public struct AddMoney {
        public static let addMoney = "\(baseURl)/api/wallet"
    }
    
    public struct Upgrade {
        public static let upgradeApi = "\(baseURl)/api/upgrade"
    }
    
    public struct Gift {
        public static let giftApi = "\(baseURl)/api/gift"
    }
    
    public struct Pokes {
        public static let PokesApi = "\(baseURl)/api/poke"
    }
    
    public struct Offers {
        public static let getOffersApi = "\(baseURl)/api/offer"
    }
    
    public struct Movies {
        public static let getMovies = "\(baseURl)/api/get-movies"
    }
    
    public struct Movies_Comment {
        public static let getMoviesComment = "\(baseURl)/api/movies_comments"
        public static let CreateMovieComment = "\(baseURl)/api/movies_comments"
        public static let addCommentReply = "\(baseURl)/api/movies_comments"
        public static let getCommentReplies = "\(baseURl)/api/movies_comments"
        public static let MovieCommentLikeDislike = "\(baseURl)/api/movies_comments"
        public static let CommentReplyLikeDislikep = "\(baseURl)/api/movies_comments"
    }
    
    public struct Games {
        public static let getGames = "\(baseURl)/api/games"
    }
    
    public struct GIFs {
        public static let GIFsApi = "https://api.giphy.com/v1/gifs/search"
    }
    
    public struct GoogleMap {
        public static let googleMapApi = "https://maps.googleapis.com/maps/api/geocode/json"
    }
    
    public struct Google_Key {
        public static let google_Key = "AIzaSyDAlG53TEdqWnwQ2wXJkC2CBKPyqW7vALU"
    }
    
    public struct NearByBusiness {
        public static let nearByBusiness = "\(baseURl)/api/nearby"
    }
    
    public struct NearbyFriends {
        public static let getNearByFriends = "\(baseURl)/api/get-nearby-users"
    }
    
    public struct Live {
        public static let createLive = "\(baseURl)/api/live"
    }
    
    public struct VoteUp {
        public static let voteUpApi = "\(baseURl)/api/vote_up"
    }
    
    public struct AddVote {
        public static let voteUPApi = "\(baseURl)/api/vote_up"
    }
    
    public struct InvtationLink {
        public static let invitationLinkApi = "\(baseURl)/api/invitation"
    }
    
    public struct DownloadInfo {
        public static let downloadInfoApi = "\(baseURl)/api/download_info"
    }
    
    public struct userList {
        public static let userlIst = "\(baseURl)/api/get-user-data"
    }
    
    public struct VIDEOS {
        public static let getUserVideos = "\(baseURl)/api/posts"
    }
}

public enum FileType: String {
    case image = "image"
    case video = "video"
    case file = "file"
}
