import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:bubble/bubble.dart';
import 'package:emoji_picker/text_composer.dart';

void main() => runApp(MainApp());

final FocusNode _nodeText = FocusNode();

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Emoji Picker Test"),
        ),
        body: Content(),
      ),
    );
  }
}

class Content extends StatefulWidget {
  const Content({
    Key key,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  TextEditingController _controller = new TextEditingController();

  final custom2Notifier = ValueNotifier<String>('');

  bool showEmoji = false;

  int _cursorPosition = -1;

  List<String> _text = new List();

  @override
  initState() {
    super.initState();

    _nodeText.addListener(() {
      if (_nodeText.hasFocus) {
        if (mounted && showEmoji)
          setState(() {
            showEmoji = false;
          });
        if (_controller.selection.baseOffset < 0) {
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: _cursorPosition));
        }
      }
    });

    _controller.addListener(() {
      if (_controller.selection.baseOffset >= 0) {
        _cursorPosition = _controller.selection.baseOffset;
      }
      print(_controller.selection.baseOffset);
    });
  }

  @override
  dispose() {
    _nodeText.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            cacheExtent: 1000.0,
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemCount: _text.length,
            itemBuilder: (_, int index) {
              // _messages[index].animationController.forward();
              return Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
                nip: index % 2 == 0 ? BubbleNip.leftTop : BubbleNip.rightTop,
                child: Text(_text[_text.length - 1 - index]),
              );
            },
          ),
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: <Widget>[
        //     Row(
        //       children: <Widget>[
        //         IconButton(
        //             icon: Icon(Icons.gif),
        //             onPressed: () {
        //               _nodeText.unfocus();

        //               setState(() {
        //                 showEmoji = !showEmoji;
        //               });

        //               if (!showEmoji) {
        //                 _nodeText.requestFocus();
        //               }
        //             }),
        //         Flexible(
        //           child: custom.TextField(
        //             showKeyboard: !showEmoji,
        //             controller: _controller,
        //             focusNode: _nodeText,
        //             decoration: InputDecoration(
        //               hintText: "Input Number with Custom Footer",
        //             ),
        //           ),
        //         )
        //       ],
        //     ),
        //   ],
        // ),
        TextComposer(
          onSend: (text) {
            setState(() {
              _text.add(text);
            });
          },
        )
      ],
    );
  }

  Widget _buildTextComposer() {
    return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: new BoxDecoration(color: Colors.blueGrey[50], borderRadius: const BorderRadius.all(const Radius.circular(24.0))),
        constraints: BoxConstraints(maxHeight: 104.0),
        child: new Row(children: <Widget>[
          IconButton(
              icon: showEmoji ? Icon(Icons.keyboard_hide) : Icon(Icons.insert_emoticon),
              onPressed: () {
                // _nodeText.unfocus();

                setState(() {
                  showEmoji = !showEmoji;
                });

                // if (!showEmoji) {
                //   _nodeText.requestFocus();
                // }
              }),
          new Flexible(
            child: new TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              readOnly: showEmoji,
              showCursor: true,
              // onChanged: _parseContent,
              focusNode: _nodeText,
              decoration: new InputDecoration.collapsed(
                hintText: "Send a message",
              ),
            ),
          ),
          new Container(
            child: new IconButton(
                icon: new Icon(Icons.photo_camera),
                onPressed: () {
                  // getImage(_controller.text);
                }),
          ),
          new Container(
            //margin: new EdgeInsets.symmetric(horizontal: 2.0),
            child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  setState(() {
                    _text.add(_controller.text);
                    _controller.text = "";
                  });
                }),
          ),
        ]));
  }
}

/// A quick example "keyboard" widget for picking a color.
class ColorPickerKeyboard extends StatelessWidget with KeyboardCustomPanelMixin<String> implements PreferredSizeWidget {
  final ValueNotifier<String> notifier;
  static const double _kKeyboardHeight = 200;

  ColorPickerKeyboard({Key key, this.notifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double rows = 3;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int colorsCount = Colors.primaries.length;
    final int colorsPerRow = (colorsCount / rows).ceil();
    final double itemWidth = screenWidth / colorsPerRow;
    final double itemHeight = _kKeyboardHeight / rows;

    return Container(
      height: _kKeyboardHeight,
      child: SafeArea(
        child: EmojiPicker(
          rows: 5,
          columns: 9,
          recommendKeywords: ["racing", "horse"],
          numRecommended: 10,
          onEmojiSelected: (emoji, category) {
            print(emoji);
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_kKeyboardHeight);
}
