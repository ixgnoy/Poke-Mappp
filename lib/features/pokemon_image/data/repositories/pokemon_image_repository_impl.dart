import 'package:dartz/dartz.dart';
import 'package:flutter_mapp_clean_architecture/features/pokemon_image/business/entities/pokemon_image_entity.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../business/repositories/pokemon_image_repository.dart';
import '../datasources/pokemon_image_local_data_source.dart';
import '../datasources/pokemon_image_remote_data_source.dart';
import '../models/pokemon_image_model.dart';

class PokemonImageRepositoryImpl implements PokemonImageRepository {
  final PokemonImageRemoteDataSource remoteDataSource;
  final PokemonImageLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PokemonImageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PokemonImageEntity>> getPokemonImage(
      {required PokemonImageParams pokemonImageParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        PokemonImageModel remotePokemonImage =
            await remoteDataSource.getPokemonImage(pokemonImageParams: pokemonImageParams);

        localDataSource.cachePokemonImage(pokemonImageToCache: remotePokemonImage);

        return Right(remotePokemonImage);
      } on ServerException {
        return Left(ServerFailure(errorMessage: 'This is a server exception'));
      }
    } else {
      try {
        PokemonImageModel localPokemonImage = await localDataSource.getLastPokemonImage();
        return Right(localPokemonImage);
      } on CacheException {
        return Left(CacheFailure(errorMessage: 'This is a cache exception'));
      }
    }
  }
}
