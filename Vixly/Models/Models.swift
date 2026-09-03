import Foundation

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var password: String?
    var name: String
    var avatar: String
    var bio: String
    var birthday: String
    var location: String
    var gender: String
    var postsCount: Int
    var followersCount: Int
    var followingCount: Int
    var coins: Int
    var isDeleted: Bool
    var createdAt: Date
}

struct Post: Identifiable, Codable {
    let id: String
    let userId: String
    var media: [PostMedia]
    var caption: String
    var styleTags: [String]
    var primaryStyleTag: String?
    var location: String
    var items: PostItems
    var likesCount: Int
    var commentsCount: Int
    var savesCount: Int
    var isLiked: Bool
    var isSaved: Bool
    var isTopFit: Bool
    var isPublic: Bool
    var isItemUnlocked: Bool
    var date: Date
    var createdAt: Date
}

struct PostMedia: Codable {
    let id: String
    let type: MediaType
    let url: String
    var isCover: Bool
}

enum MediaType: String, Codable {
    case photo
    case video
}

struct PostItems: Codable {
    var tops: [PostItem]
    var bottoms: [PostItem]
    var shoes: [PostItem]
    var accessories: [PostItem]
    
    var isEmpty: Bool {
        return tops.isEmpty && bottoms.isEmpty && shoes.isEmpty && accessories.isEmpty
    }
    
    var totalCount: Int {
        return tops.count + bottoms.count + shoes.count + accessories.count
    }
}

struct PostItem: Codable {
    let id: String
    var brand: String
    var product: String
    var color: String
    var size: String
}

struct Comment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    var content: String
    var replyToCommentId: String?
    var createdAt: Date
}

struct Conversation: Identifiable, Codable {
    let id: String
    let userId: String
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int
    var isRequest: Bool
    var messageType: MessageType
}

enum MessageType: String, Codable {
    case text
    case image
    case voice
    case call
    case missedCall
}

struct Message: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    var content: String
    var type: MessageType
    var duration: TimeInterval?
    var isRead: Bool
    var createdAt: Date
}

struct BlockedUser: Codable {
    let userId: String
    let blockedAt: Date
}

struct Report: Codable {
    let id: String
    let targetUserId: String
    let targetPostId: String?
    let reason: String
    let source: String
    let createdAt: Date
}

struct IAPProduct {
    let productId: String
    let coins: Int
    let price: Double
    let priceString: String
}
