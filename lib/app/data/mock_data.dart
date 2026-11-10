class MockDatabase {
  static String dailyVerse = "The Lord is my shepherd; I shall not want.";
  static String dailyVerseRef = "Psalm 23:1";
  static String dailyVerseBg =
      "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1400";
  static bool isLiveNow = true;
  static String youtubeVideoId = "Rrvvvc6cFow"; // Default mock ID for testing

  // static List<BookModel> storeBooks = [
  //   BookModel(
  //     id: 1,
  //     title: "The Purpose Driven Life",
  //     author: "Rick Warren",
  //     price: "14.99",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=1000',
  //     category: "Christian Living",
  //     isPurchased: false,
  //   ),
  //   BookModel(
  //     id: 2,
  //     title: "Mere Christianity",
  //     author: "C.S. Lewis",
  //     price: "12.50",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=1000',
  //     category: "Apologetics",
  //     isPurchased: true,
  //   ),
  //   BookModel(
  //     id: 1,
  //     title: "The Purpose Driven Life",
  //     author: "Rick Warren",
  //     price: "14.99",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=1000',
  //     category: "Christian Living",
  //     isPurchased: false,
  //   ),
  //   BookModel(
  //     id: 2,
  //     title: "Mere Christianity",
  //     author: "C.S. Lewis",
  //     price: "12.50",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?q=80&w=1000',
  //     category: "Apologetics",
  //     isPurchased: true,
  //   ),
  //   BookModel(
  //     id: 1,
  //     title: "The Purpose Driven Life",
  //     author: "Rick Warren",
  //     price: "14.99",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1000',
  //     category: "Christian Living",
  //     isPurchased: false,
  //   ),
  //   BookModel(
  //     id: 2,
  //     title: "Mere Christianity",
  //     author: "C.S. Lewis",
  //     price: "12.50",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=1000',
  //     category: "Apologetics",
  //     isPurchased: true,
  //   ),
  // ];

  static List<Map<String, String>> dailyVerseCards = [
    {
      "text": "The Lord is my shepherd; I shall not want.",
      "ref": "Psalm 23:1",
      "bg":
          "https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=1400",
    },
    {
      "text": "I can do all things through Christ who strengthens me.",
      "ref": "Philippians 4:13",
      "bg":
          "https://images.unsplash.com/photo-1470770903676-69b98201ea1c?q=80&w=1400",
    },
    {
      "text": "Be strong and courageous... for the Lord your God is with you.",
      "ref": "Joshua 1:9",
      "bg":
          "https://images.unsplash.com/photo-1452711932549-e7ea7f129399?q=80&w=1400",
    },
    {
      "text": "The joy of the Lord is your strength.",
      "ref": "Nehemiah 8:10",
      "bg":
          "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=1400",
    },
  ];

  // static List<EventModel> allEvents = [
  //   EventModel(
  //     id: 1,
  //     title: "Booking Event For Men",
  //     description:
  //         "The church, originating from the Greek term for assembly, is a community of believers dedicated to gathering for worship, fellowship, and spiritual growth.",
  //     dateTime: DateTime(2025, 1, 15, 19, 0),
  //     location: "addiss abeba",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000', // Concert/Event style
  //     regCount: 24,
  //   ),
  //   EventModel(
  //     id: 2,
  //     title: "Internationa Music Concret",
  //     description: "Global worship and music festival.",
  //     dateTime: DateTime(2025, 1, 18, 18, 30),
  //     location: "addiss abeba",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?auto=format&fit=crop&w=1000&q=80',
  //     regCount: 16,
  //   ),
  //   EventModel(
  //     id: 3,
  //     title: "Youth Worship Night",
  //     description: "Join us for a night of praise.",
  //     dateTime: DateTime(2025, 1, 22, 20, 0),
  //     location: "addiss abeba",
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=1000',
  //     regCount: 150,
  //     isFull: true,
  //   ),
  // ];

  // New sermons list added here
  // static List<SermonModel> sermons = [
  //   SermonModel(
  //     id: '1',
  //     slug: 'faith-that-moves-mountains',
  //     categoryId: 'general',
  //     title: "Faith That Moves Mountains",
  //     pastorName: "Pastor John Smith",
  //     date: "Jan 12, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon1/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  //     isPremium: false,
  //   ),
  //   // Add other sermons here if you have them
  //   SermonModel(
  //     id: '1b',
  //     slug: 'faith-that-moves-mountains-part-2',
  //     categoryId: 'general',
  //     title: "Faith That Moves Mountains",
  //     pastorName: "Pastor John Smith",
  //     date: "Jan 12, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon1/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  //     isPremium: false,
  //   ),
  //   SermonModel(
  //     id: '2',
  //     slug: 'walking-in-grace',
  //     categoryId: 'general',
  //     title: "Walking in Grace",
  //     pastorName: "Pastor Sarah Lee",
  //     date: "Feb 5, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon2/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  //     isPremium: true,
  //   ),
  //   SermonModel(
  //     id: '3',
  //     slug: 'the-power-of-prayer',
  //     categoryId: 'general',
  //     title: "The Power of Prayer",
  //     pastorName: "Pastor Michael Johnson",
  //     date: "Mar 1, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon3/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  //     isPremium: false,
  //   ),
  //   SermonModel(
  //     id: '4',
  //     slug: 'living-with-purpose',
  //     categoryId: 'general',
  //     title: "Living with Purpose",
  //     pastorName: "Pastor Emily Davis",
  //     date: "Apr 18, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon4/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  //     isPremium: false,
  //   ),
  //   SermonModel(
  //     id: '5',
  //     slug: 'overcoming-fear',
  //     categoryId: 'general',
  //     title: "Overcoming Fear",
  //     pastorName: "Pastor David Kim",
  //     date: "May 10, 2025",
  //     imageUrl: 'https://picsum.photos/seed/sermon5/800/400',
  //     audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  //     isPremium: true,
  //   ),
  // ];

  // Inside MockDatabase class...
  // static List<TestimonyModel> testimonyList = [
  //   TestimonyModel(
  //     id: 1,
  //     title: "God Healed My Family",
  //     verse:
  //         "He heals the brokenhearted and binds up their wounds. — Psalm 147:3",
  //     content:
  //         "I want to share something that has been on my heart for months now. Last spring, my husband was diagnosed with a serious heart condition. The doctors told us he would need surgery, and the prognosis was uncertain at best. I remember sitting in that hospital waiting room, feeling completely overwhelmed and afraid. But through prayer and the support of our church family, we saw a miracle happen...",
  //     images: [
  //       "https://images.unsplash.com/photo-1438032005730-c779502df39b?q=80&w=1000",
  //     ],
  //   ),
  //   TestimonyModel(
  //     id: 2,
  //     title: "Breakthrough in My Finances",
  //     verse: "And my God will meet all your needs. — Philippians 4:19",
  //     content:
  //         "I was struggling with debt for three years. I decided to trust God with my tithes first, even when it didn't make sense. Within two months, I received an unexpected promotion that cleared my debt completely!",
  //     images: [
  //       "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1000",
  //     ],
  //   ),
  //   TestimonyModel(
  //     id: 2,
  //     title: "Breakthrough in My Finances",
  //     verse: "And my God will meet all your needs. — Philippians 4:19",
  //     content:
  //         "I was struggling with debt for three years. I decided to trust God with my tithes first, even when it didn't make sense. Within two months, I received an unexpected promotion that cleared my debt completely!",
  //     images: [
  //       "https://images.unsplash.com/photo-1504052434569-70ad5836ab65?q=80&w=1000",
  //     ],
  //   ),
  //   TestimonyModel(
  //     id: 2,
  //     title: "Breakthrough in My Finances",
  //     verse: "And my God will meet all your needs. — Philippians 4:19",
  //     content:
  //         "I was struggling with debt for three years. I decided to trust God with my tithes first, even when it didn't make sense. Within two months, I received an unexpected promotion that cleared my debt completely!",
  //     images: [
  //       "https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=1000",
  //     ],
  //   ),
  // ];
}
