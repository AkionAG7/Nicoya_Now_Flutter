import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class HomeFoodSearch extends StatelessWidget {
  const HomeFoodSearch({
    super.key,
    required TextEditingController searchController,
  }) : _searchController = searchController;

  final TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '¿Que quieres comer hoy?',
              prefixIcon: const Icon(Icons.storefront_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xffd72a23)),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.searchFilter,
              arguments: _searchController.text.trim(),
            );
          },
        ),
      ],
    );
  }
}
