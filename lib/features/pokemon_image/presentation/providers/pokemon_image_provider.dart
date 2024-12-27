import 'package:data_connection_checker_tv/data_connection_checker.dart';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mapp_clean_architecture/core/constants/constants.dart';
import 'package:flutter_mapp_clean_architecture/features/pokemon/business/entities/pokemon_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../business/entities/pokemon_image_entity.dart';
import '../../business/usecases/get_pokemon_image.dart';
import '../../data/datasources/pokemon_image_local_data_source.dart';
import '../../data/datasources/pokemon_image_remote_data_source.dart';
import '../../data/repositories/pokemon_image_repository_impl.dart';

class PokemonImageProvider extends ChangeNotifier {
  PokemonImageEntity? template;
  Failure? failure;

  PokemonImageProvider({
    this.template,
    this.failure,
  });

  PokemonImageEntity? get pokemonImage => null;

  void eitherFailureOrPokemonImage({required PokemonEntity pokemonEntity, required PokemonEntity PokemonEntity}) async {
    PokemonImageRepositoryImpl repository = PokemonImageRepositoryImpl(
      remoteDataSource: PokemonImageRemoteDataSourceImpl(
        dio: Dio(),
      ),
      localDataSource: PokemonImageLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    String imageUrl = isShiny ? pokemonEntity.sprites.other.officialArtwork.frontShiny : pokemonEntity.sprites.other.officialArtwork.frontDefault;

    final failureOrPokemonImage = await GetPokemonImage(pokemonImageRepository: repository).call(
      pokemonImageParams: PokemonImageParams(name: pokemonEntity.name, imageUrl: imageUrl),
    );

    failureOrPokemonImage.fold(
      (Failure newFailure) {
        template = null;
        failure = newFailure;
        notifyListeners();
      },
      (PokemonImageEntity newPokemonImage) {
        template = newPokemonImage;
        failure = null;
        notifyListeners();
      },
    );
  }
}
