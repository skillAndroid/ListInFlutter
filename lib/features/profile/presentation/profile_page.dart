import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:list_in/config/assets/app_icons.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // bgColor
      body: Column(
        children: [
          Container(
            height: 30,
            color: const Color(0xFFEEEEEE), // secondaryColor
          ),
          const TopBarProfile(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 2,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const ProfilePart(),
                  Container(
                    height: 12,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const LittleInfoPart(),
                  Container(
                    height: 12,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const UpgradePart(),
                  Container(
                    height: 12,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const BasePart(),
                  Container(
                    height: 12,
                    color: const Color(0xFFEEEEEE),
                  ),
                  const BasePart2(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBarProfile extends StatelessWidget {
  const TopBarProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to edit profile
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
                Container(
                  height: 1,
                  width: 30,
                  color: const Color(0xFF8A8A8A).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePart extends StatelessWidget {
  const ProfilePart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              AppImages.appLogo,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anna Dii',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEEEEE),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(92, 43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '12 Following',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '19 Followers',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          height: 1,
                          width: 61,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LittleInfoPart extends StatelessWidget {
  const LittleInfoPart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 8, 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Ionicons.location,
                  size: 34,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'City',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tashkent',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Ionicons.person,
                  size: 34,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Face',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Business',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpgradePart extends StatelessWidget {
  const UpgradePart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Upgrade Premium',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.star,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class BasePart extends StatelessWidget {
  const BasePart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          image: AppIcons.addsIc,
          title: 'My Ads',
          trailing: '(5)',
        ),
        const Divider(),
        ProfileMenuItem(
          image: AppIcons.favorite,
          title: 'My favourites',
        ),
        const Divider(),
        ProfileMenuItem(
          image: AppIcons.chatIc,
          title: 'Chats',
          trailing: '(3)',
        ),
        const Divider(),
        ProfileMenuItem(
          image: AppIcons.cardIc,
          title: 'My balance',
          trailing: '\$33',
          showTrailingBox: true,
        ),
        const Divider(),
        ProfileMenuItem(
          image: AppIcons.languageIc,
          title: 'Language',
          trailing: 'English',
          showTrailingBox: true,
        ),
      ],
    );
  }
}

class BasePart2 extends StatelessWidget {
  const BasePart2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          image: AppIcons.supportIc,
          title: 'Contact Support',
        ),
        const Divider(),
        ProfileMenuItem(
          image: AppIcons.logoutIc,
          title: 'Log out',
          onTap: () {
            // Handle logout
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle logout
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String image;
  final String title;
  final String? trailing;
  final bool showTrailingBox;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.image,
    required this.title,
    this.trailing,
    this.showTrailingBox = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Image.asset(image,color: AppColors.black,),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (trailing != null)
                  showTrailingBox
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trailing!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          trailing!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
