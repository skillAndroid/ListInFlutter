import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/map/domain/entities/coordinates_entity.dart';
import 'package:list_in/features/map/domain/entities/location_entity.dart';
import 'package:list_in/features/map/domain/usecases/get_location_usecase.dart';
import 'package:list_in/features/map/domain/usecases/search_locations_usecase.dart';
import 'package:list_in/features/map/presentation/bloc/MapState.dart';
import 'package:rxdart/rxdart.dart';

class MapBloc extends Cubit<MapState> {
  final GetLocationUseCase getLocationUseCase;
  final SearchLocationsUseCase searchLocationsUseCase;

  final _searchQueryController = BehaviorSubject<String>();
  final _cameraIdleController = BehaviorSubject<LatLng>();
  late final StreamSubscription _searchSubscription;
  late final StreamSubscription _cameraIdleSubscription;

  MapBloc({
    required this.getLocationUseCase,
    required this.searchLocationsUseCase,
  }) : super(
          MapIdleState(
            const LatLng(41.312128, 69.241796),
          ),
        ) {
    _searchSubscription = _searchQueryController
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) => _performSearch(query));
    _cameraIdleSubscription = _cameraIdleController
        .debounceTime(const Duration(milliseconds: 2000))
        .listen((currentCenter) => _handleCameraIdle(currentCenter));
  }

  void onCameraMove() {
    emit(MapMovingState());
  }

  void onLocationConfirmed() {
    emit(MapLocationConfirmedState());
  }

  void onCameraIdle(LatLng currentCenter) {
    _cameraIdleController.add(currentCenter); // Добавляем событие в поток
  }

  void _handleCameraIdle(LatLng currentCenter) async {
    emit(MapLoadingState());
    final coordinates = CoordinatesEntity(
      latitude: currentCenter.latitude,
      longitude: currentCenter.longitude,
    );
    try {
      final locationName = await getLocationUseCase(params: coordinates);
      emit(MapIdleState(currentCenter, locationName: locationName));
    } on Failure catch (failure) {
      emit(MapErrorState(_mapFailureToMessage(failure)));
    } catch (exception) {
      emit(MapErrorState(_mapFailureToMessage(_convertToFailure(exception))));
    }
  }

  void searchLocations(String query) {
    _searchQueryController.add(query); // Добавляем запрос в поток
  }

  Future<void> _performSearch(String query) async {
    emit(MapLoadingState());

    try {
      final result = await searchLocationsUseCase(params: query);
      emit(MapSearchResultsState(result));
    } on Failure catch (failure) {
      emit(MapErrorState(_mapFailureToMessage(failure)));
    } catch (exception) {
      emit(MapErrorState(_mapFailureToMessage(_convertToFailure(exception))));
    }
  }

  void navigateToLocation(LocationEntity location) {
    emit(
      MapIdleState(
        LatLng(
          location.coordinates.latitude,
          location.coordinates.longitude,
        ),
        locationName: location.name,
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server Error';
      case NetworkFailure _:
        return 'Network Error';
      case CacheFailure _:
        return 'Cache Error';
      case UnexpectedFailure _:
        return 'Unexpected Error';
      default:
        return 'Unexpected Error';
    }
  }

  Failure _convertToFailure(Object exception) {
    if (exception is DioException) {
      return ServerFailure(); // Можно добавить более точное определение
    } else if (exception is NetworkFailure) {
      return NetworkFailure();
    } else {
      return UnexpectedFailure(); // Например, тип для неизвестных ошибок
    }
  }

  @override
  Future<void> close() {
    _searchSubscription.cancel(); // Отписываемся от потока
    _searchQueryController.close(); // Закрываем контроллер
    _cameraIdleSubscription.cancel();
    _cameraIdleController.close(); // Закрываем контроллер
    return super.close();
  }
}
