import 'package:flutter/material.dart';
import 'dart:async';

class SearchWidget extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final Function()? onClearSearch;

  const SearchWidget({
    Key? key,
    this.onSearchChanged,
    this.onClearSearch,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text.trim();

    // Cancel previous timer
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    // If search is cleared
    if (text.isEmpty) {
      setState(() {
        _isSearching = false;
      });

      if (widget.onClearSearch != null) {
        widget.onClearSearch!();
      }
      return;
    }

    // Show searching indicator
    setState(() {
      _isSearching = true;
    });

    // Set a new timer for debouncing (400ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(text);
      }
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });

    if (widget.onClearSearch != null) {
      widget.onClearSearch!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0,
                  color: Color(0xFFfb3132),
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFFfb3132),
              ),
              fillColor: Color(0xFFFAFAFA),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Color(0xFFfb3132),
                      ),
                      onPressed: _clearSearch,
                    )
                  : Icon(
                      Icons.sort,
                      color: Color(0xFFfb3132),
                    ),
              hintStyle: TextStyle(color: Color(0xFFd0cece), fontSize: 18),
              hintText: "What would you like to buy?",
            ),
          ),

          // Show searching indicator
          if (_isSearching)
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFfb3132),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Searching...',
                    style: TextStyle(
                      color: Color(0xFFfb3132),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
