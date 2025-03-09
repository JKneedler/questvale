import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tag/create_character_tag_cubit.dart';
import 'package:questvale/cubits/character_tag/create_character_tag_view.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:sqflite/sqflite.dart';

class CreateCharacterTagPage extends StatelessWidget {
  const CreateCharacterTagPage({super.key});

  static Future<void> showModal(
      BuildContext context, String characterId, void Function() onTagCreated) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (context) => CreateCharacterTagCubit(
          CharacterRepository(db: context.read<Database>()),
          characterId,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CreateCharacterTagView(
            onTagCreated: onTagCreated,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CreateCharacterTagView(
      onTagCreated: () {},
    );
  }
}
