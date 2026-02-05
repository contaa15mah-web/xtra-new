// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:xtra_neo/core/theme/app_theme.dart';
import 'package:xtra_neo/presentation/pages/browse_page.dart';
import 'package:xtra_neo/presentation/pages/following_page.dart';
import 'package:xtra_neo/presentation/widgets/multistream_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const BrowsePage(),
    const FollowingPage(),
    const MultiStreamGrid(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.darkGrey,
        selectedItemColor: AppTheme.twitchPurple,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Following',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Multistream',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============ BROWSE PAGE ============

class BrowsePage extends StatelessWidget {
  const BrowsePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: AppTheme.twitchPurple,
              tabs: [
                Tab(
                  icon: Icon(Icons.play_arrow),
                  text: 'Twitch',
                ),
                Tab(
                  icon: Icon(Icons.sports_esports),
                  text: 'Kick',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStreamList('Twitch'),
                  _buildStreamList('Kick'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreamList(String platform) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () {
              // Open stream
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[800],
                    child: Stack(
                      children: [
                        // Placeholder image
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        
                        // Live indicator
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.liveIndicator,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        
                        // Viewers
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '1.2K',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.twitchPurple,
                            child: Text(
                              platform[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sample Stream Title',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Username • Category',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============ FOLLOWING PAGE ============

class FollowingPage extends StatelessWidget {
  const FollowingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No followed channels',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Login to see your followed channels',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Open login
              },
              child: const Text('Login with Twitch'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ SETTINGS PAGE ============

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Account',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Login'),
            subtitle: const Text('Not logged in'),
            onTap: () {
              // Open login
            },
          ),
          
          const Divider(),
          
          const ListTile(
            title: Text(
              'Video',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.block),
            title: const Text('Ad-Block'),
            subtitle: const Text('Block ads using HLS proxy'),
            value: true,
            onChanged: (value) {},
          ),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Default Quality'),
            subtitle: const Text('Best'),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.headphones),
            title: const Text('Audio Only Mode'),
            subtitle: const Text('Save data and battery'),
            value: false,
            onChanged: (value) {},
          ),
          
          const Divider(),
          
          const ListTile(
            title: Text(
              'Chat',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_emotions),
            title: const Text('7TV Emotes'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_emotions),
            title: const Text('BetterTTV Emotes'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_emotions),
            title: const Text('FrankerFaceZ Emotes'),
            value: true,
            onChanged: (value) {},
          ),
          
          const Divider(),
          
          const ListTile(
            title: Text(
              'About',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source'),
            subtitle: const Text('Based on Xtra'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
