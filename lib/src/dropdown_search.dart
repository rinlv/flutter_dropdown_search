import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'suggestions_box_controller.dart';

typedef OptionsInputSuggestions<T> = FutureOr<List<T>> Function(String query);
typedef OptionSelected<T> = void Function(T data, bool selected);
typedef OptionsBuilder<T> = Widget Function(
    BuildContext context, _OptionsInputState<T> state, T data);

class OptionsInput<T> extends StatefulWidget {
  final OptionsInputSuggestions<T> findSuggestions;
  final ValueChanged<T> onChanged;
  final OptionsBuilder<T> suggestionBuilder;
  final TextEditingController textEditingController;
  final double suggestionsBoxMaxHeight;
  final double inputHeight;
  final double spaceSuggestionBox;
  final FocusNode focusNode;
  final InputDecoration inputDecoration;
  final TextInputAction textInputAction;
  final TextStyle textStyle;
  final double scrollPadding;
  final List<T> initOptions;

  const OptionsInput(
      {Key key,
      @required this.findSuggestions,
      @required this.onChanged,
      @required this.suggestionBuilder,
      this.textEditingController,
      this.focusNode,
      this.inputDecoration,
      this.textInputAction,
      this.textStyle,
      this.suggestionsBoxMaxHeight = 0,
      this.scrollPadding = 40,
      this.initOptions = const [],
      this.inputHeight = 40,
      this.spaceSuggestionBox = 4})
      : super(key: key);

  @override
  _OptionsInputState<T> createState() => _OptionsInputState<T>();
}

class _OptionsInputState<T> extends State<OptionsInput<T>> {
  final _layerLink = LayerLink();
  final _suggestionsStreamController = StreamController<List<T>>.broadcast();
  int _searchId = 0;
  SuggestionsBoxController _suggestionsBoxController;
  FocusNode _focusNode;

  RenderBox get renderBox => context.findRenderObject();

  @override
  void initState() {
    super.initState();
    _suggestionsBoxController = SuggestionsBoxController(context);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initOverlayEntry();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification val) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _suggestionsBoxController.overlayEntry.markNeedsBuild();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: widget.textEditingController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                decoration: widget.inputDecoration,
                textInputAction: widget.textInputAction,
                maxLines: 1,
                style: widget.textStyle,
                onSubmitted: _onSearchChanged,
                scrollPadding: EdgeInsets.only(bottom: widget.scrollPadding),
              ),
              height: widget.inputHeight,
            ),
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    if (null == widget.focusNode) {
      _focusNode.dispose();
    }
    _suggestionsStreamController.close();
    _suggestionsBoxController.close();
    super.dispose();
  }

  void _initOverlayEntry() {
    _suggestionsBoxController.overlayEntry = OverlayEntry(
      builder: (context) {
        final size = renderBox.size;
        final renderBoxOffset = renderBox.localToGlobal(Offset.zero);
        final topAvailableSpace = renderBoxOffset.dy;
        final mq = MediaQuery.of(context);
        final bottomAvailableSpace = mq.size.height -
            mq.viewInsets.bottom -
            renderBoxOffset.dy -
            size.height;
        final showTop = topAvailableSpace > bottomAvailableSpace;
        final _suggestionBoxHeight = showTop
            ? min(topAvailableSpace, widget.suggestionsBoxMaxHeight)
            : min(bottomAvailableSpace, widget.suggestionsBoxMaxHeight);

        final compositedTransformFollowerOffset = showTop
            ? Offset(0, -size.height - widget.spaceSuggestionBox)
            : Offset(0, widget.spaceSuggestionBox);

        return StreamBuilder<List<T>>(
          stream: _suggestionsStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              var suggestionsListView = Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _suggestionBoxHeight,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widget.suggestionBuilder(
                        context,
                        this,
                        snapshot.data[index],
                      );
                    },
                  ),
                ),
              );
              return Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: compositedTransformFollowerOffset,
                  child: !showTop
                      ? suggestionsListView
                      : FractionalTranslation(
                          translation: const Offset(0, -1),
                          child: suggestionsListView,
                        ),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }

  void selectSuggestion(T data) {
    _suggestionsStreamController.add(null);
    widget.onChanged(data);
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    final results = await widget.findSuggestions(value);
    if (_searchId == localId && mounted) {
      _suggestionsStreamController.add(results);
    }
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _suggestionsBoxController.open();
      Future.delayed(Duration(milliseconds: 100)).then(
          (value) => _suggestionsStreamController.add(widget.initOptions));
    } else {
      _suggestionsBoxController.close();
    }
  }
}
