class Routes {
  // Auth paths
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const verification = '/verification';
  static const userRegisterDetails = '/user_register_details';

  // Main paths
  static const home = '/home';
  static const profile = '/profile';
  static const profileEdit = '/profileEdit';
  static const post = '/post';
  static const subcategories = '/subcategories';
  static const attributes = '/details';
  static const productDetails = '/product/:id';

  static const myPosts = '/my_posts';
  static const anotherUserProfile = '/a_u_profile';

  static const videosFeed = '/video_feed';
  static const search = '/search';
  static const searchResult = '/searchResult';

  static const publicationsEdit = '/publicationsEdit';

  static const filterHomeResult = '/filterHomeResult';
  static const filterSecondaryResult = '/filterSecondaryResult';

  static const socialConnections = '/connections';

  // chat
  static const chats = '/chat';
  static const room = '/chat/:roomId';
}

class RoutesByName {
  static const welcome = 'welcome';
  static const login = 'login';
  static const signup = 'signup';
  static const verification = 'verification';
  static const userRegisterDetails = 'user_register_details';

  // Main paths
  static const home = 'home';
  static const profile = 'profile';
  static const profileEdit = 'profileEdit';
  static const post = 'post';
  static const subcategories = 'subcategories';
  static const attributes = 'details';
  static const productDetails = 'product/:id';

  static const myPosts = 'my_posts';
  static const anotherUserProfile = 'a_u_profile';

  static const videosFeed = 'video_feed';
  static const search = 'search';
  static const searchResult = 'searchResult';

  static const publicationsEdit = 'publicationsEdit';
  static const filterHomeResult = 'filterHomeResult';
  static const filterSecondaryResult = 'filterSecondaryResult';

  static const socialConnections = 'connections';
}
