import Foundation
import UIKit

enum AppError: Error {
    case message(String)
    var localizedDescription: String {
        switch self {
        case .message(let msg): return msg
        }
    }
}

class DataRepository {
    static let shared = DataRepository()
    
    private init() {}
    
    private var users: [User] = []
    private var posts: [Post] = []
    private var comments: [Comment] = []
    private var conversations: [Conversation] = []
    private var messages: [String: [Message]] = [:]
    private var blockedUsers: [BlockedUser] = []
    private var reports: [Report] = []
    private var aiMessages: [Message] = []
    
    private var currentUserId: String?
    private var followingUserIds: Set<String> = []
    private var unlockedPostItemIds: Set<String> = []
    private var avatarImageDataByUserId: [String: Data] = [:]
    private lazy var systemDefaultAvatarImage: UIImage = {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            AppTheme.backgroundColor.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

            guard let symbol = UIImage(
                systemName: "person",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .regular)
            ) else { return }

            let tintedSymbol = symbol.withTintColor(UIColor(hex: "#2A6878"), renderingMode: .alwaysOriginal)
            let symbolSize = tintedSymbol.size
            let symbolRect = CGRect(
                x: (size.width - symbolSize.width) / 2,
                y: (size.height - symbolSize.height) / 2,
                width: symbolSize.width,
                height: symbolSize.height
            )
            tintedSymbol.draw(in: symbolRect)
        }
    }()
    private var followingUserIdsByUserId: [String: Set<String>] = [:]
    private var likedPostIds: Set<String> = []
    private var savedPostIds: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let csvSeedVersionKey = "VIXLY_CSV_SEED_VERSION"
    private let csvSeedVersion = 2
    
    func initialize() {
        loadUsers()
        loadAvatarImages()
        loadPosts()
        loadComments()
        loadReports()
        loadRelationshipMap()
        installCSVSeedIfNeeded()
        
        if let savedUserId = userDefaults.string(forKey: "CURRENT_USER_ID") {
            if let user = users.first(where: { $0.id == savedUserId && !$0.isDeleted }) {
                currentUserId = user.id
                loadRelationships()
                loadConversations()
                loadUnlockedPosts()
                loadInteractions()
                loadBlockedUsers()
            }
        } else {
            for index in posts.indices {
                posts[index].isLiked = false
                posts[index].isSaved = false
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentUserId != nil
    }
    
    var isGuest: Bool {
        return currentUserId == nil
    }
    
    var currentUser: User? {
        guard let userId = currentUserId else { return nil }
        return users.first(where: { $0.id == userId })
    }

    func avatarImage(for user: User) -> UIImage? {
        if let data = avatarImageDataByUserId[user.id], let image = UIImage(data: data) {
            return image
        }
        if !user.avatar.isEmpty, let image = UIImage(named: user.avatar) {
            return image
        }
        return systemDefaultAvatarImage
    }

    func defaultAvatarImage() -> UIImage {
        return systemDefaultAvatarImage
    }

    func currentUserAvatarImage() -> UIImage? {
        guard let user = currentUser else { return nil }
        return avatarImage(for: user)
    }

    func setCurrentUserAvatarImage(_ image: UIImage?) {
        guard let userId = currentUserId else { return }
        if let image, let data = image.jpegData(compressionQuality: 0.9) {
            avatarImageDataByUserId[userId] = data
        } else {
            avatarImageDataByUserId.removeValue(forKey: userId)
        }
        saveAvatarImages()
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }
    
    func getUser(byId id: String) -> User? {
        return users.first(where: { $0.id == id })
    }
    
    func isUserBlocked(userId: String) -> Bool {
        return blockedUsers.contains(where: { $0.userId == userId })
    }
    
    func isFollowing(userId: String) -> Bool {
        return followingUserIds.contains(userId)
    }
    
    func isMutualFollowing(userId: String) -> Bool {
        guard let currentUserId else { return false }
        return isFollowing(userId: userId) && (followingUserIdsByUserId[userId] ?? []).contains(currentUserId)
    }
    
    func getFilteredPosts() -> [Post] {
        return posts.filter { !isUserBlocked(userId: $0.userId) }
    }
    
    func getExplorePosts(type: String) -> [Post] {
        var filtered = getFilteredPosts()
        
        switch type {
        case "Following":
            filtered = filtered.filter { followingUserIds.contains($0.userId) }
        case "Top Fits":
            filtered = filtered.filter { $0.isTopFit }.sorted { $0.createdAt > $1.createdAt }
        default:
            filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        }
        
        return filtered
    }
    
    func getCreatorPosts(page: Int = 0, pageSize: Int = 10) -> [Post] {
        let all = getFilteredPosts().sorted { $0.createdAt > $1.createdAt }
        let startIndex = page * pageSize
        guard startIndex < all.count else { return [] }
        let endIndex = min(startIndex + pageSize, all.count)
        return Array(all[startIndex..<endIndex])
    }
    
    func getPost(byId id: String) -> Post? {
        return posts.first(where: { $0.id == id })
    }
    
    func getComments(for postId: String) -> [Comment] {
        return comments.filter { $0.postId == postId && !isUserBlocked(userId: $0.userId) }
    }
    
    func getUserPosts(userId: String) -> [Post] {
        return posts.filter { $0.userId == userId }
    }

    func getFollowers(userId: String) -> [User] {
        let followerIds = followingUserIdsByUserId.compactMap { ownerId, following in
            following.contains(userId) ? ownerId : nil
        }
        return followerIds.compactMap { getUser(byId: $0) }.filter { !isUserBlocked(userId: $0.id) }
    }

    func getFollowing(userId: String) -> [User] {
        let ids = followingUserIdsByUserId[userId] ?? (userId == currentUserId ? followingUserIds : [])
        return ids.compactMap { getUser(byId: $0) }.filter { !isUserBlocked(userId: $0.id) }
    }
    
    func getSavedPosts() -> [Post] {
        return getFilteredPosts().filter { $0.isSaved }
    }
    
    func getConversations(includeRequests: Bool = false) -> [Conversation] {
        return conversations
            .filter { $0.isRequest == includeRequests && !isUserBlocked(userId: $0.userId) }
            .sorted { $0.lastMessageTime > $1.lastMessageTime }
    }
    
    func getConversation(with userId: String) -> Conversation? {
        return conversations.first { $0.userId == userId }
    }

    func markConversationRead(userId: String) {
        if let index = conversations.firstIndex(where: { $0.userId == userId }) {
            conversations[index].unreadCount = 0
            saveConversations()
            NotificationCenter.default.post(name: .messageSent, object: nil)
        }
    }
    
    func getMessages(for conversationId: String) -> [Message] {
        return messages[conversationId] ?? []
    }
    
    func getAIMessages() -> [Message] {
        return aiMessages
    }
    
    func getBlockedUsers() -> [BlockedUser] {
        return blockedUsers
    }
    
    func getReports() -> [Report] {
        return reports
    }
    
    func isPostItemUnlocked(postId: String) -> Bool {
        return unlockedPostItemIds.contains(postId)
    }
    
    func login(email: String, password: String) -> Result<User, AppError> {
        let deletedAccounts = userDefaults.stringArray(forKey: "DELETED_ACCOUNTS") ?? []
        
        if deletedAccounts.contains(email.lowercased()) {
            return .failure(.message("This account has been deleted and cannot be used."))
        }
        
        guard let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            return .failure(.message("Account not found. Please check your email or sign up."))
        }
        
        if user.isDeleted {
            return .failure(.message("This account has been deleted and cannot be used."))
        }
        
        guard let storedPassword = user.password, storedPassword == password else {
            return .failure(.message("Incorrect password. Please try again."))
        }
        
        setupLoggedInUser(user: user)
        return .success(user)
    }
    
    func signup(email: String, password: String, confirmPassword: String) -> Result<User, AppError> {
        // 简单邮箱校验
        let emailRegex = ".+@.+\\..+"
        if email.isEmpty || !(email.range(of: emailRegex, options: .regularExpression) != nil) {
            return .failure(.message("Please enter a valid email address."))
        }
        
        if password.count < 8 {
            return .failure(.message("Password must be at least 8 characters long."))
        }
        
        if password != confirmPassword {
            return .failure(.message("Passwords do not match. Please try again."))
        }
        
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return .failure(.message("An account with this email already exists."))
        }
        
        let newUser = User(
            id: "user_\(UUID().uuidString.prefix(8))",
            email: email,
            password: password,
            name: "",
            avatar: "avatar_default",
            bio: "",
            birthday: "",
            location: "",
            gender: "",
            postsCount: 0,
            followersCount: 0,
            followingCount: 0,
            coins: 0,
            isDeleted: false,
            createdAt: Date()
        )
        
        users.append(newUser)
        saveUsers()
        currentUserId = newUser.id
        saveCurrentUser()
        
        return .success(newUser)
    }
    
    func completeProfile(name: String, avatar: String, birthday: String, location: String, gender: String) {
        guard let userId = currentUserId,
              let index = users.firstIndex(where: { $0.id == userId }) else { return }
        
        users[index].name = name
        users[index].avatar = avatar
        users[index].birthday = birthday
        users[index].location = location
        users[index].gender = gender
        
        loadRelationships()
        loadConversations()
        loadUnlockedPosts()
        loadInteractions()
        loadBlockedUsers()
        saveCurrentUser()
        saveUsers()
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }
    
    func logout() {
        currentUserId = nil
        followingUserIds = []
        unlockedPostItemIds = []
        likedPostIds = []
        savedPostIds = []
        conversations = []
        messages = [:]
        aiMessages = []
        blockedUsers = []
        for index in posts.indices {
            posts[index].isLiked = false
            posts[index].isSaved = false
        }
        userDefaults.removeObject(forKey: "CURRENT_USER_ID")
    }
    
    func deleteAccount() {
        guard let user = currentUser else { return }
        
        var deletedAccounts = userDefaults.stringArray(forKey: "DELETED_ACCOUNTS") ?? []
        deletedAccounts.append(user.email)
        userDefaults.set(deletedAccounts, forKey: "DELETED_ACCOUNTS")
        
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isDeleted = true
        }
        saveUsers()
        
        logout()
    }
    
    func updateProfile(name: String, bio: String, avatar: String?) {
        guard let userId = currentUserId,
              let index = users.firstIndex(where: { $0.id == userId }) else { return }
        
        users[index].name = name
        users[index].bio = bio
        if let avatar = avatar {
            users[index].avatar = avatar
        }
        saveUsers()
        
        NotificationCenter.default.post(name: .userProfileUpdated, object: nil)
    }
    
    func toggleFollow(userId: String) -> Bool {
        guard let currentUserId, currentUserId != userId else { return false }
        if followingUserIds.contains(userId) {
            followingUserIds.remove(userId)
            if let index = users.firstIndex(where: { $0.id == userId }) {
                users[index].followersCount = max(0, users[index].followersCount - 1)
            }
            if let currentIdx = users.firstIndex(where: { $0.id == currentUserId }) {
                users[currentIdx].followingCount = max(0, users[currentIdx].followingCount - 1)
            }
            followingUserIdsByUserId[currentUserId] = followingUserIds
            saveRelationships()
            saveUsers()
            NotificationCenter.default.post(name: .followStatusChanged, object: nil, userInfo: ["userId": userId, "isFollowing": false])
            return false
        } else {
            followingUserIds.insert(userId)
            if let index = users.firstIndex(where: { $0.id == userId }) {
                users[index].followersCount += 1
            }
            if let currentIdx = users.firstIndex(where: { $0.id == currentUserId }) {
                users[currentIdx].followingCount += 1
            }
            followingUserIdsByUserId[currentUserId] = followingUserIds
            saveRelationships()
            saveUsers()
            NotificationCenter.default.post(name: .followStatusChanged, object: nil, userInfo: ["userId": userId, "isFollowing": true])
            return true
        }
    }
    
    func toggleLike(postId: String) -> Bool {
        guard let currentUserId, let index = posts.firstIndex(where: { $0.id == postId }) else { return false }
        
        if posts[index].isLiked {
            posts[index].isLiked = false
            posts[index].likesCount = max(0, posts[index].likesCount - 1)
            likedPostIds.remove(postId)
        } else {
            posts[index].isLiked = true
            posts[index].likesCount += 1
            likedPostIds.insert(postId)
        }
        saveInteractions(for: currentUserId)
        savePosts()
        NotificationCenter.default.post(name: .postUpdated, object: nil, userInfo: ["postId": postId])
        return posts[index].isLiked
    }
    
    func toggleSave(postId: String) -> Bool {
        guard let currentUserId, let index = posts.firstIndex(where: { $0.id == postId }) else { return false }
        
        if posts[index].isSaved {
            posts[index].isSaved = false
            posts[index].savesCount = max(0, posts[index].savesCount - 1)
            savedPostIds.remove(postId)
        } else {
            posts[index].isSaved = true
            posts[index].savesCount += 1
            savedPostIds.insert(postId)
        }
        saveInteractions(for: currentUserId)
        savePosts()
        NotificationCenter.default.post(name: .postUpdated, object: nil, userInfo: ["postId": postId])
        return posts[index].isSaved
    }
    
    func addComment(postId: String, content: String) {
        guard let userId = currentUserId,
              let postIndex = posts.firstIndex(where: { $0.id == postId }) else { return }
        
        let comment = Comment(
            id: "comment_\(UUID().uuidString.prefix(8))",
            postId: postId,
            userId: userId,
            content: content,
            replyToCommentId: nil,
            createdAt: Date()
        )
        
        comments.append(comment)
        posts[postIndex].commentsCount += 1
        saveComments()
        savePosts()
        NotificationCenter.default.post(name: .commentAdded, object: nil, userInfo: ["postId": postId])
    }
    
    func blockUser(userId: String) {
        if !blockedUsers.contains(where: { $0.userId == userId }) {
            let blocked = BlockedUser(userId: userId, blockedAt: Date())
            blockedUsers.append(blocked)
            saveBlockedUsers()
            
            if isFollowing(userId: userId) {
                _ = toggleFollow(userId: userId)
            }
            
            NotificationCenter.default.post(name: .userBlocked, object: nil, userInfo: ["userId": userId])
        }
    }
    
    func unblockUser(userId: String) {
        blockedUsers.removeAll { $0.userId == userId }
        saveBlockedUsers()
        NotificationCenter.default.post(name: .userUnblocked, object: nil, userInfo: ["userId": userId])
    }
    
    func reportUser(userId: String, postId: String?, reason: String, source: String) {
        let report = Report(
            id: "report_\(UUID().uuidString.prefix(8))",
            targetUserId: userId,
            targetPostId: postId,
            reason: reason,
            source: source,
            createdAt: Date()
        )
        reports.append(report)
        saveReports()
    }
    
    func sendMessage(to userId: String, content: String, type: MessageType = .text, duration: TimeInterval? = nil) {
        guard let currentUserId = currentUserId else { return }
        
        let conversationId = "conv_\(userId)"
        
        if messages[conversationId] == nil {
            messages[conversationId] = []
        }
        
        let message = Message(
            id: "msg_\(UUID().uuidString.prefix(8))",
            conversationId: conversationId,
            senderId: currentUserId,
            content: content,
            type: type,
            duration: duration,
            isRead: false,
            createdAt: Date()
        )
        
        messages[conversationId]?.insert(message, at: 0)

        let conversationPreview: String
        switch type {
        case .image: conversationPreview = "Photo"
        case .voice: conversationPreview = "Voice message"
        default: conversationPreview = content
        }
        
        if let convIndex = conversations.firstIndex(where: { $0.userId == userId }) {
            conversations[convIndex].lastMessage = conversationPreview
            conversations[convIndex].lastMessageTime = Date()
            conversations[convIndex].messageType = type
        } else {
            let newConv = Conversation(
                id: conversationId,
                userId: userId,
                lastMessage: conversationPreview,
                lastMessageTime: Date(),
                unreadCount: 0,
                isRequest: false,
                messageType: type
            )
            conversations.append(newConv)
        }
        saveConversations()
        saveMessages()
        NotificationCenter.default.post(name: .messageSent, object: nil, userInfo: ["userId": userId])
    }
    
    func sendAIMessage(content: String) {
        guard let currentUserId = currentUserId else { return }
        
        let userMessage = Message(
            id: "msg_ai_\(UUID().uuidString.prefix(8))",
            conversationId: "ai_stylist",
            senderId: currentUserId,
            content: content,
            type: .text,
            duration: nil,
            isRead: true,
            createdAt: Date()
        )
        aiMessages.insert(userMessage, at: 0)
        saveAIMessages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let aiMessage = Message(
                id: "msg_ai_\(UUID().uuidString.prefix(8))",
                conversationId: "ai_stylist",
                senderId: "ai_stylist",
                content: AIStylistResponseLibrary.response(for: content),
                type: .text,
                duration: nil,
                isRead: true,
                createdAt: Date()
            )
            self.aiMessages.insert(aiMessage, at: 0)
            self.saveAIMessages()
            NotificationCenter.default.post(name: .aiMessageReceived, object: nil)
        }
    }
    
    func consumeCoins(amount: Int) -> Bool {
        guard let userId = currentUserId,
              let index = users.firstIndex(where: { $0.id == userId }),
              users[index].coins >= amount else {
            return false
        }
        
        users[index].coins -= amount
        saveUsers()
        NotificationCenter.default.post(name: .coinsUpdated, object: nil)
        return true
    }
    
    func addCoins(amount: Int) {
        guard let userId = currentUserId,
              let index = users.firstIndex(where: { $0.id == userId }) else { return }
        
        users[index].coins += amount
        saveUsers()
        NotificationCenter.default.post(name: .coinsUpdated, object: nil)
    }
    
    func unlockPostItems(postId: String) {
        unlockedPostItemIds.insert(postId)
        saveUnlockedPosts()
        
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isItemUnlocked = true
            savePosts()
        }
        
        NotificationCenter.default.post(name: .postUpdated, object: nil, userInfo: ["postId": postId])
    }
    
    func promotePost(postId: String) -> Bool {
        if consumeCoins(amount: 300) {
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].isTopFit = true
                savePosts()
                NotificationCenter.default.post(name: .postUpdated, object: nil, userInfo: ["postId": postId])
            }
            return true
        }
        return false
    }
    
    func createPost(media: [PostMedia], items: PostItems, caption: String, styleTags: [String], location: String) -> Post {
        let post = Post(
            id: "post_\(UUID().uuidString.prefix(8))",
            userId: currentUserId ?? "",
            media: media,
            caption: caption,
            styleTags: styleTags,
            primaryStyleTag: styleTags.first,
            location: location,
            items: items,
            likesCount: 0,
            commentsCount: 0,
            savesCount: 0,
            isLiked: false,
            isSaved: false,
            isTopFit: false,
            isPublic: true,
            isItemUnlocked: true,
            date: Date(),
            createdAt: Date()
        )
        
        posts.insert(post, at: 0)
        savePosts()
        
        if let userId = currentUserId,
           let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].postsCount += 1
            saveUsers()
        }
        
        NotificationCenter.default.post(name: .postCreated, object: nil, userInfo: ["postId": post.id])
        return post
    }
    
    func resetPassword(email: String, newPassword: String, confirmPassword: String) -> Result<Void, AppError> {
        guard let index = users.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) else {
            return .failure(.message("No account found with this email."))
        }
        
        if newPassword.count < 8 {
            return .failure(.message("Password must be at least 8 characters long."))
        }
        
        if newPassword != confirmPassword {
            return .failure(.message("Passwords do not match."))
        }
        
        users[index].password = newPassword
        saveUsers()
        
        return .success(())
    }
    
    func hasOOTDForToday() -> Bool {
        return getPost(for: Date()) != nil
    }

    func hasOOTD(for date: Date) -> Bool {
        return getPost(for: date) != nil
    }

    func getPost(for date: Date) -> Post? {
        guard let userId = currentUserId else { return nil }
        let calendar = Calendar.current
        return posts
            .filter { post in
            post.userId == userId && calendar.isDate(post.date, inSameDayAs: date)
            }
            .max(by: { $0.createdAt < $1.createdAt })
    }
    
    func hasRecordForDate(_ date: Date) -> Bool {
        guard let userId = currentUserId else { return false }
        let calendar = Calendar.current
        return posts.contains { post in
            post.userId == userId && calendar.isDate(post.date, inSameDayAs: date)
        }
    }
    
    func getTodayPost() -> Post? {
        return getPost(for: Date())
    }
    
    func getStreakDays() -> Int {
        guard let userId = currentUserId else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let hasPost = posts.contains { post in
                post.userId == userId && calendar.isDate(post.date, inSameDayAs: currentDate)
            }
            
            if hasPost {
                streak += 1
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDay
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getPostsForMonth(year: Int, month: Int) -> [Date: Post] {
        guard let userId = currentUserId else { return [:] }
        let calendar = Calendar.current
        var result: [Date: Post] = [:]
        
        for post in posts where post.userId == userId {
            let components = calendar.dateComponents([.year, .month, .day], from: post.date)
            if components.year == year && components.month == month, let day = components.day,
               let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                if let existing = result[date] {
                    result[date] = existing.createdAt < post.createdAt ? post : existing
                } else {
                    result[date] = post
                }
            }
        }
        
        return result
    }

    private func installCSVSeedIfNeeded() {
        let legacyUserIDs = Set((1...6).map { "user_\($0)" })
        let legacyPostIDs = Set((1...12).map { "post_\($0)" })
        let hasLegacySeed = users.contains { legacyUserIDs.contains($0.id) }
            || posts.contains { legacyPostIDs.contains($0.id) }
        let storedSeedVersion = userDefaults.integer(forKey: csvSeedVersionKey)

        if users.isEmpty || hasLegacySeed {
            clearLegacySeedData(userIDs: legacyUserIDs)
            users = MockData.generateUsers()
            posts = MockData.generatePosts()
            comments = MockData.generateComments()
            followingUserIdsByUserId = MockData.generateFollowingRelationships()
            conversations = []
            messages = [:]
            aiMessages = []

            saveUsers()
            savePosts()
            saveComments()
            saveRelationshipMap()
            userDefaults.set(csvSeedVersion, forKey: csvSeedVersionKey)
            return
        }

        guard storedSeedVersion < csvSeedVersion else { return }

        if !users.contains(where: { $0.id == MockData.testUserID }) {
            users.append(MockData.generateTestUser())
        }
        installDefaultTestFollowers()
        saveUsers()
        saveRelationshipMap()
        userDefaults.set(csvSeedVersion, forKey: csvSeedVersionKey)
    }

    private func installDefaultTestFollowers() {
        let defaults = MockData.generateFollowingRelationships()
        for (followerID, targetIDs) in defaults {
            var existingTargets = followingUserIdsByUserId[followerID] ?? []
            let insertedTargets = targetIDs.subtracting(existingTargets)
            existingTargets.formUnion(targetIDs)
            followingUserIdsByUserId[followerID] = existingTargets

            if !insertedTargets.isEmpty,
               let followerIndex = users.firstIndex(where: { $0.id == followerID }) {
                users[followerIndex].followingCount += insertedTargets.count
            }
        }

        let followerCount = followingUserIdsByUserId.values.filter { $0.contains(MockData.testUserID) }.count
        if let testUserIndex = users.firstIndex(where: { $0.id == MockData.testUserID }) {
            users[testUserIndex].followersCount = followerCount
        }
    }

    private func clearLegacySeedData(userIDs: Set<String>) {
        let legacyPostIDs = Set((1...12).map { "post_\($0)" })
        let legacyCommentIDs = Set((0..<18).map { "comment_post\(($0 / 3))_\(($0 % 3))" })

        users.removeAll { userIDs.contains($0.id) }
        posts.removeAll { legacyPostIDs.contains($0.id) }
        comments.removeAll { legacyCommentIDs.contains($0.id) || legacyPostIDs.contains($0.postId) }
        reports = []
        avatarImageDataByUserId = [:]
        followingUserIds = []
        followingUserIdsByUserId = [:]
        likedPostIds = []
        savedPostIds = []
        blockedUsers = []
        unlockedPostItemIds = []

        userDefaults.removeObject(forKey: "FOLLOWING_IDS_BY_USER")
        userDefaults.removeObject(forKey: "REPORTS_KEY")
        userDefaults.removeObject(forKey: "USER_AVATAR_IMAGES_KEY")
        for userID in userIDs {
            userDefaults.removeObject(forKey: "CONVERSATIONS_\(userID)")
            userDefaults.removeObject(forKey: "MESSAGES_\(userID)")
            userDefaults.removeObject(forKey: "AI_MESSAGES_\(userID)")
            userDefaults.removeObject(forKey: "BLOCKED_USER_IDS_\(userID)")
            userDefaults.removeObject(forKey: "UNLOCKED_POST_IDS_\(userID)")
            userDefaults.removeObject(forKey: "LIKED_POST_IDS_\(userID)")
            userDefaults.removeObject(forKey: "SAVED_POST_IDS_\(userID)")
        }

        if let savedUserID = userDefaults.string(forKey: "CURRENT_USER_ID"), userIDs.contains(savedUserID) {
            userDefaults.removeObject(forKey: "CURRENT_USER_ID")
        }
    }
    
    private func setupLoggedInUser(user: User) {
        currentUserId = user.id
        loadRelationships()
        loadConversations()
        loadUnlockedPosts()
        loadInteractions()
        loadBlockedUsers()
        saveCurrentUser()
    }
    
    private func saveCurrentUser() {
        if let userId = currentUserId {
            userDefaults.set(userId, forKey: "CURRENT_USER_ID")
        }
    }
    
    private func saveRelationships() {
        guard let currentUserId else { return }
        followingUserIdsByUserId[currentUserId] = followingUserIds
        saveRelationshipMap()
    }

    private func saveRelationshipMap() {
        let encoded = followingUserIdsByUserId.mapValues { Array($0) }
        userDefaults.set(encoded, forKey: "FOLLOWING_IDS_BY_USER")
    }

    private func loadRelationshipMap() {
        if let stored = userDefaults.dictionary(forKey: "FOLLOWING_IDS_BY_USER") as? [String: [String]] {
            followingUserIdsByUserId = stored.mapValues { Set($0) }
        }
    }
    private func loadRelationships() {
        loadRelationshipMap()
        if let currentUserId {
            if let ids = followingUserIdsByUserId[currentUserId] {
                followingUserIds = ids
            } else {
                followingUserIds = []
            }
        }
    }
    
    private func saveBlockedUsers() {
        let ids = blockedUsers.map { $0.userId }
        guard let currentUserId else { return }
        userDefaults.set(ids, forKey: "BLOCKED_USER_IDS_\(currentUserId)")
    }
    
    private func loadBlockedUsers() {
        guard let currentUserId else { blockedUsers = []; return }
        blockedUsers = userDefaults.stringArray(forKey: "BLOCKED_USER_IDS_\(currentUserId)")?
            .map { BlockedUser(userId: $0, blockedAt: Date()) } ?? []
    }
    
    private func saveReports() {
        if let data = try? PropertyListEncoder().encode(reports) {
            userDefaults.set(data, forKey: "REPORTS_KEY")
        }
    }
    
    private func loadReports() {
        if let data = userDefaults.data(forKey: "REPORTS_KEY"),
           let decoded = try? PropertyListDecoder().decode([Report].self, from: data) {
            reports = decoded
        }
    }
    
    private func saveUsers() {
        if let data = try? PropertyListEncoder().encode(users) {
            userDefaults.set(data, forKey: "USERS_KEY")
        }
    }
    
    private func loadUsers() {
        if let data = userDefaults.data(forKey: "USERS_KEY"),
           let decoded = try? PropertyListDecoder().decode([User].self, from: data) {
            users = decoded
        }
    }

    private func saveAvatarImages() {
        if let data = try? PropertyListEncoder().encode(avatarImageDataByUserId) {
            userDefaults.set(data, forKey: "USER_AVATAR_IMAGES_KEY")
        }
    }

    private func loadAvatarImages() {
        if let data = userDefaults.data(forKey: "USER_AVATAR_IMAGES_KEY"),
           let decoded = try? PropertyListDecoder().decode([String: Data].self, from: data) {
            avatarImageDataByUserId = decoded
        }
    }
    
    private func saveUnlockedPosts() {
        guard let currentUserId else { return }
        userDefaults.set(Array(unlockedPostItemIds), forKey: "UNLOCKED_POST_IDS_\(currentUserId)")
    }
    
    private func loadUnlockedPosts() {
        guard let currentUserId else { return }
        if let ids = userDefaults.stringArray(forKey: "UNLOCKED_POST_IDS_\(currentUserId)") {
            unlockedPostItemIds = Set(ids)
            for postId in ids {
                if let index = posts.firstIndex(where: { $0.id == postId }) {
                    posts[index].isItemUnlocked = true
                }
            }
        }
    }
    
    private func loadConversations() {
        guard let userId = currentUserId else { return }
        if let data = userDefaults.data(forKey: "CONVERSATIONS_\(userId)"),
           let decoded = try? PropertyListDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        } else {
            conversations = []
        }
        if let data = userDefaults.data(forKey: "MESSAGES_\(userId)"),
           let decoded = try? PropertyListDecoder().decode([String: [Message]].self, from: data) {
            messages = decoded
        } else {
            messages = [:]
        }
        if let data = userDefaults.data(forKey: "AI_MESSAGES_\(userId)"),
           let decoded = try? PropertyListDecoder().decode([Message].self, from: data) {
            aiMessages = decoded
        } else {
            aiMessages = MockData.generateAIMessages()
            saveAIMessages()
        }
    }

    private func savePosts() {
        guard let data = try? PropertyListEncoder().encode(posts) else { return }
        userDefaults.set(data, forKey: "POSTS_DATA")
    }

    private func loadPosts() {
        if let data = userDefaults.data(forKey: "POSTS_DATA"),
           let decoded = try? PropertyListDecoder().decode([Post].self, from: data) {
            posts = decoded
        } else {
            posts = []
        }
    }

    private func saveComments() {
        guard let data = try? PropertyListEncoder().encode(comments) else { return }
        userDefaults.set(data, forKey: "COMMENTS_DATA")
    }

    private func loadComments() {
        if let data = userDefaults.data(forKey: "COMMENTS_DATA"),
           let decoded = try? PropertyListDecoder().decode([Comment].self, from: data) {
            comments = decoded
        } else {
            comments = []
        }
    }

    private func saveMessages() {
        guard let currentUserId,
              let data = try? PropertyListEncoder().encode(messages) else { return }
        userDefaults.set(data, forKey: "MESSAGES_\(currentUserId)")
    }

    private func saveConversations() {
        guard let currentUserId,
              let data = try? PropertyListEncoder().encode(conversations) else { return }
        userDefaults.set(data, forKey: "CONVERSATIONS_\(currentUserId)")
    }

    private func saveAIMessages() {
        guard let currentUserId,
              let data = try? PropertyListEncoder().encode(aiMessages) else { return }
        userDefaults.set(data, forKey: "AI_MESSAGES_\(currentUserId)")
    }

    private func saveInteractions(for userId: String) {
        userDefaults.set(Array(likedPostIds), forKey: "LIKED_POST_IDS_\(userId)")
        userDefaults.set(Array(savedPostIds), forKey: "SAVED_POST_IDS_\(userId)")
    }

    private func loadInteractions() {
        guard let currentUserId else { return }
        likedPostIds = Set(userDefaults.stringArray(forKey: "LIKED_POST_IDS_\(currentUserId)") ?? [])
        savedPostIds = Set(userDefaults.stringArray(forKey: "SAVED_POST_IDS_\(currentUserId)") ?? [])
        for index in posts.indices {
            posts[index].isLiked = likedPostIds.contains(posts[index].id)
            posts[index].isSaved = savedPostIds.contains(posts[index].id)
        }
    }
}

private enum AIStylistResponseLibrary {
    private struct Rule {
        let keywordGroups: [[String]]
        let response: String

        func score(for text: String) -> Int {
            var score = 0
            for group in keywordGroups {
                guard let match = group.first(where: { text.contains($0) }) else { return 0 }
                score += match.contains(" ") || match.contains("-") ? 3 : 1
            }
            return score
        }
    }

    private static let rules: [Rule] = [
        Rule(
            keywordGroups: [["proportion", "silhouette", "look taller", "longer legs"]],
            response: "Balance volume instead of making every piece oversized. Pair one relaxed item with a cleaner fit, define the waist when useful, and keep the hem intentional. A shorter top or a light front tuck can make the legs look longer."
        ),
        Rule(
            keywordGroups: [["wide trousers", "wide pants", "wide-leg", "wide leg"], ["shoe", "sneaker", "boot"]],
            response: "Wide trousers work well with a streamlined shoe that keeps the hem clean. Try low-profile sneakers for a casual look, or a slightly pointed boot to add length. Keep the shoe color close to one tone in the outfit."
        ),
        Rule(
            keywordGroups: [["gorpcore"], ["under $", "under 200", "budget", "affordable", "price"]],
            response: "For a Gorpcore fit under $200, start with one weather-ready shell, relaxed cargo pants, and practical trail sneakers. Spend most on the outer layer, then use simple basics and one compact accessory to stay on budget."
        ),
        Rule(
            keywordGroups: [["color match", "color combination", "match colors", "colours"]],
            response: "Choose one main color, one supporting neutral, and a small accent. Repeating the accent once in a shoe or accessory usually makes the palette feel intentional without looking forced."
        ),
        Rule(
            keywordGroups: [["white shirt", "white top", "white tee"]],
            response: "A white shirt is easy to balance with darker denim, tailored trousers, or a soft neutral skirt. Add texture through knitwear or leather and keep one layer slightly relaxed for a modern shape."
        ),
        Rule(
            keywordGroups: [["capsule wardrobe", "capsule closet"]],
            response: "Build a capsule around a neutral jacket, a clean shirt, two versatile bottoms, one knit layer, and simple sneakers. Keep the colors compatible so each piece can make several outfits."
        ),
        Rule(
            keywordGroups: [["in style", "trend", "trends", "this season"]],
            response: "A reliable current direction is relaxed tailoring mixed with practical layers. Use the trend in one piece, then keep the rest familiar so the outfit still feels like you."
        ),
        Rule(
            keywordGroups: [["layer", "layering", "layers"]],
            response: "Layer from light to structured: a breathable base, a flexible middle layer, and one outer piece. Keep only one layer oversized and let the lengths create a clear order."
        ),
        Rule(
            keywordGroups: [["accessor", "jewelry", "bag", "watch", "sunglasses"]],
            response: "Use accessories to repeat one detail from the outfit. A single visible metal, leather, or color accent is usually enough; keep the scale balanced with the clothing."
        ),
        Rule(
            keywordGroups: [["office", "workwear", "formal", "interview"]],
            response: "For a polished outfit, combine one tailored piece with a simple base and clean shoes. Keep the palette quiet, then add one structured accessory for definition."
        ),
        Rule(
            keywordGroups: [["casual", "weekend", "everyday"]],
            response: "For everyday wear, combine one relaxed item with one sharper piece. Clean sneakers, a useful layer, and a restrained color palette keep the look comfortable but considered."
        ),
        Rule(
            keywordGroups: [["shoe", "sneaker", "boot", "footwear"]],
            response: "Match the shoe to the outfit's visual weight. Chunkier shoes suit relaxed trousers, while a slimmer sneaker or boot works better with a cleaner silhouette."
        ),
        Rule(
            keywordGroups: [["jean", "denim"]],
            response: "Balance denim with a contrasting texture or proportion. A tucked knit, a structured jacket, or a clean shirt can keep the outfit from feeling too uniform."
        ),
        Rule(
            keywordGroups: [["dress", "skirt"]],
            response: "Keep the shape of a dress or skirt as the focus. Add one structured layer and shoes that match its length; avoid stacking too many competing details."
        ),
        Rule(
            keywordGroups: [["shop", "shopping", "buy", "brand", "budget", "price"]],
            response: "Start with the role you need the piece to fill, then compare fabric, fit, and versatility before the label. A flexible neutral usually gives more outfit options than a one-time statement piece."
        ),
        Rule(
            keywordGroups: [["rain", "weather", "cold", "warm"]],
            response: "Dress for the conditions with a breathable base, a protective outer layer, and shoes that can handle the ground. Keep the practical piece visible so it feels intentional."
        ),
        Rule(
            keywordGroups: [["fit", "size", "body type", "body shape"]],
            response: "Prioritize comfort at the shoulders, waist, and seat, then adjust the proportions around that fit. Small changes such as a sleeve roll or a clean tuck can refine the shape without forcing it."
        )
    ]

    private static let fallback = "Share the main piece, its color, the occasion, and the fit you prefer. I can then suggest a balanced combination with clear next steps."

    static func response(for question: String) -> String {
        let normalized = question
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")
        var bestRule: Rule?
        var bestScore = 0
        for rule in rules {
            let score = rule.score(for: normalized)
            if score > bestScore {
                bestScore = score
                bestRule = rule
            }
        }
        return bestRule?.response ?? fallback
    }
}

extension Notification.Name {
    static let userProfileUpdated = Notification.Name("userProfileUpdated")
    static let postUpdated = Notification.Name("postUpdated")
    static let postCreated = Notification.Name("postCreated")
    static let commentAdded = Notification.Name("commentAdded")
    static let followStatusChanged = Notification.Name("followStatusChanged")
    static let userBlocked = Notification.Name("userBlocked")
    static let userUnblocked = Notification.Name("userUnblocked")
    static let messageSent = Notification.Name("messageSent")
    static let aiMessageReceived = Notification.Name("aiMessageReceived")
    static let coinsUpdated = Notification.Name("coinsUpdated")
}
