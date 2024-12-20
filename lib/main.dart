import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/config/theme/app_theme.dart';
import 'package:list_in/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:list_in/features/map/presentation/bloc/MapBloc.dart';
import 'package:list_in/features/post/data/sources/post_remoute_data_source.dart';
import 'package:list_in/features/post/presentation/pages/catalog_screen.dart';
import 'package:list_in/features/post/presentation/pages/nessary_details_releted/media_page.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:list_in/list.dart';
import 'package:provider/provider.dart';

import 'injection_container.dart' as di;

// Sample data for products and advertisements
final List<AdvertisedProduct> sampleVideos = [
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "1",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "2",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "3",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "4",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "5",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "6",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "7",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "8",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "9",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "10",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "11",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "12",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "13",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "14",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "15",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "16",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "17",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "18",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
    title: "Big Buck Bunny",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/11/02/14/47/bird-7565103_640.jpg",
      "https://cdn.pixabay.com/photo/2020/04/13/17/32/volendam-5039431_640.jpg"
    ],
    userName: "Axel",
    userRating: 4.5,
    reviewsCount: 121,
    location: "Buxoro, Quyliq Bozor",
    price: "\$90",
    id: "19",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
    title: "Elephant's Dream",
    images: [
      "https://cdn.pixabay.com/photo/2022/11/02/15/35/iphone-14-7565225_640.jpg",
      "https://cdn.pixabay.com/photo/2016/10/02/22/08/construction-1710526_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/30/04/14/house-2187170_640.jpg"
    ],
    userName: "Kolen Morgen",
    userRating: 4.0,
    reviewsCount: 1212,
    location: "Toshkent, Yashnobod",
    price: "\$420",
    id: "20",
  ),
  AdvertisedProduct(
    videoUrl:
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    thumbnailUrl:
        "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg",
    title: "Sintel",
    images: [
      "https://cdn.pixabay.com/photo/2018/07/26/16/14/cars-3564022_640.jpg",
      "https://cdn.pixabay.com/photo/2021/03/25/13/27/cars-6123092_640.jpg",
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    userName: "Malika Bozor",
    userRating: 5.0,
    reviewsCount: 446,
    location: "Toshkent, Mirzo Ulug'bek",
    price: "\$205",
    id: "21",
  ),
];
final List<Product> sampleProducts = [
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
  Product(
    name: "iPhone 4 Pro Max",
    images: [
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "1",
  ),
  Product(
    name: "Car",
    images: [
      "https://cdn.pixabay.com/photo/2024/09/03/08/56/dairy-cattle-9018750_640.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2022/09/25/22/25/iphones-7479304_1280.jpg",
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "2",
  ),
  Product(
    name: "Green iPhone",
    images: [
      "https://cdn.pixabay.com/photo/2017/03/27/15/17/apartment-2179337_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "3",
  ),
  Product(
    name: "Apartments",
    images: [
      "https://cdn.pixabay.com/photo/2016/05/18/10/52/buick-1400243_640.jpg"
    ],
    location: "Tashkent, Yashnobod",
    price: 205,
    isNew: true,
    id: "4",
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AuthBloc>(),
          ),
          BlocProvider<MapBloc>(
            create: (_) => di.sl<MapBloc>(), // Provide the MapBloc here
          ),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = AppTheme.lightTheme;
    AppTheme.setStatusBarAndNavBarColor(theme);
    Provider.of<PostProvider>(context, listen: false).loadCatalog(jsonString);
    return MaterialApp(
      title: 'Your App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const Catalog(),
      routes: {
        '/home': (context) =>
            const Scaffold(body: Center(child: Text('Home Page'))),
      },
    );
  }
}

class Catalog extends StatelessWidget {
  const Catalog({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<PostProvider>(context, listen: false).loadCatalog(jsonString);
    return const CatalogPagerScreen();
  }
}
