import Foundation

/// Local seed data used on a fresh install. The seven rows mirror the CSV
/// supplied for the app and intentionally exclude the permission/EULA rows.
final class MockData {
    private struct SeedPost {
        let userName: String
        let avatar: String
        let mediaName: String
        let mediaType: MediaType
        let title: String
        let detail: String
        let locationAndStyle: String
        let top: (product: String, color: String, size: String)
        let bottom: (product: String, color: String, size: String)
        let shoes: (product: String, color: String, size: String)
        let accessory: (product: String, color: String)?
        let comment: String?
    }

    private static let seedPosts: [SeedPost] = [
        SeedPost(
            userName: "Emma Nilsson",
            avatar: "33c3bffeacc40feee3a7d283a62d3b15.jpg",
            mediaName: "649b1222af19c60cb0e1f63d5456ab80.jpg",
            mediaType: .photo,
            title: "Autumn Minimalist Layering: Earth Tone Fit",
            detail: "Sharing this clean, warm autumn fit today. Layering different textures in earth tones creates depth without bulk. Perfect for daily wear.",
            locationAndStyle: "Stockholm • Vibe",
            top: ("Wool Trench Coat", "Camel", "M"),
            bottom: ("Tailored Trousers", "Cream", "S"),
            shoes: ("Boots", "Brown", ""),
            accessory: ("Canvas Tote Bag", "Beige"),
            comment: "Like it!"
        ),
        SeedPost(
            userName: "Lucas Webber",
            avatar: "b2c31163c7092719e5197287964b7826.jpg",
            mediaName: "dca352726806a0cac25a78dbb779da95.jpg",
            mediaType: .photo,
            title: "Street Casual: Relaxed Hoodie Vibe",
            detail: "My go-to weekend look after a busy week. An oversized grey hoodie paired with straight jeans—simple, comfy, and casual.",
            locationAndStyle: "Berlin • Streetwear",
            top: ("Oversized Hoodie", "Heather Grey", "L"),
            bottom: ("Raw Denim Jeans", "Dark Blue", "32"),
            shoes: ("Canvas Low-top Sneakers", "White", ""),
            accessory: nil,
            comment: "Easy daily wear."
        ),
        SeedPost(
            userName: "Elena Rostova",
            avatar: "2cbb08b21b1871bb00dd136c2493baef.jpg",
            mediaName: "no_watermark.mp4",
            mediaType: .video,
            title: "Old Town Stroll: Vintage Black & White",
            detail: "You can never go wrong with black and white. Structured black coat with white wide-leg trousers, simple yet confident.",
            locationAndStyle: "Paris • Vibe",
            top: ("Double-Breasted Blazer", "Black", "S"),
            bottom: ("Wide-Leg Trousers", "Off-White", "S"),
            shoes: ("Pointed Ankle Boots", "Black", ""),
            accessory: ("Retro Sunglasses", "Tortoiseshell"),
            comment: "Love this style!"
        ),
        SeedPost(
            userName: "Mateo Benitez",
            avatar: "ca710b0c5ddb38ea504467bd31840a77.jpg",
            mediaName: "2164c1ea8074b475ffc9bee4f4d188fd.jpg",
            mediaType: .photo,
            title: "Sunlit & Linen: Late Summer Retro",
            detail: "Enjoying the late summer sun in a breathable linen shirt. Paired with beige chinos for a clean, light afternoon vibe.",
            locationAndStyle: "Barcelona • Cityboy",
            top: ("Long Sleeve Linen Shirt", "Off-White", "M"),
            bottom: ("Straight Chino Pants", "Beige", "31"),
            shoes: ("Suede Slip-on Shoes", "", ""),
            accessory: ("Minimalist Leather Watch", "Brown"),
            comment: nil
        ),
        SeedPost(
            userName: "Sophie Laurent",
            avatar: "095a25404c342c2db4dae804f070f0ac.jpg",
            mediaName: "5d8c0a29ce5dcb87b01882cddd0235fb.jpg",
            mediaType: .photo,
            title: "Cozy Knitwear: French Daily Vibe",
            detail: "A soft cream cardigan is all I need on a cool afternoon. Paired with flared denim for an effortless french aesthetic.",
            locationAndStyle: "Lyon • Streetwear",
            top: ("Chunky Knit Cardigan", "Cream", "S"),
            bottom: ("Flared High-Waist Jeans", "Light Blue", "XS"),
            shoes: ("Leather Ballerina Flats", "White", ""),
            accessory: ("Pendant Gold Necklace", "Gold"),
            comment: nil
        ),
        SeedPost(
            userName: "Oliver Jansen",
            avatar: "65db1953fe67a1ce34fba42dd1deb270.jpg",
            mediaName: "ff742b682a4b5968dc1fd5248bcd3611.jpg",
            mediaType: .photo,
            title: "Urban Outdoor: Gorpcore Functional Fit",
            detail: "Blending outdoor functionality into daily wear. Forest green windbreaker with cargo pants—weatherproof and sharp.",
            locationAndStyle: "Amsterdam • Gorpcore",
            top: ("Waterproof Windbreaker", "Forest Green", "L"),
            bottom: ("Multi-Pocket Cargo Pants", "Charcoal", "33"),
            shoes: ("Trail Running Shoes", "White", ""),
            accessory: nil,
            comment: nil
        ),
        SeedPost(
            userName: "Dora Green",
            avatar: "ff0ea8aefa2fdd09d52fa3d04dacba4e.jpg",
            mediaName: "ba0dc271bc12710be51dabff5147d224.jpg",
            mediaType: .photo,
            title: "Y2K Vibe: Cropped Baby Tee & Metallic Accents",
            detail: "Stepping back into the 2000s! Fitted cropped graphic baby tee paired with low-rise relaxed denim and futuristic shades. Bold and energetic.",
            locationAndStyle: "Rome • Y2K",
            top: ("Fitted Cropped Graphic Baby Tee", "Pink", "S"),
            bottom: ("Low-rise Relaxed Denim", "", "S"),
            shoes: ("Platform Chunky Sneakers", "White", ""),
            accessory: ("Silver Shoulder Bag", ""),
            comment: "Super chic look!"
        )
    ]

    private static let seedUserIDs = (0..<7).map { "csv_user_\($0 + 1)" }
    static let testUserID = "test_user_123"

    static var csvSeedUserIDs: Set<String> {
        Set(seedUserIDs + [testUserID])
    }

    static func generateUsers() -> [User] {
        var users = seedPosts.enumerated().map { index, seed in
            let location = splitLocationAndStyle(seed.locationAndStyle).location
            let slug = seed.userName.lowercased().replacingOccurrences(of: " ", with: ".")
            return User(
                id: seedUserIDs[index],
                email: "\(slug)@vixly.local",
                password: "12345678",
                name: seed.userName,
                avatar: seed.avatar,
                bio: "",
                birthday: "",
                location: location,
                gender: "",
                postsCount: 1,
                followersCount: 0,
                followingCount: index < 2 ? 1 : 0,
                coins: 0,
                isDeleted: false,
                createdAt: seedDate(offset: -index, hour: 12)
            )
        }
        users.append(generateTestUser())
        return users
    }

    static func generateTestUser() -> User {
        User(
            id: testUserID,
            email: "123@gmail.com",
            password: "12345678",
            name: "Mike",
            avatar: "",
            bio: "",
            birthday: "",
            location: "",
            gender: "",
            postsCount: 0,
            followersCount: 2,
            followingCount: 0,
            coins: 0,
            isDeleted: false,
            createdAt: seedDate(offset: 0, hour: 12)
        )
    }

    static func generateFollowingRelationships() -> [String: Set<String>] {
        [
            seedUserIDs[0]: [testUserID],
            seedUserIDs[1]: [testUserID]
        ]
    }

    static func generatePosts() -> [Post] {
        seedPosts.enumerated().map { index, seed in
            let locationAndStyle = splitLocationAndStyle(seed.locationAndStyle)
            let commentCount = seed.comment == nil ? 0 : 1
            let itemPrefix = "csv_item_\(index + 1)"
            let items = PostItems(
                tops: [makeItem(id: "\(itemPrefix)_top", value: seed.top)],
                bottoms: [makeItem(id: "\(itemPrefix)_bottom", value: seed.bottom)],
                shoes: [makeItem(id: "\(itemPrefix)_shoes", value: seed.shoes)],
                accessories: seed.accessory.map {
                    [PostItem(id: "\(itemPrefix)_accessory", brand: "", product: $0.product, color: $0.color, size: "")]
                } ?? []
            )
            let postDate = seedDate(offset: -index, hour: 12)
            return Post(
                id: "csv_post_\(index + 1)",
                userId: seedUserIDs[index],
                media: [PostMedia(id: "csv_media_\(index + 1)", type: seed.mediaType, url: seed.mediaName, isCover: true)],
                caption: "\(seed.title)\n\(seed.detail)",
                styleTags: locationAndStyle.styles,
                primaryStyleTag: locationAndStyle.styles.first,
                location: locationAndStyle.location,
                items: items,
                likesCount: 0,
                commentsCount: commentCount,
                savesCount: 0,
                isLiked: false,
                isSaved: false,
                isTopFit: false,
                isPublic: true,
                isItemUnlocked: false,
                date: postDate,
                createdAt: postDate
            )
        }
    }

    static func generateComments() -> [Comment] {
        seedPosts.enumerated().compactMap { index, seed in
            guard let content = seed.comment else { return nil }
            // The commenter is always another seeded user, cycling to the next row.
            let commenterIndex = (index + 1) % seedPosts.count
            return Comment(
                id: "csv_comment_\(index + 1)",
                postId: "csv_post_\(index + 1)",
                userId: seedUserIDs[commenterIndex],
                content: content,
                replyToCommentId: nil,
                createdAt: seedDate(offset: -index, hour: 13)
            )
        }
    }

    static func generateAIMessages() -> [Message] {
        [
            Message(
                id: "ai_msg_1",
                conversationId: "ai_stylist",
                senderId: "ai_stylist",
                content: "The proportions look really clean.",
                type: .text,
                duration: nil,
                isRead: true,
                createdAt: Date()
            )
        ]
    }

    private static func makeItem(id: String, value: (product: String, color: String, size: String)) -> PostItem {
        PostItem(id: id, brand: "", product: value.product, color: value.color, size: value.size)
    }

    private static func splitLocationAndStyle(_ value: String) -> (location: String, styles: [String]) {
        let parts = value.components(separatedBy: "•").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let location = parts.first ?? value
        let styles = Array(parts.dropFirst().filter { !$0.isEmpty })
        return (location, styles)
    }

    private static func seedDate(offset: Int, hour: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: offset, to: base) ?? base
        return calendar.date(byAdding: .hour, value: hour, to: day) ?? day
    }
}
