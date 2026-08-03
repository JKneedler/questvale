import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/character_tag/create_character_tag_cubit.dart';
import 'package:questvale/cubits/todo_tab/character_tag/create_character_tag_state.dart';

class CreateCharacterTagView extends StatelessWidget {
  final void Function() onTagCreated;

  const CreateCharacterTagView({
    super.key,
    required this.onTagCreated,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CreateCharacterTagCubit, CreateCharacterTagState>(
      listener: (context, state) {
        if (state.status == CreateCharacterTagStatus.success) {
          onTagCreated();
          Navigator.pop(context);
        } else if (state.status == CreateCharacterTagStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ?? 'Failed to create tag')),
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.only(
            top: 6,
            left: 12,
            right: 12,
            bottom: 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(color: colorScheme.primary)),
                  ),
                  TextButton(
                    onPressed: state.status == CreateCharacterTagStatus.loading
                        ? null
                        : () =>
                            context.read<CreateCharacterTagCubit>().submit(),
                    child: state.status == CreateCharacterTagStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Create',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 36,
                child: TextField(
                  key: Key('createCharacterTagView_name_textField'),
                  decoration: InputDecoration(
                    hintText: 'Tag Name',
                    hintStyle:
                        TextStyle(color: colorScheme.onPrimaryFixedVariant),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (value) =>
                      context.read<CreateCharacterTagCubit>().nameChanged(value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
