# flutter_dropdown_search

Flutter library for building input fields with InputOptions as input options based on [flutter_chips_input](https://github.com/danvick/flutter_chips_input).

## Usage

| ![Image](https://github.com/rinlv/flutter_dropdown_search/blob/master/image/1.png) | ![Image](https://github.com/rinlv/flutter_dropdown_search/blob/master/image/2.png) |
| :------------: | :------------: |

### Import

```dart
import 'package:flutter_dropdown_search/flutter_dropdown_search.dart';
```

### Example

#### OptionsInput

```dart
OptionsInput(
    initOptions: mockResults,
    focusNode: _focusNode,
    textEditingController: textEditingController,
    inputDecoration:
        InputDecoration(border: UnderlineInputBorder()),
    onChanged: (data) {
      setState(() {
        textEditingController.text = data;
        textEditingController.selection =
            TextSelection.fromPosition(TextPosition(
                offset: textEditingController.text.length));
        FocusScope.of(context).requestFocus(FocusNode());
      });
    },
    suggestionsBoxMaxHeight: 160,
    findSuggestions: (String query) {
      if (query.isNotEmpty) {
        var lowercaseQuery = query.toLowerCase();
        return mockResults.where((profile) {
          return profile
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              profile.toLowerCase().contains(query.toLowerCase());
        }).toList(growable: false)
          ..sort((a, b) => a
              .toLowerCase()
              .indexOf(lowercaseQuery)
              .compareTo(b.toLowerCase().indexOf(lowercaseQuery)));
      }
      return mockResults;
    },
    suggestionBuilder: (context, state, profile) {
      return ListTile(
        key: ObjectKey(profile),
        title: Text(profile),
        onTap: () => state.selectSuggestion(profile),
      );
    },
  )
```
