import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Список всех итемов.
  List<ItemModel> items = List.generate(4, (index) => ItemModel(index: index));

  /// Все ли итемы выбраны.
  bool get isAllSelected => items.fold(
        true,
        (previousValue, item) => item.isSelected && previousValue,
      );

  List<ItemModel> get selectedItems =>
      items.where((item) => item.isSelected).toList();

  bool get isAnySelected => selectedItems.isNotEmpty;

  final allSelectedNotifier = ValueNotifier<bool>(false);

  final anySelectedNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Selection Demo'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: anySelectedNotifier,
            builder: (context, value, child) {
              return value
                  ? IconButton(
                      onPressed: () {
                        print('Is all items selected: $isAllSelected');
                        print('List of selected items: $selectedItems');

                        for (ItemModel item in selectedItems) {
                          if (item.isSelected) {
                            item.title = 'Changed Item';
                          }
                        }
                      },
                      icon: const Icon(Icons.settings),
                    )
                  : const SizedBox.shrink();
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: allSelectedNotifier,
            builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  if (isAllSelected) {
                    for (ItemModel item in items) {
                      item.isSelected = false;
                    }
                  } else {
                    for (ItemModel item in items) {
                      item.isSelected = true;
                    }
                  }
                  allSelectedNotifier.value = isAllSelected;
                  anySelectedNotifier.value = isAnySelected;
                },
                icon: Icon(value ? Icons.deselect : Icons.select_all),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemModelProvider(
            model: items[index],
            child: ItemWidget(
              onSelected: (value) {
                print('$index: $value');
                allSelectedNotifier.value = isAllSelected;
                anySelectedNotifier.value = isAnySelected;
              },
            ),
          );
        },
      ),
    );
  }
}

class ItemModel extends ChangeNotifier {
  final int index;

  bool _isSelected = false;
  String _title = 'Item';

  ItemModel({required this.index});

  set isSelected(bool value) {
    _isSelected = value;
    notifyListeners();
  }

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  bool get isSelected => _isSelected;

  String get title => _title;

  @override
  String toString() => '$title #$index';
}

class ItemModelProvider extends InheritedNotifier<ItemModel> {
  final ItemModel model;

  const ItemModelProvider({
    super.key,
    required this.model,
    required super.child,
  }) : super(notifier: model);

  static ItemModel? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ItemModelProvider>()
        ?.model;
  }

  static ItemModel? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<ItemModelProvider>()
        ?.widget;
    return widget is ItemModelProvider ? widget.model : null;
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.onSelected,
  });

  final void Function(bool value) onSelected;

  @override
  Widget build(BuildContext context) {
    final item = ItemModelProvider.watch(context)!;

    return Card(
      child: ListTile(
        title: Text('$item'),
        trailing: Checkbox(
          value: item.isSelected,
          onChanged: (value) {
            if (value != null) {
              item.isSelected = value;
              onSelected(item.isSelected);
            }
          },
        ),
      ),
    );
  }
}
