import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/common/backdrops.dart';

class HorizontalBackdropList extends StatefulWidget {
  final List<String> backdrops;
  final Function(String) onBackdropSelected;  // Neue callback Funktion

  const HorizontalBackdropList({
    Key? key,
    required this.backdrops,
    required this.onBackdropSelected,  // Neuer required Parameter
  }) : super(key: key);

  @override
  State<HorizontalBackdropList> createState() => _HorizontalBackdropListState();
}

class _HorizontalBackdropListState extends State<HorizontalBackdropList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.backdrops.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: BackdropCard(
                  backdropUrl: widget.backdrops[index],
                  onTap: () {
                    // Ruft die callback Funktion mit dem ausgewählten Backdrop auf
                    widget.onBackdropSelected(widget.backdrops[index]);
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          top: 45,
          bottom: 45,
          child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _scrollLeft,
                      child: const Icon(
                        Icons.arrow_left,
                        size: 65,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
        ),
        Positioned(
          right: 0,
          top: 45,
          bottom: 45,
          child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _scrollRight,
                      child: const Icon(
                        Icons.arrow_right,
                        size: 65,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}