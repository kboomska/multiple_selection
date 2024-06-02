import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Список всех итемов.
  List<ItemModel> items = List.generate(4, (_) => ItemModel());

  /// Все ли итемы выбраны.
  bool get isAllSelected => items.fold(
        true,
        (previousValue, item) => item.isSelected && previousValue,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Selection Demo'),
        actions: [
          IconButton(
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
            },
            icon: const Icon(Icons.select_all),
          ),
          IconButton(
            onPressed: () {
              print(isAllSelected);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemModelProvider(
            model: items[index],
            child: ItemWidget(
              index: index,
              onSelected: (value) {
                print('$index: $value');
              },
            ),
          );
        },
      ),
    );
  }
}

class ItemModel extends ChangeNotifier {
  final _isSelected = ValueNotifier(false);

  set isSelected(bool value) {
    _isSelected.value = value;
    notifyListeners();
  }

  bool get isSelected => _isSelected.value;
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
    required this.index,
    required this.onSelected,
  });

  final int index;

  final void Function(bool value) onSelected;

  @override
  Widget build(BuildContext context) {
    final item = ItemModelProvider.watch(context)!;

    return Card(
      child: ListTile(
        title: Text('Item #$index'),
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
