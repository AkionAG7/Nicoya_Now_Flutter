import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchFilter extends StatefulWidget {
  const SearchFilter({ Key? key }) : super(key: key);

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  @override
  Widget build(BuildContext context) {
    final query = ModalRoute.of(context)!.settings.arguments as String;


    return Scaffold(
      
    );
  }
}